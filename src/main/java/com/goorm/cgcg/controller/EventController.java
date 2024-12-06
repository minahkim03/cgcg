package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.event.EventPageDto.EventDto;
import com.goorm.cgcg.dto.event.NewPlaceDto;
import com.goorm.cgcg.service.EventService;
import jakarta.validation.constraints.Null;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @GetMapping("/event")
    public ResponseEntity<EventDto> getEventPage(@RequestParam Long id) {
        EventDto eventPage = eventService.getEventPage(id);
        return ResponseEntity.ok(eventPage);
    }

    @PostMapping("/event/add")
    public ResponseEntity<Null> addNewPlace(@RequestParam Long id, @RequestBody NewPlaceDto newPlaceDto) {
        eventService.addNewPlace(id, newPlaceDto);
        return ResponseEntity.ok(null);
    }

}
