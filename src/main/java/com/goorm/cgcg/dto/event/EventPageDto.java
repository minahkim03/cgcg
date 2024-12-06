package com.goorm.cgcg.dto.event;

import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.domain.Place;
import java.time.LocalDate;
import java.util.List;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

public class EventPageDto {

    @Builder
    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    @AllArgsConstructor(access = AccessLevel.PRIVATE)
    public static class EventDto {
        private LocalDate date;
        private String title;
        private List<Place> places;
        private List<CustomMemberDto> members;
    }

    @Builder
    @Getter
    @NoArgsConstructor(access = AccessLevel.PROTECTED)
    @AllArgsConstructor(access = AccessLevel.PRIVATE)
    public static class CustomMemberDto {
        private Long id;
        private String nickname;
        private String profileImage;
    }

}
