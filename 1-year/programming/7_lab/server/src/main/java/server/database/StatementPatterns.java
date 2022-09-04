package server.database;

public enum StatementPatterns {
    CREATE_SEQUENCE(
            "CREATE SEQUENCE IF NOT EXISTS id_sequence START 1"
    ),
    GET_NEXT_ID(
            "SELECT nextval('id_sequence')"
    ),
    CREATE_USERS_TABLE(
            "CREATE TABLE IF NOT EXISTS users (" +
            "username VARCHAR(128) PRIMARY KEY, " +
            "password_hash VARCHAR(128) NOT NULL," +
            "salt VARCHAR(8) NOT NULL" +
            ")"
    ),
    CREATE_COLLECTION_TABLE(
      "CREATE TABLE IF NOT EXISTS collection (" +
              "movie_id BIGINT PRIMARY KEY, " +
              "movie_name VARCHAR(128) NOT NULL, " +
              "coordinate_x REAL NOT NULL, " +
              "coordinate_y REAL NOT NULL, " +
              "creation_date DATE NOT NULL, " +
              "oscars_count INT, " +
              "tagline VARCHAR(128), " +
              "movie_genre GENRE NOT NULL, " +
              "mpaa_rating MPAA NOT NULL, " +
              "screenwriter_name VARCHAR(128) NOT NULL, " +
              "screenwriter_birthday DATE, " +
              "screenwriter_eye_color EYECOLOR NOT NULL, " +
              "screenwriter_hair_color HAIRCOLOR NOT NULL, " +
              "screenwriter_nationality COUNTRY NOT NULL, " +
              "location_x INT NOT NULL, " +
              "location_y REAL NOT NULL, " +
              "location_name VARCHAR(128) NOT NULL, " +
              "owner_username VARCHAR(128) NOT NULL " +
              ")"
    ),
    ADD_MOVIE(
            "INSERT INTO collection(" +
                    "movie_name, " +
                    "coordinate_x, " +
                    "coordinate_y, " +
                    "creation_date, " +
                    "oscars_count, " +
                    "tagline, " +
                    "movie_genre, " +
                    "mpaa_rating, " +
                    "screenwriter_name, " +
                    "screenwriter_birthday, " +
                    "screenwriter_eye_color, " +
                    "screenwriter_hair_color, " +
                    "screenwriter_nationality, " +
                    "location_x, " +
                    "location_y, " +
                    "location_name, " +
                    "owner_username, " +
                    "movie_id" +
                    ") " +
                    "VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )"
    ),
    UPDATE_MOVIE(
            "UPDATE collection " +
                    "SET movie_name = ?," +
                        "coordinate_x = ?, " +
                        "coordinate_y = ?, " +
                        "creation_date = ?, " +
                        "oscars_count = ?, " +
                        "tagline = ?, " +
                        "movie_genre = ?, " +
                        "mpaa_rating = ?, " +
                        "screenwriter_name = ?, " +
                        "screenwriter_birthday = ?, " +
                        "screenwriter_eye_color = ?, " +
                        "screenwriter_hair_color = ?, " +
                        "screenwriter_nationality = ?, " +
                        "location_x = ?, " +
                        "location_y = ?, " +
                        "location_name = ?" +
                    "WHERE movie_id = ? AND owner_username = ?"
    ),
    REMOVE_BY_ID(
            "DELETE FROM collection WHERE movie_id = ? AND owner_username = ?"
    ),
    REMOVE_ALL_BY_OWNER(
            "DELETE FROM collection WHERE owner_username = ?"
    ),
    GET_ALL_BY_OWNER(
            "SELECT * FROM collection WHERE owner_username = ?"
    ),
    GET_MOVIE_BY_ID(
            "SELECT * FROM collection WHERE movie_id = ?"
    );



    private final String sqlString;

    StatementPatterns(String sqlString) {
        this.sqlString = sqlString;
    }

    public static String toSQLString(StatementPatterns pattern) {
        return pattern.sqlString;
    }

}
