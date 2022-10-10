package com.xgodness.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class ResultRow {
    private float x;
    private float y;
    private float r;
    private boolean hit;
    private String time;

    public ResultRow() {}

    public ResultRow(float x, float y, float r, boolean hit, String time) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.hit = hit;
        this.time = time;
    }

    public float getX() {
        return x;
    }

    public float getY() {
        return y;
    }

    public float getR() {
        return r;
    }

    public boolean isHit() {
        return hit;
    }

    public String getTime() {
        return time;
    }

    @JsonIgnore
    public String getHitAsString() {
        return hit ? "Hit" : "Miss";
    }

    @Override
    public String toString() {
        return "ResultRow{" +
                "x=" + x +
                ", y=" + y +
                ", r=" + r +
                ", hit=" + hit +
                ", time='" + time + '\'' +
                '}';
    }
}
