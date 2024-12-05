package com.goorm.cgcg.repository;

import com.goorm.cgcg.domain.Event;
import com.goorm.cgcg.domain.Member;
import com.goorm.cgcg.domain.MemberEvent;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberEventRepository extends JpaRepository<MemberEvent, Long> {
    @Query("SELECT me.event FROM MemberEvent me WHERE me.member.id = :memberId")
    List<Event> findEventsByMemberId(@Param("memberId") Long memberId);

    @Query("SELECT me.event FROM MemberEvent me WHERE me.event.id = :eventId")
    List<Member> findMembersByEventId(@Param("eventId") Long eventId);
}
