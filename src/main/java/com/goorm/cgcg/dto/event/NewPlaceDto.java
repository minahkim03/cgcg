package com.goorm.cgcg.dto.event;

import java.time.LocalTime;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Builder
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PROTECTED)
public class NewPlaceDto {

    private Float latitude;
    private Float longitude;
    private String name;
    private LocalTime time;

}
