package com.goorm.cgcg.service;

import com.goorm.cgcg.converter.ChatConverter;
import com.goorm.cgcg.domain.Chat;
import com.goorm.cgcg.domain.ChatRoom;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.dto.chat.ChatDto;
import com.goorm.cgcg.dto.chat.ChatListDto.ChatMessageDto;
import com.goorm.cgcg.dto.chat.ChatListDto.ChatMessageListDto;
import com.goorm.cgcg.repository.ChatRepository;
import com.goorm.cgcg.repository.ChatRoomRepository;
import com.goorm.cgcg.repository.MemberEventRepository;
import com.goorm.cgcg.repository.MemberRepository;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@Transactional
@RequiredArgsConstructor
public class ChatService {

    private final ChatRepository chatRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final MemberEventRepository memberEventRepository;
    private final ChatConverter chatConverter;
    private final MemberRepository memberRepository;

    public String getChatRoom(Long eventId) {
        ChatRoom room =  chatRoomRepository.findByEventId(eventId)
            .orElseGet(() -> {
                List<Member> members = memberEventRepository.findMembersByEventId(eventId);
                ChatRoom chatRoom = ChatRoom.builder()
                    .eventId(eventId)
                    .memberIds(members.stream()
                        .map(Member::getId)
                        .collect(Collectors.toList())
                    )
                    .build();
                return chatRoomRepository.save(chatRoom);
            });
        return room.getId();
    }

    public ChatMessageListDto getChatMessageList(String chatRoomId) {
        List<Chat> chatList = chatRepository.findAllByRoomIdOrderByCreateTime(chatRoomId);
        List<ChatMessageDto> chatMessages = new ArrayList<>();
        for (Chat chat : chatList) {
            chatMessages.add(ChatMessageDto.builder()
                    .file(chat.getFileUrl())
                    .message(chat.getMessage())
                    .nickname(chat.getSender())
                    .profileImage(chat.getSender())
                    .senderId(chat.getSenderId())
                    .time(chat.getCreateTime())
                .build());
        }
        return ChatMessageListDto.builder()
            .messages(chatMessages)
            .build();
    }

    public Chat saveMessage(String chatRoomId, ChatDto chatDto) {
        Member member = memberRepository.findById(chatDto.getSenderId()).orElseThrow();
        Chat chat = chatConverter.convertToEntity(chatDto, member, chatRoomId);
        return chatRepository.save(chat);
    }

}
