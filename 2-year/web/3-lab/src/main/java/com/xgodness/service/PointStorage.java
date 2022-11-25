package com.xgodness.service;

import com.xgodness.data.PointsRepositoryImpl;
import com.xgodness.model.Point;
import org.ocpsoft.rewrite.el.ELBeanName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.enterprise.context.SessionScoped;
import javax.inject.Named;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Component(value = "pointStorage")
@Named("pointStorage")
@SessionScoped
@ELBeanName(value = "pointStorage")
public class PointStorage implements Serializable {
    @Autowired
    private PointsRepositoryImpl repository;
    private final List<Integer> valuesX = Arrays.asList(-4, -3, -2, -1, 0, 1, 2, 3, 4);

    private List<Point> pointList;
    private Point point;

    @PostConstruct
    public void init() throws SQLException {
        repository.init();
        point = new Point(null, 0, 0, 1, true, 0);
        syncData();
    }

    private void syncData() throws SQLException {
        List<Point> fromDB = repository.findAll();
        if (fromDB == null) {
            System.out.println("data from db is null");
            if (pointList == null) pointList = new ArrayList<>();
        }
        else pointList = fromDB;
        Collections.reverse(pointList);
    }

    public void add() throws SQLException {
        System.out.println(point.toString());
        repository.save(point);
        point.setId(null);
        syncData();
    }

    public void clear() throws SQLException {
        repository.clear();
        syncData();
    }

    public List<Integer> getValuesX() {
        return valuesX;
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
}
