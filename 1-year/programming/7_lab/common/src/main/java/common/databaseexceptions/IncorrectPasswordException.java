package common.databaseexceptions;

public class IncorrectPasswordException extends DatabaseException {
    public IncorrectPasswordException(String message) {
        super(message);
    }
}
