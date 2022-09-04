package client.factoryexceptions;

public class CommandNotFoundException extends FactoryException {
    public CommandNotFoundException(String message) {
        super(message);
    }
}
