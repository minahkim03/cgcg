package com.goorm.cgcg.service;

import com.goorm.cgcg.domain.FriendRelationship;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.friend.FindFriendDto;
import com.goorm.cgcg.dto.friend.FriendListDto.CustomFriendDto;
import com.goorm.cgcg.dto.friend.FriendListDto.FriendDto;
import com.goorm.cgcg.repository.FriendRelationshipRepository;
import com.goorm.cgcg.repository.MemberRepository;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@Transactional
@RequiredArgsConstructor
public class FriendService {

    private final MemberRepository memberRepository;
    private final FriendRelationshipRepository friendRelationshipRepository;

    public FindFriendDto findFriend(String code) {
        Member friend = memberRepository.findByEmail(code).orElseThrow();
        return FindFriendDto.builder()
            .id(friend.getId())
            .nickname(friend.getNickname())
            .profileImage(friend.getProfileImage())
            .build();
    }

    public void addFriend(Long id, Long friendId) {
        Member member = memberRepository.findById(id).orElseThrow();
        Member friend = memberRepository.findById(friendId).orElseThrow();
        FriendRelationship friendRelationship1 = FriendRelationship.builder()
            .friend(friend)
            .member(member)
            .build();
        FriendRelationship friendRelationship2 = FriendRelationship.builder()
            .friend(member)
            .member(friend)
            .build();
        friendRelationshipRepository.save(friendRelationship1);
        friendRelationshipRepository.save(friendRelationship2);
    }

    public FriendDto getFriendList(Long id) {
        Member member = memberRepository.findById(id).orElseThrow();
        List<CustomFriendDto> friends = new ArrayList<>();
        for (FriendRelationship friendRelationship : member.getFriendRelationships()) {
            Member friend = friendRelationship.getFriend();
            friends.add(CustomFriendDto.builder()
                .nickname(friend.getNickname())
                .profileImage(friend.getProfileImage())
                .id(friend.getId())
                .build());
        }
        return FriendDto.builder()
            .friends(friends)
            .build();
    }
}
