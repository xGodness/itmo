package com.xgodness.model;

import lombok.Data;

@Data
public class Point {
    private Integer id;
    private double x;
    private double y;
    private double r;
    private boolean hit;
    private int dateTimeOffset;

    public Point(Integer id, double x, double y, double r, boolean hit, int dateTimeOffset) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.r = r;
        this.hit = hit;
        this.dateTimeOffset = dateTimeOffset;
    }

}
