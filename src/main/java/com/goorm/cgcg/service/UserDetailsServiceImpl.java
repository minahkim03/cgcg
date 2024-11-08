package com.goorm.cgcg.service;

import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Member member = memberRepository.findByEmail(email)
            .orElseThrow(() -> new IllegalArgumentException(email));

        return Member.builder()
            .id(member.getId())
            .password(member.getPassword())
            .nickname(member.getNickname())
            .email(member.getEmail())
            .profileImage(member.getProfileImage())
            .build();
    }
}
