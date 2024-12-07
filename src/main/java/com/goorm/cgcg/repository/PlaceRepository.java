package com.goorm.cgcg.repository;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.domain.Place;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaceRepository extends JpaRepository<Place, Long> {

    List<Place> findAllByEventOrderByTime(Event event);

}
