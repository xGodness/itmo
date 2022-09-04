package common.requestresponse;

import java.io.Serializable;

public enum ExceptionType implements Serializable {
    NO_EXCEPTION("No exception"),
    PERMISSION_DENIED("Permission denied"),
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
