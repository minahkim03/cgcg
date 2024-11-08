package com.goorm.cgcg.config.token;

import java.util.Optional;
import org.springframework.data.repository.CrudRepository;

public interface TokenRedisRepository extends CrudRepository<TokenRedis, String> {

    Optional<TokenRedis> findByAccessToken(String accessToken);

}
