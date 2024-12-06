package com.goorm.cgcg.controller;

import com.goorm.cgcg.config.token.TokenDto;
import com.goorm.cgcg.config.token.TokenProvider;
import com.goorm.cgcg.dto.member.LoginRequestDto;
import com.goorm.cgcg.dto.member.LoginResponseDto;
import com.goorm.cgcg.dto.member.MainPageDto.MainDto;
import com.goorm.cgcg.dto.member.RegisterRequestDto;
import com.goorm.cgcg.service.FileUploadService;
import com.goorm.cgcg.service.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
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
    private final FileUploadService fileUploadService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody @Validated  RegisterRequestDto registerDto) throws IOException {
        memberService.register(registerDto);
        return ResponseEntity.ok("회원가입 성공");
    }

    @PostMapping("/register/image")
    public ResponseEntity<String> registerImage(@RequestParam("file") MultipartFile file) throws IOException {
        String url = fileUploadService.uploadFile(file);
        return ResponseEntity.ok(url);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto loginRequestDto) {
        TokenDto token = memberService.login(loginRequestDto);
        return ResponseEntity.ok(LoginResponseDto.builder().accessToken(token.getAccessToken()).build());
    }

    @GetMapping("/reissue")
    public ResponseEntity<?> reissue(HttpServletRequest request, HttpServletResponse response) {
        String token = tokenProvider.resolveToken(request);
        TokenDto newToken = tokenProvider.reissueToken(token, request, response);
        return ResponseEntity.ok(LoginResponseDto.builder().accessToken(newToken.getAccessToken()));
    }

    @GetMapping("/main")
    public ResponseEntity<MainDto> getMain(@RequestParam Long id) {
        MainDto mainDto = memberService.getMainData(id);
        return ResponseEntity.ok(mainDto);
    }
}
