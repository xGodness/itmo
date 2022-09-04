package server.database;

import common.movieclasses.*;
import common.movieclasses.enums.*;
import common.databaseexceptions.DatabaseException;
import org.postgresql.ds.PGSimpleDataSource;
//import org.postgresql.Driver;
//import org.postgresql.ds.PGSimpleDataSource;


import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedList;

public class DBManager {
    private final Connection connection;
    private final StatementInvoker statementInvoker;

    public DBManager(String host, String username, String password) throws SQLException {
        if (host.equals("jdbc:postgresql://pg:5432/studs")) {
            connection = DriverManager.getConnection(host, username, password);
        } else {
            try {
                Class.forName("java.sql.DriverManager");
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                System.exit(-1);
            }
            connection = DriverManager.getConnection(host, username, password);
//            PGSimpleDataSource pgDataSource = new PGSimpleDataSource();
//            pgDataSource.setServerNames(new String[] {host});
//            pgDataSource.setUser(username);
//            pgDataSource.setPassword(password);
//            connection = pgDataSource.getConnection();
        }
        statementInvoker = new StatementInvoker(connection);
        statementInvoker.initializeUsersTable();
        statementInvoker.initializeEnums();
        statementInvoker.initializeCollectionTable();
        statementInvoker.initializeSequence();
    }

    public void register(String username, String password) throws SQLException, DatabaseException {
        statementInvoker.registerUser(username, password);
    }

    public void login(String username, String password) throws SQLException, DatabaseException {
        statementInvoker.loginUser(username, password);
    }

    public Movie add(Movie movie, String username) throws SQLException {
        ResultSet idResult = connection.createStatement().executeQuery(StatementPatterns.toSQLString(StatementPatterns.GET_NEXT_ID));
        idResult.next();
        long id = idResult.getLong("nextval");
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.ADD_MOVIE));
        setUpMovieToStatement(statement, movie);
        statement.setString(17, username);
        statement.setLong(18, id);
        statement.executeUpdate();
        movie.setId(id);
        return movie;
    }

    public void update(Movie movie, Long id, String username) throws SQLException, DatabaseException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.UPDATE_MOVIE));
        setUpMovieToStatement(statement, movie);
        statement.setLong(17, id);
        statement.setString(18, username);
        if (statement.executeUpdate() == 0) {
            throw new DatabaseException("Movie with id " + id + " does not exist or is owned by another user");
        }
    }

    private void setUpMovieToStatement(PreparedStatement statement, Movie movie) throws SQLException {
        statement.setString(1, movie.getName());
        statement.setDouble(2, movie.getCoordinates().getX());
        statement.setFloat(3, movie.getCoordinates().getY());
        statement.setDate(4, Date.valueOf(movie.getCreationDate().toLocalDate()));
        Integer oscarsCount = movie.getOscarsCount();
        if (oscarsCount != null) {
            statement.setInt(5, movie.getOscarsCount());
        } else {
            statement.setNull(5, Types.NULL);
        }
        statement.setString(6, movie.getTagline());
        statement.setObject(7, movie.getGenre().getLabelAsEnumType(), Types.OTHER);
        statement.setObject(8, movie.getMpaaRating().getLabelAsEnumType(), Types.OTHER);
        statement.setString(9, movie.getScreenwriter().getName());
        LocalDate birthday = movie.getScreenwriter().getBirthday();
        statement.setObject(10, ( birthday == null ? null : Date.valueOf(movie.getScreenwriter().getBirthday()) ), Types.DATE);
        statement.setObject(11, movie.getScreenwriter().getEyeColor().getLabelAsEnumType(), Types.OTHER);
        statement.setObject(12, movie.getScreenwriter().getHairColor().getLabelAsEnumType(), Types.OTHER);
        statement.setObject(13, movie.getScreenwriter().getNationality().getLabelAsEnumType(), Types.OTHER);
        statement.setInt(14, movie.getScreenwriter().getLocation().getX());
        statement.setDouble(15, movie.getScreenwriter().getLocation().getY());
        statement.setString(16, movie.getScreenwriter().getLocation().getName());
    }

    public void remove(Long id, String username) throws DatabaseException, SQLException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.REMOVE_BY_ID));
        statement.setLong(1, id);
        statement.setString(2, username);
        if (statement.executeUpdate() == 0) {
            throw new DatabaseException("Movie with id " + id + " does not exist or is owned by another user");
        }
    }

    public void clear(String username) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.REMOVE_ALL_BY_OWNER));
        statement.setString(1, username);
        statement.executeUpdate();
    }

    public Movie removeHead(String username) throws SQLException, DatabaseException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.GET_ALL_BY_OWNER));
        statement.setString(1, username);
        ResultSet result = statement.executeQuery();
        Movie movie = getNextMovie(result);
        if (movie == null) {
            throw new DatabaseException("There is no movies owned by user \"" + username + "\"");
        }
        statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.REMOVE_BY_ID));
        statement.setLong(1, movie.getId());
        statement.setString(2, username);
        statement.executeUpdate();
        return movie;
    }

    public int removeLower(Movie movie, String username) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.GET_ALL_BY_OWNER));
        statement.setString(1, username);
        PreparedStatement removeStatement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.REMOVE_BY_ID));
        ResultSet result = statement.executeQuery();
        int removedCount = 0;
        Movie iterMovie = getNextMovie(result);
        while (iterMovie != null) {
            if (iterMovie.compareTo(movie) < 0) {
                removeStatement.setLong(1, iterMovie.getId());
                removeStatement.executeUpdate();
                removedCount++;
            }
            iterMovie = getNextMovie(result);
        }
        return removedCount;
    }

    public LinkedList<Movie> getCollection() throws SQLException {
        LinkedList<Movie> collection = new LinkedList<>();
        ResultSet rows = connection.createStatement().executeQuery("SELECT * FROM collection");
        Movie movie;
        while (true) {
            movie = getNextMovie(rows);
            if (movie == null) {
                break;
            }
            collection.add(movie);
        }
        return collection;
    }

    private void checkMovieById(Long id) throws SQLException, DatabaseException {
        PreparedStatement statement = connection.prepareStatement(StatementPatterns.toSQLString(StatementPatterns.GET_MOVIE_BY_ID));
        statement.setLong(1, id);
        ResultSet result = statement.executeQuery();
        if (!result.next()) {
            throw new DatabaseException("Movie with id " + id + " does not exist");
        }
    }

    private Movie getNextMovie(ResultSet rows) throws SQLException {
        if (!rows.next()) {
            return null;
        }
        Long id = rows.getLong("movie_id");
        String movieName = rows.getString("movie_name");
        Double coordinateX = rows.getDouble("coordinate_x");
        Float coordinateY = rows.getFloat("coordinate_y");
        LocalDateTime creationDate = rows.getDate("creation_date").toLocalDate().atStartOfDay(); //TODO: time stamp
        Integer oscarsCount = rows.getInt("oscars_count");
        String tagline = rows.getString("tagline");
        MovieGenre movieGenre = MovieGenre.valueOfLabel(rows.getString("movie_genre"));
        MpaaRating mpaaRating = MpaaRating.valueOfLabel(rows.getString("mpaa_rating"));
        String screenwriterName = rows.getString("screenwriter_name");
        String birthday = rows.getString("screenwriter_birthday");
        LocalDate screenwriterBirthday = birthday == null ? null : LocalDate.parse(birthday);
        EyeColor screenwriterEyeColor = EyeColor.valueOfLabel(rows.getString("screenwriter_eye_color"));
        HairColor screenwriterHairColor = HairColor.valueOfLabel(rows.getString("screenwriter_hair_color"));
        Country screenwriterNationality = Country.valueOfLabel(rows.getString("screenwriter_nationality"));
        Integer locationX = rows.getInt("location_x");
        Double locationY = rows.getDouble("location_y");
        String locationName = rows.getString("location_name");
        String ownerUsername = rows.getString("owner_username");

        Movie movie = new Movie(
                movieName,
                new Coordinates(coordinateX, coordinateY),
                creationDate,
                oscarsCount,
                tagline,
                movieGenre,
                mpaaRating,
                new Person(
                        screenwriterName,
                        screenwriterBirthday,
                        screenwriterEyeColor,
                        screenwriterHairColor,
                        screenwriterNationality,
                        new Location(
                                locationX,
                                locationY,
                                locationName
                        )
                ),
                ownerUsername
        );
        movie.setId(id);
        return movie;
    }

    public void close() throws SQLException {
        connection.close();
    }

}
