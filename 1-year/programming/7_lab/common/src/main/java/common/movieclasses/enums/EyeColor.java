package common.movieclasses.enums;

import java.io.Serializable;
import java.util.Locale;

public enum EyeColor implements Serializable {
    GREEN("Green"),
    RED("Red"),
    WHITE("White"),
    BROWN("Brown");

    private String label;

    EyeColor(String eyeColor) {
        this.label = eyeColor;
    }

    public static EyeColor valueOfLabel(String label) {
        for (EyeColor e : values()) {
            if (e.label.equalsIgnoreCase(label)) {
                return e;
            }
        }
        return null;
    }

    public String getLabelAsEnumType() {
        return label.toLowerCase(Locale.ROOT);
    }

    @Override
    public String toString() {
        return label;
    }

}
