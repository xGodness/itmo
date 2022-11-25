package com.xgodness.data;

import com.xgodness.model.Point;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;

import static com.xgodness.data.StatementPattern.*;
import static com.xgodness.data.StatementPattern.toSQLString;

@Component("")
public class PointsRepositoryImpl implements PointRepository {

    @Value("${spring.datasource.url}")
    private String url;

    @Value("${spring.datasource.username}")
    private String username;

    @Value("${spring.datasource.password}")
    private String password;

    private Connection connection;
    private PreparedStatement statement;
    private boolean isInitialized = false;

    public PointsRepositoryImpl() { }

    public void init() throws SQLException {
        this.connection = DBManager.getConnection(url, username, password);

        for (StatementPattern pattern : new StatementPattern[] {
                CREATE_SEQUENCE,
                CREATE_POINTS_TABLE
        }) {
            connection.createStatement().executeUpdate(toSQLString(pattern));
        }

        isInitialized = true;
    }

    public boolean save(Point point) throws SQLException {
        if (!isInitialized) return false;
        if (point.getId() == null) {
            ResultSet resultSet = connection.createStatement().executeQuery(toSQLString(GET_NEXT_ID));
            resultSet.next();
            point.setId(resultSet.getInt("nextval"));
        }
        statement = connection.prepareStatement(toSQLString(SAVE_POINT));
        statement.setDouble(1, point.getX());
        statement.setDouble(2, point.getY());
        statement.setDouble(3, point.getR());
        statement.setBoolean(4, point.isHit());
        statement.setInt(5, point.getDateTimeOffset());
        statement.setInt(6, point.getId());

        statement.executeUpdate();
        return true;
    }

    public boolean clear() throws SQLException {
        if (!isInitialized) return false;
        connection.createStatement().executeUpdate(toSQLString(CLEAR_TABLE));
        return true;
    }

    public List<Point> findAll() throws SQLException {
        if (!isInitialized) return null;
        ResultSet rows = connection.createStatement().executeQuery(toSQLString(FIND_ALL));

        Point point = nextPoint(rows);
        List<Point> pointList = new LinkedList<>();

        while (point != null) {
            pointList.add(point);
            point = nextPoint(rows);
        }

        return pointList;
    }


    private Point nextPoint(ResultSet rows) throws SQLException {
        if (!rows.next()) {
            return null;
        }

        return new Point(
                rows.getInt("id"),
                rows.getDouble("x"),
                rows.getDouble("y"),
                rows.getDouble("r"),
                rows.getBoolean("hit"),
                rows.getInt("date_time_offset")
        );
    }
}
