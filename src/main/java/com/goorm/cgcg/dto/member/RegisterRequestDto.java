package com.goorm.cgcg.dto.member;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Builder
@Getter
@AllArgsConstructor(access = AccessLevel.PROTECTED)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RegisterRequestDto {
    @NotBlank(message = "이메일은 필수 항목입니다.")
    @Email(message = "유효한 이메일 주소를 입력해주세요.")
    private String email;

    @NotBlank(message = "비밀번호는 필수 항목입니다.")
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,16}$",
        message = "비밀번호는 영문자, 숫자, 특수문자를 포함하여 8~16자로 입력해주세요.")
    private String password;

    @NotBlank(message = "프로필 사진을 설정해주세요.")
    private String profileImage;

    @NotBlank(message = "닉네임은 필수 항목입니다.")
    @Pattern(regexp = "^[가-힣a-zA-Z]{1,10}$", message = "닉네임은 한글과 영문자만 사용하여 1~10자로 입력해주세요.")
    private String nickname;
}
