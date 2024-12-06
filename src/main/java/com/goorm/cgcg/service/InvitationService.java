package com.goorm.cgcg.service;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.domain.Invitation;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.domain.MemberEvent;
import com.goorm.cgcg.dto.invitation.InvitationDto;
import com.goorm.cgcg.dto.invitation.InvitationDto.CustomInvitationDto;
import com.goorm.cgcg.dto.invitation.InvitationDto.InvitationListDto;
import com.goorm.cgcg.repository.InvitationRepository;
import com.goorm.cgcg.repository.MemberEventRepository;
import com.goorm.cgcg.repository.MemberRepository;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class InvitationService {

    private final MemberRepository memberRepository;
    private final InvitationRepository invitationRepository;
    private final MemberEventRepository memberEventRepository;

    public InvitationListDto getInvitationList(Long id) {
        Member member = memberRepository.findById(id).orElseThrow();
        List<Invitation> receivedInvitations = member.getReceivedInvitations();
        List<CustomInvitationDto> invitationList = new ArrayList<>();
        for (Invitation invitation : receivedInvitations) {
            invitationList.add(CustomInvitationDto.builder()
                .profileImage(invitation.getSender().getProfileImage())
                .date(invitation.getEvent().getDate())
                .title(invitation.getEvent().getTitle())
                .id(invitation.getId())
                .nickname(invitation.getSender().getNickname())
                .build()
            );
        }
        return InvitationListDto.builder().invitations(invitationList).build();
    }

    public void respondToInvitation(Long id, Boolean accept) {
        Invitation invitation = invitationRepository.findById(id).orElseThrow();

        invitation.setAccepted(accept);

        Member receiver = invitation.getReceiver();
        receiver.getReceivedInvitations().removeIf(inv -> inv.getId().equals(id));

        invitationRepository.save(invitation);
        memberRepository.save(receiver);

        if (accept) {
            MemberEvent memberEvent = MemberEvent.builder()
                .event(invitation.getEvent())
                .member(receiver)
                .role("MEMBER")
                .build();
            memberEventRepository.save(memberEvent);
        }
    }

}
