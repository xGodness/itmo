package com.xgodness.service;

import com.xgodness.entity.Point;
import com.xgodness.model.PointDTO;
import com.xgodness.repository.PointRepository;
import com.xgodness.repository.UserRepository;
import com.xgodness.util.PointChecker;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@Transactional
public class PointManager {

    private final PointRepository pointRepo;
    private final UserRepository userRepo;
    private final PointChecker pointChecker;

    public PointManager(PointRepository pointRepo, UserRepository userRepo, PointChecker pointChecker) {
        this.pointRepo = pointRepo;
        this.userRepo = userRepo;
        this.pointChecker = pointChecker;
    }

    public Point addPoint(PointDTO pointDTO, String username, LocalDateTime startTime) {
        Point point = new Point(pointDTO.getX(), pointDTO.getY(), pointDTO.getR());
        pointChecker.checkAndSetHit(point);
        point.setUser(
                userRepo.findByUsername(username)
        );

        point.setExecutionTime(
                LocalDateTime.now(ZoneOffset.UTC).minusNanos(startTime.getNano()).getNano()
        );

        point.setCurTime(
                LocalDateTime.now(ZoneOffset.UTC).minusMinutes(pointDTO.getZoneOffset())
                        .format(DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"))
        );

        pointRepo.save(point);
        return point;
    }

    public List<Point> getPoints() {
        List<Point> pointList = new ArrayList<>();
        pointRepo.findAll().forEach(pointList::add);
        Collections.reverse(pointList);
        return pointList;
    }

    public void deleteAll(String username) {
        pointRepo.deleteAllByUser_Username(username);
    }

}
