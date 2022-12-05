package com.xgodness.service;

import com.xgodness.data.PointsRepositoryImpl;
import com.xgodness.model.Point;
import com.xgodness.util.DateTimeConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.enterprise.context.SessionScoped;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Component(value = "pointStorage")
@SessionScoped
public class PointStorage implements Serializable {
    @Autowired
    private PointsRepositoryImpl repository;

    private List<Point> pointList;
    private Point point;
    private Integer offset;

    @PostConstruct
    public void init() throws SQLException {
        point = new Point(null, 0, 0, 4, true, DateTimeConverter.getDateTimeFromOffset(null));
        repository.init();
        syncData();
    }

    private void syncData() throws SQLException {
        List<Point> fromDB = repository.findAll();
        if (fromDB == null) {
            System.out.println("[INFO] data from db is null");
            if (pointList == null) pointList = new ArrayList<>();
        }
        else pointList = fromDB;
        Collections.reverse(pointList);
    }

    public void add() throws SQLException {
        point.setDateTimeByOffset(offset);
        System.out.println(point);
        repository.save(point);

        point.setId(null);
        point.setX(Math.round(point.getX()));

        syncData();
    }

    public void clear() throws SQLException {
        repository.clear();
        syncData();
    }

    public List<Point> getPointList() {
        return pointList;
    }

    public Point getPoint() {
        return point;
    }

    public void setPoint(Point point) {
        this.point = point;
    }

    public Integer getOffset() {
        return offset;
    }

    public void setOffset(Integer offset) {
        this.offset = offset;
    }
}
