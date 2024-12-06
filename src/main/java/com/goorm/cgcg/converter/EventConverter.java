package com.goorm.cgcg.converter;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.dto.event.NewEventDto;
import org.springframework.stereotype.Component;

@Component
public class EventConverter {

    public Event convertToEntity(NewEventDto newEventDto) {
        return Event.builder()
            .date(newEventDto.getDate())
            .title(newEventDto.getTitle())
            .image(newEventDto.getImage())
            .build();
    }

}
