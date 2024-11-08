package com.goorm.cgcg.controller;

import com.goorm.cgcg.config.CookieUtils;
import com.goorm.cgcg.config.token.TokenDto;
import com.goorm.cgcg.config.token.TokenProvider;
import com.goorm.cgcg.dto.member.LoginRequestDto;
import com.goorm.cgcg.dto.member.RegisterRequestDto;
import com.goorm.cgcg.service.MemberService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RequiredArgsConstructor
@RestController
public class MemberController {

    private final TokenProvider tokenProvider;
    private final MemberService memberService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody @Validated  RegisterRequestDto registerDto) throws IOException {
        memberService.register(registerDto);
        return ResponseEntity.ok("회원가입 성공");
    }

    @PostMapping("/register/image")
    public ResponseEntity<String> registerImage(@RequestParam("file") MultipartFile file) throws IOException {
        String url = memberService.uploadProfileImage(file);
        return ResponseEntity.ok(url);
    }

    @PostMapping("/login")
    public ResponseEntity<Cookie> login(@RequestBody LoginRequestDto loginRequestDto, HttpServletResponse response) {
        TokenDto token = memberService.login(loginRequestDto);
        Cookie cookie = new Cookie("access_token", token.getAccessToken());
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(60 * 30);
        response.addCookie(cookie);
        return ResponseEntity.ok(cookie);
    }

    @GetMapping("/reissue")
    public ResponseEntity<?> reissue(HttpServletRequest request, HttpServletResponse response) {
        TokenDto token = tokenProvider.resolveToken(request);
        TokenDto newToken = tokenProvider.reissueToken(token.getAccessToken(), request, response);
        Cookie cookie = new Cookie("access_token", newToken.getAccessToken());
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(60 * 30);
        response.addCookie(cookie);
        return ResponseEntity.ok(null);
    }
}
