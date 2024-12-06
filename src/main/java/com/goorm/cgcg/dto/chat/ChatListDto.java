package com.goorm.cgcg.dto.chat;

import java.time.LocalDateTime;
import java.util.List;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

public class ChatListDto {

    @Builder
    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    @AllArgsConstructor(access = AccessLevel.PRIVATE)
    public static class ChatMessageListDto {
        List<ChatMessageDto> messages;
    }

    @Builder
    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    @AllArgsConstructor(access = AccessLevel.PRIVATE)
    public static class ChatMessageDto {
        private Long senderId;
        private String nickname;
        private String profileImage;
        private LocalDateTime time;
        private String message;
        private String file;
    }

}
