package com.xgodness.data;

import com.xgodness.model.Point;

import java.sql.SQLException;
import java.util.List;

public interface PointRepository {
    void save(Point point) throws SQLException;
    List<Point> findAll() throws SQLException;
    void clear() throws SQLException;
}
