package com.goorm.cgcg.repository;

import com.goorm.cgcg.domain.ChatRoom;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ChatRoomRepository extends MongoRepository<ChatRoom, String> {

    Optional<ChatRoom> findByEventId(Long eventId);

}
