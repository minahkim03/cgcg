package com.goorm.cgcg.repository;

import com.goorm.cgcg.domain.Invitation;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InvitationRepository extends JpaRepository<Invitation, Long> {

    Optional<Invitation> findById(Long invitationId);
}
