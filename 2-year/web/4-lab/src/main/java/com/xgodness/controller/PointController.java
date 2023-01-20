package com.xgodness.controller;

import com.xgodness.entity.Point;
import com.xgodness.model.PointDTO;
import com.xgodness.service.PointManager;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/points")
public class PointController {

    private final PointManager manager;

    public PointController(PointManager manager) {
        this.manager = manager;
    }

    @PostMapping
    public Point addPoint(@RequestBody PointDTO pointDTO,
                          @RequestAttribute String username,
                          @RequestAttribute LocalDateTime startTime) {
        return manager.addPoint(pointDTO, username, startTime);
    }

    @GetMapping
    public List<Point> getPoints() {
        return manager.getPoints();
    }

    @DeleteMapping
    public void deleteAll(@RequestAttribute String username) {
        manager.deleteAll(username);
    }

}
