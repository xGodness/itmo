package common.movieclasses.enums;

import java.io.Serializable;
import java.util.Locale;

public enum HairColor implements Serializable {
    BLUE("Blue"),
    YELLOW("Yellow"),
    WHITE("White");

    private String label;

    HairColor(String hairColor) {
        this.label = hairColor;
    }

    public static HairColor valueOfLabel(String label) {
        for (HairColor e : values()) {
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
