package com.goorm.cgcg.config;

import com.goorm.cgcg.domain.Chat;
import com.goorm.cgcg.dto.chat.ChatDto;
import com.goorm.cgcg.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler {

    private final ChatService chatService;

    @MessageMapping("/chat/{chatRoomId}")
    @SendTo("/room/chat/{chatRoomId}")
    public Chat sendMessage(@DestinationVariable String chatRoomId, ChatDto chat) {
        return chatService.saveMessage(chatRoomId, chat);
    }

}
