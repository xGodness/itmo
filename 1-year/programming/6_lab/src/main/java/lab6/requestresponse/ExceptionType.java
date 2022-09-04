package lab6.requestresponse;

import java.io.Serializable;

public enum ExceptionType implements Serializable {
    NO_EXCEPTION("No exception"),
    FILE_NOT_FOUND("File not found"),
    PERMISSION_DENIED("Permission denied"),
    INVALID_FILE_NAME("Invalid file name"),
    FILE_ALREADY_EXISTS("File already exists"),
    CANNOT_CREATE_FILE("Cannot create file"),
    EXECUTE_COMMAND_EXCEPTION("Execute command exception");

    private String label;

    ExceptionType(String exceptionType) {
        label = exceptionType;
    }

    public static ExceptionType valueOfLabel(String label) {
        for (ExceptionType e : values()) {
            if (e.label.equalsIgnoreCase(label)) {
                return e;
            }
        }
        return null;
    }

    @Override
    public String toString() {
        return label;
    }

}
