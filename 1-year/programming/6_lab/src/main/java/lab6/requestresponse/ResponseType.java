package lab6.requestresponse;

import java.io.Serializable;

public enum ResponseType implements Serializable {
    SUCCESS("Success"),
    SUCCESS_AND_FILE_ALREADY_LOADED("Success and file already loaded"),
    ERROR("Error");

    private String label;

    ResponseType(String responseType) {
        label = responseType;
    }

    public static ResponseType valueOfLabel(String label) {
        for (ResponseType e : values()) {
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
