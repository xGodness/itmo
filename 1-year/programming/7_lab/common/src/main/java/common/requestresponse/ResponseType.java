package common.requestresponse;

import java.io.Serializable;

public enum ResponseType implements Serializable {
    SUCCESS("Success"),
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
