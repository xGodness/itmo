package lab6.exceptions.factoryexceptions;

public class CannotAccessCommandException extends FactoryException {
    public CannotAccessCommandException(String message) {
        super(message);
    }
}
