package com.goorm.cgcg.converter;

import com.goorm.cgcg.domain.Chat;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.chat.ChatDto;
import java.time.LocalDateTime;
import org.springframework.stereotype.Component;

@Component
public class ChatConverter {

    public Chat convertToEntity(ChatDto chatDto, Member sender, String roomId) {

        return Chat.builder()
            .createTime(LocalDateTime.now())
            .fileUrl(chatDto.getFile())
            .senderId(sender.getId())
            .sender(sender.getNickname())
            .message(chatDto.getMessage())
            .roomId(roomId)
            .senderProfile(sender.getProfileImage())
            .build();
    }

}
