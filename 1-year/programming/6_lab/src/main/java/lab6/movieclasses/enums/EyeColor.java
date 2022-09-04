package lab6.movieclasses.enums;

import java.io.Serializable;

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

    @Override
    public String toString() {
        return label;
    }

}
