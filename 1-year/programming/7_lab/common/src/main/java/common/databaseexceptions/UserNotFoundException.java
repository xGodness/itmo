package common.databaseexceptions;

public class UserNotFoundException extends DatabaseException {
    public UserNotFoundException(String message) {
        super(message);
    }
}
