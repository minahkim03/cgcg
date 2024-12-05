package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.invitation.InvitationDto.InvitationListDto;
import com.goorm.cgcg.service.InvitationService;
import jakarta.validation.constraints.Null;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class InvitationController {

    private final InvitationService invitationService;

    @GetMapping("/invitations")
    public ResponseEntity<InvitationListDto> getInvitations(@RequestParam Long id) {
        InvitationListDto invitationList = invitationService.getInvitationList(id);
        return ResponseEntity.ok(invitationList);
    }

    @PatchMapping("/invitations")
    public ResponseEntity<Null> respondInvitation(@RequestParam Long id, @RequestParam Boolean accept) {
        invitationService.respondToInvitation(id, accept);
        return ResponseEntity.ok(null);
    }
}

