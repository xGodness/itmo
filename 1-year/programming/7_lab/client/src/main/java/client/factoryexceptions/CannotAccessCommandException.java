package client.factoryexceptions;

public class CannotAccessCommandException extends FactoryException {
    public CannotAccessCommandException(String message) {
        super(message);
    }
}
