package server.database;

import common.databaseexceptions.IncorrectPasswordException;
import common.databaseexceptions.UserAlreadyExistsException;
import common.databaseexceptions.UserNotFoundException;
import javax.validation.constraints.NotNull;
import common.databaseexceptions.DatabaseException;

import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StatementInvoker {
    private Connection connection;
    private PreparedStatement checkUserStatement;
    private PreparedStatement registerUserStatement;

    public StatementInvoker(@NotNull Connection connection) throws SQLException {
        this.connection = connection;
        checkUserStatement = connection.prepareStatement("SELECT * from users WHERE username = ?");
        registerUserStatement = connection.prepareStatement("INSERT INTO users VALUES (?, ?, ?)");
    }

     /*________________________________________________________________________________________________________________
                                                     Setup methods
    ________________________________________________________________________________________________________________*/

    public void initializeUsersTable() throws SQLException {
        connection.createStatement().executeUpdate(StatementPatterns.toSQLString(StatementPatterns.CREATE_USERS_TABLE));
    }

    public void initializeCollectionTable() throws SQLException {
        connection.createStatement().executeUpdate(StatementPatterns.toSQLString(StatementPatterns.CREATE_COLLECTION_TABLE));
    }

    public void initializeSequence() throws SQLException {
        connection.createStatement().executeUpdate(StatementPatterns.toSQLString(StatementPatterns.CREATE_SEQUENCE));
    }

    public boolean initializeEnums() {
        try {
            connection.createStatement().executeUpdate(
                    "CREATE TYPE GENRE AS ENUM ('action', 'western', 'drama', 'musical', 'sci-fi')");
            connection.createStatement().executeUpdate(
                    "CREATE TYPE MPAA AS ENUM ('pg', 'pg-13', 'r')");
            connection.createStatement().executeUpdate(
                    "CREATE TYPE COUNTRY AS ENUM ('uk', 'usa', 'vatican', 'south korea', 'north korea')");
            connection.createStatement().executeUpdate(
                    "CREATE TYPE EYECOLOR AS ENUM ('green', 'red', 'white', 'brown')");
            connection.createStatement().executeUpdate(
                    "CREATE TYPE HAIRCOLOR AS ENUM ('blue', 'yellow', 'white')");
            return true;
        } catch (SQLException e) {
            return false;
        }

    }

     /*________________________________________________________________________________________________________________
                                             Register or login methods
    ________________________________________________________________________________________________________________*/

    public boolean registerUser(String username, String password) throws DatabaseException, SQLException {
        if (checkUsernamePresence(username)) {
            throw new UserAlreadyExistsException("User with such name already exists");
        }
        String salt = SaltGenerator.generateSalt();
        String passwordHash;
        try {
            passwordHash = Encryptor.encrypt(password + salt);
        } catch (NoSuchAlgorithmException e) {
            throw new DatabaseException("Error during encrypting process");
        }
        registerUserStatement.setString(1, username);
        registerUserStatement.setString(2, passwordHash);
        registerUserStatement.setString(3, salt);
        return registerUserStatement.executeUpdate() == 1;
    }

    public void loginUser(String username, String password) throws DatabaseException, SQLException {
        checkUserStatement.setString(1, username);
        ResultSet sqlResult = checkUserStatement.executeQuery();
        boolean passwordIsCorrect;
        if (sqlResult.next()) {
            String passwordHash = sqlResult.getString("password_hash");
            String userSalt = sqlResult.getString("salt");
            try {
                String providedPasswordHash = Encryptor.encrypt(password + userSalt);
                passwordIsCorrect = providedPasswordHash.equals(passwordHash);

            } catch (NoSuchAlgorithmException e) {
                throw new DatabaseException("Error during encrypting process");
            }
            if (!passwordIsCorrect) {
                throw new IncorrectPasswordException("Authentication failed");
            }
        } else {
            throw new UserNotFoundException("User with name '" + username + "' does not exist");
        }
    }

    /*________________________________________________________________________________________________________________
                                                Auxiliary methods
    ________________________________________________________________________________________________________________*/

    private boolean checkUsernamePresence(String username) throws SQLException {
        checkUserStatement.setString(1, username);
        return checkUserStatement.executeQuery().next();
    }

}
