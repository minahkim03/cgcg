package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.chat.ChatListDto.ChatMessageListDto;
import com.goorm.cgcg.service.ChatService;
import com.goorm.cgcg.service.FileUploadService;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final FileUploadService fileUploadService;

    @PostMapping("/chat/room")
    public ResponseEntity<String> getChatRoom(@RequestParam Long event) {
        return ResponseEntity.ok(chatService.getChatRoom(event));
    }

    @GetMapping("/chat/messages")
    public ResponseEntity<ChatMessageListDto> getChatMessages(@RequestParam String id) {
        ChatMessageListDto chatMessageList = chatService.getChatMessageList(id);
        return ResponseEntity.ok(chatMessageList);
    }

    @PostMapping("/chat/image")
    public ResponseEntity<String> uploadChatImage(@RequestParam("file") MultipartFile file) throws IOException {
        String url = fileUploadService.uploadFile(file);
        return ResponseEntity.ok(url);
    }
}
