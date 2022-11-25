package com.xgodness.data;

public enum StatementPattern {
    CREATE_SEQUENCE(
            "CREATE SEQUENCE IF NOT EXISTS id_sequence START 1"
    ),
    GET_NEXT_ID(
            "SELECT nextval('id_sequence')"
    ),
    CREATE_POINTS_TABLE(
            "CREATE TABLE IF NOT EXISTS points (" +
            "id BIGINT PRIMARY KEY, " +
            "x REAL NOT NULL, " +
            "y REAL NOT NULL, " +
            "r REAL CHECK (r <= 4 AND r >= 1) NOT NULL, " +
            "hit BOOLEAN NOT NULL, " +
            "date_time_offset INTEGER NOT NULL" +
            ")"
    ),
    SAVE_POINT(
            "INSERT INTO points(" +
                    "x, " +
                    "y, " +
                    "r, " +
                    "hit, " +
                    "date_time_offset, " +
                    "id" +
                    ") " +
                    "VALUES( ?, ?, ?, ?, ?, ? )"
    ),
    FIND_ALL(
            "SELECT * FROM points"
    ),
    CLEAR_TABLE(
            "DELETE FROM points"
    );

    private final String pattern;

    StatementPattern(String pattern) {
        this.pattern = pattern;
    }

    public static String toSQLString(StatementPattern pattern) {
        return pattern.pattern;
    }
}
