package com.goorm.cgcg.domain;

import jakarta.persistence.Id;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.redis.core.index.Indexed;

@Document(collection = "chat")
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PROTECTED)
public class Chat {

    @Id
    private String id;

    private String sender;

    private Long senderId;

    private String roomId;

    private String message;

    private String fileUrl;

    @Indexed
    private LocalDateTime createTime;

    private String senderProfile;
}
