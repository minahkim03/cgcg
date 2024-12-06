package com.goorm.cgcg.repository;

import com.goorm.cgcg.domain.Chat;
import java.util.List;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatRepository extends MongoRepository<Chat, String> {
    List<Chat> findAllByRoomIdOrderByCreateTime(String chatRoomId);
}
