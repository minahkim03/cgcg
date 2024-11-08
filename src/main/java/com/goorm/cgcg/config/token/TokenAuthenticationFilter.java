package com.goorm.cgcg.config.token;

import com.goorm.cgcg.config.CookieUtils;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

@RequiredArgsConstructor
public class TokenAuthenticationFilter extends OncePerRequestFilter {
    private final TokenProvider tokenProvider;
    private final RedisTemplate redisTemplate;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
        FilterChain filterChain) throws ServletException, IOException {

        Optional<Cookie> accessTokenCookie = CookieUtils.getCookie(request, "accessToken");

        if (accessTokenCookie.isPresent()) {
            String accessToken = accessTokenCookie.get().getValue();

            if (isTokenBlacklisted(accessToken)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("로그아웃 처리된 엑세스 토큰입니다.");
                return;
            }

            if (tokenProvider.validateToken(accessToken)) {
                UsernamePasswordAuthenticationToken authentication =
                    (UsernamePasswordAuthenticationToken) tokenProvider.getAuthentication(accessToken);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } else {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("유효하지 않은 토큰입니다.");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private boolean isTokenBlacklisted(String accessToken) {
        String blackToken = (String) redisTemplate.opsForValue().get(accessToken);
        return StringUtils.hasText(blackToken);
    }
}
