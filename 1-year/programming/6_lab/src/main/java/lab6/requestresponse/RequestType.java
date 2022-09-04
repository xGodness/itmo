package lab6.requestresponse;

import java.io.Serializable;

public enum RequestType implements Serializable {
    CONNECT("Connect"),
    LOAD("Load"),
    CREATE("Create"),
    EXECUTE_COMMAND("Execute command"),
    EXECUTE_SCRIPT("Execute script"),
    EXIT("Exit");

    private String label;

    RequestType(String requestType) {
        label = requestType;
    }

    public static RequestType valueOfLabel(String label) {
        for (RequestType e : values()) {
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
