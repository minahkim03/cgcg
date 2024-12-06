package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.event.EventPageDto.EventDto;
import com.goorm.cgcg.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
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

}
