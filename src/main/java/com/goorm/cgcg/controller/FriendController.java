package com.goorm.cgcg.controller;

import com.goorm.cgcg.dto.friend.FindFriendDto;
import com.goorm.cgcg.dto.friend.FriendListDto.FriendDto;
import com.goorm.cgcg.service.FriendService;
import jakarta.validation.constraints.Null;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @GetMapping("/friend/find")
    public ResponseEntity<FindFriendDto> findFriend(@RequestParam String code) {
        FindFriendDto friend = friendService.findFriend(code);
        return ResponseEntity.ok(friend);
    }

    @PatchMapping("/friend/add")
    public ResponseEntity<Null> addFriend(@RequestParam Long id, @RequestParam Long friend) {
        friendService.addFriend(id, friend);
        return ResponseEntity.ok(null);
    }

    @GetMapping("/friend")
    public ResponseEntity<FriendDto> getFriendList(@RequestParam Long id) {
        FriendDto friendList = friendService.getFriendList(id);
        System.out.println(friendList);
        return ResponseEntity.ok(friendList);
    }
}
