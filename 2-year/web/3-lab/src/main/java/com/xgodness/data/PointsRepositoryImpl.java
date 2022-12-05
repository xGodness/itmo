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

@Component()
public class PointsRepositoryImpl implements PointRepository {

//    @Value("${spring.datasource.url}")
    private String url = "jdbc:postgresql://localhost:5432/postgres";

//    @Value("${spring.datasource.username}")
    private String username = "postgres";

//    @Value("${spring.datasource.password}")
    private String password = "gfhjkm";

    private Connection connection;
    private PreparedStatement statement;
    private boolean isInitialized = false;

    public PointsRepositoryImpl() { }

    public void init() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (Exception ex) {
            ex.printStackTrace();
            System.exit(-1);
        }

        this.connection = DBManager.getConnection(url, username, password);

        for (StatementPattern pattern : new StatementPattern[] {
                CREATE_SEQUENCE,
                CREATE_POINTS_TABLE
        }) {
            connection.createStatement().executeUpdate(toSQLString(pattern));
        }

        isInitialized = true;
    }

    public void save(Point point) throws SQLException {
        if (!isInitialized) return;
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
        statement.setString(5, point.getDateTime());
        statement.setInt(6, point.getId());

        statement.executeUpdate();
    }

    public void clear() throws SQLException {
        if (!isInitialized) return;
        connection.createStatement().executeUpdate(toSQLString(CLEAR_TABLE));
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
                rows.getString("date_time")
        );
    }
}
