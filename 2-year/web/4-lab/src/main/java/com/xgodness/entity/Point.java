package com.xgodness.entity;

import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.Positive;

@Data
@Entity
@Table(name = "points")
@NoArgsConstructor
public class Point {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private User user;

    @Min(value = -3)
    @Max(value = 5)
    private double x;

    @Min(-5)
    @Max(5)
    private double y;

    @Positive
    @Max(5)
    private double r;

    private Boolean hit;

    private String curTime;

    private long executionTime;

    public Point(double x, double y, double r) {
        this.x = x;
        this.y = y;
        this.r = r;
//        this.hit = false;
    }

}
