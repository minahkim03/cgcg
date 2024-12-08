package com.goorm.cgcg.converter;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.domain.Place;
import com.goorm.cgcg.dto.event.NewPlaceDto;
import org.springframework.stereotype.Component;

@Component
public class PlaceConverter {
    public Place convertToEntity(NewPlaceDto newPlaceDto, Event event) {
        return Place.builder()
            .latitude(newPlaceDto.getLatitude())
            .longitude(newPlaceDto.getLongitude())
            .name(newPlaceDto.getName())
            .time(newPlaceDto.getTime())
            .event(event)
            .build();
    }
}
