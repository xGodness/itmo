package lab6.exceptions.factoryexceptions;

public class CommandNotFoundException extends FactoryException {
    public CommandNotFoundException(String message) {
        super(message);
    }
}
