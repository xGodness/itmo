package lab5.exceptions.factory_exceptions;

public class CommandNotFoundException extends FactoryException {
    public CommandNotFoundException(String message) {
        super(message);
    }
}
