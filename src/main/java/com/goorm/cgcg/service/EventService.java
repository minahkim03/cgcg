package com.goorm.cgcg.service;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.event.EventPageDto.CustomMemberDto;
import com.goorm.cgcg.dto.event.EventPageDto.EventDto;
import com.goorm.cgcg.repository.EventRepository;
import com.goorm.cgcg.repository.MemberEventRepository;
import com.goorm.cgcg.repository.PlaceRepository;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class EventService {

    private final EventRepository eventRepository;
    private final PlaceRepository placeRepository;
    private final MemberEventRepository memberEventRepository;

    public EventDto getEventPage(Long id) {
        Event event = eventRepository.findById(id).orElseThrow();
        List<CustomMemberDto> memberList = new ArrayList<>();
        List<Member> members= memberEventRepository.findMembersByEventId(id);
        for (Member member : members) {
            memberList.add(CustomMemberDto.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .profileImage(member.getProfileImage())
                .build());
        }
        return EventDto.builder()
            .title(event.getTitle())
            .date(event.getDate())
            .places(placeRepository.findAllByEvent(event))
            .members(memberList)
            .build();
    }

}
