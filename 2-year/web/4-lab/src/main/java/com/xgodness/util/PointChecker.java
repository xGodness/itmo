package com.xgodness.util;

import com.xgodness.entity.Point;
import org.springframework.stereotype.Component;

@Component
public class PointChecker {

    public void checkAndSetHit(Point point) {
        point.setHit(checkHit(point));
    }


    private boolean checkHit(Point point) {
        double x = point.getX();
        double y = point.getY();
        double r = point.getR();

        if (x == 0) return Math.abs(y) <= r;

        if (y == 0) return Math.abs(x) <= r;

        if (y > 0) {
            if (x < 0) return false;
            return (y <= r - x);
        }

        if (x < 0) {
            return x >= -r && y >= -r;
        }
        return Math.pow(x, 2) + Math.pow(y, 2) <= Math.pow(r, 2);
    }
}
