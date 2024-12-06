package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.event.EventPageDto.EventDto;
import com.goorm.cgcg.dto.event.NewEventDto;
import com.goorm.cgcg.dto.event.NewPlaceDto;
import com.goorm.cgcg.service.EventService;
import com.goorm.cgcg.service.FileUploadService;
import jakarta.validation.constraints.Null;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;
    private final FileUploadService fileUploadService;

    @GetMapping("/event")
    public ResponseEntity<EventDto> getEventPage(@RequestParam Long id) {
        EventDto eventPage = eventService.getEventPage(id);
        return ResponseEntity.ok(eventPage);
    }

    @PostMapping("/event/add")
    public ResponseEntity<Long> addNewPlace(@RequestParam Long id, @RequestBody NewPlaceDto newPlaceDto) {
        return ResponseEntity.ok(eventService.addNewPlace(id, newPlaceDto));
    }

    @PostMapping("/event/new")
    public ResponseEntity<Long> newEvent(@RequestParam Long id, @RequestBody NewEventDto newEventDto) {
        return ResponseEntity.ok(eventService.addNewEvent(id, newEventDto));
    }

    @PostMapping("/event/new/image")
    public ResponseEntity<String> uploadEventImage(@RequestParam("file") MultipartFile file) throws IOException {
        String url = fileUploadService.uploadFile(file);
        return ResponseEntity.ok(url);
    }

}
