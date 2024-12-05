package com.goorm.cgcg.config.token;

import static java.lang.System.getenv;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.UnsupportedJwtException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collection;
import java.util.Date;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class TokenProvider {

    private final TokenRedisRepository tokenRedisRepository;
    Map<String, String> env = getenv();
    private String secretKey = Base64.getEncoder().encodeToString(
        Objects.requireNonNull(env.get("JWT_SECRET")).getBytes());
    private static final String AUTHORITIES_KEY = "ROLE_USER";

    public TokenDto generateToken(Authentication authentication) {

        long currentTime = (new Date()).getTime();

        Date accessTokenExpirationTime = new Date(currentTime + (1000 * 60 * 60 * 24));
        Date refreshTokenExpirationTime = new Date(currentTime + (1000 * 60 * 60 * 24 * 7));

        String accessToken = Jwts.builder()
            .setIssuedAt(new Date(currentTime))
            .setExpiration(accessTokenExpirationTime)
            .signWith(SignatureAlgorithm.HS256, secretKey)
            .compact();

        String refreshToken = Jwts.builder()
            .setExpiration(refreshTokenExpirationTime)
            .signWith(SignatureAlgorithm.HS256, secretKey)
            .compact();

        return TokenDto.builder()
            .grantType("Bearer")
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .build();

    }

    public Authentication getAuthentication(String accessToken) {
        Claims claims = Jwts.parserBuilder()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(accessToken)
            .getBody();

        Collection<? extends GrantedAuthority> authorities =
            Arrays.stream(claims.get(AUTHORITIES_KEY).toString().split(","))
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        User principal = new User(claims.getSubject(), "", authorities);

        return new UsernamePasswordAuthenticationToken(principal, accessToken, authorities);
    }

    //액세스 토큰과 리프레시 토큰 함께 재발행
    public TokenDto reissueToken(String token, HttpServletRequest request, HttpServletResponse response) {
        TokenRedis tokenRedis = tokenRedisRepository.findByAccessToken(token)
            .orElseThrow();

        String refreshToken = tokenRedis.getRefreshToken();

        UsernamePasswordAuthenticationToken authentication = (UsernamePasswordAuthenticationToken) getAuthentication(refreshToken);

        TokenDto tokenDTO = generateToken(authentication);

        tokenRedis.updateToken(tokenDTO.getAccessToken(), tokenDTO.getRefreshToken());
        tokenRedisRepository.save(tokenRedis);

        return tokenDTO;

    }

    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }


    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {

            log.info("잘못된 JWT 서명입니다.");
        } catch (ExpiredJwtException e) {

            log.info("만료된 JWT 토큰입니다.");
        } catch (UnsupportedJwtException e) {

            log.info("지원되지 않는 JWT 토큰입니다.");
        } catch (IllegalArgumentException e) {

            log.info("JWT 토큰이 잘못되었습니다.");
        }
        return false;
    }

    public Claims getClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(secretKey).build().parseClaimsJws(token).getBody();
    }

    public Long getRemainingExpirationTime(String token) {
        Claims claims = getClaims(token);
        Date expirationDate = claims.getExpiration();
        long now = (new Date()).getTime();

        return expirationDate.getTime() - now;
    }
}
