package com.xgodness.repository;

import com.xgodness.entity.Point;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PointRepository extends CrudRepository<Point, Long> {
    void deleteAllByUser_Username(String username);
}
