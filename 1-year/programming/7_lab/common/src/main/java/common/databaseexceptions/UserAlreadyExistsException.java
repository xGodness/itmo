package common.databaseexceptions;

public class UserAlreadyExistsException extends DatabaseException {
    public UserAlreadyExistsException(String message) {
        super(message);
    }
}
