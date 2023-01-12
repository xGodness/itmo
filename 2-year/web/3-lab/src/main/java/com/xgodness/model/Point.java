package com.xgodness.model;

import com.xgodness.util.DateTimeConverter;
import com.xgodness.util.NumberFormatter;
import lombok.Data;

@Data
public class Point {
    private Integer id;
    private double x;
    private double y;
    private double r;
    private boolean hit;
    private String dateTime;

    public Point(Integer id, double x, double y, double r, boolean hit, String dateTime) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.r = r;
        this.hit = hit;
        this.dateTime = dateTime;
    }

    public void setDateTimeByOffset(Integer offset) {
        this.dateTime = DateTimeConverter.getDateTimeFromOffset(offset);
    }

    public double getX() {
        return NumberFormatter.roundDoubleTwoDigits(x);
    }

    public double getY() {
        return NumberFormatter.roundDoubleTwoDigits(y);
    }

}
