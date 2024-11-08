package com.goorm.cgcg.service;

import com.goorm.cgcg.config.token.TokenProvider;
import com.goorm.cgcg.config.token.TokenRedis;
import com.goorm.cgcg.config.token.TokenRedisRepository;
import com.goorm.cgcg.converter.MemberConverter;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.member.LoginRequestDto;
import com.goorm.cgcg.dto.member.RegisterRequestDto;
import com.goorm.cgcg.config.token.TokenDto;
import com.goorm.cgcg.repository.MemberRepository;
import jakarta.transaction.Transactional;
import java.io.IOException;
import java.util.NoSuchElementException;
import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@RequiredArgsConstructor
@Service
@Transactional
public class MemberService {
    private final BCryptPasswordEncoder encoder;
    private final MemberRepository memberRepository;
    private final AuthenticationManager authenticationManager;
    private final TokenProvider tokenProvider;
    private final TokenRedisRepository tokenRedisRepository;
    private final RedisTemplate redisTemplate;
    private final FileUploadService fileUploadService;

    public void register(RegisterRequestDto registerRequestDto) throws IOException {
        String encryptedPassword = encoder.encode(registerRequestDto.getPassword());
        RegisterRequestDto newRegisterDto = RegisterRequestDto.builder()
            .email(registerRequestDto.getEmail())
            .password(encryptedPassword)
            .nickname(registerRequestDto.getNickname())
            .profileImage(registerRequestDto.getProfileImage())
            .build();
        Member member = MemberConverter.convertToEntity(newRegisterDto);
        if (!memberRepository.existsByEmail(registerRequestDto.getEmail())) {
            memberRepository.save(member);
        }
    }

    public String uploadProfileImage(MultipartFile file) throws IOException {
        return fileUploadService.uploadFile(file);
    }

    public TokenDto login(LoginRequestDto loginRequestDto) {
        String email = loginRequestDto.getEmail();
        String password = loginRequestDto.getPassword();
        Member member = memberRepository.findByEmail(email)
            .orElseThrow(() -> new NoSuchElementException("Member with email " + email + " not found"));
        if (!encoder.matches(password, member.getPassword())) {
            throw new IllegalArgumentException("Invalid password");
        } else {
            UsernamePasswordAuthenticationToken token
                = new UsernamePasswordAuthenticationToken(email, password);
            Authentication authentication
                = authenticationManager.authenticate(token);
            TokenDto jwtToken = tokenProvider.generateToken(authentication);
            tokenRedisRepository.save(
                new TokenRedis(authentication.getName(), jwtToken.getAccessToken(), jwtToken.getRefreshToken()));
            return jwtToken;
        }
    }
}
