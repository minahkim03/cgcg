package com.goorm.cgcg.converter;

import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.member.RegisterRequestDto;
import org.springframework.stereotype.Component;

@Component
public class MemberConverter {

    public static Member convertToEntity(RegisterRequestDto registerDto) {
        return Member.builder()
            .email(registerDto.getEmail())
            .password(registerDto.getPassword())
            .nickname(registerDto.getNickname())
            .profileImage(registerDto.getProfileImage())
            .build();
    }

}
