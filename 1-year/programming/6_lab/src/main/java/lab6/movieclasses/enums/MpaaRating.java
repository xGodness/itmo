package lab6.movieclasses.enums;

import java.io.Serializable;

public enum MpaaRating implements Serializable {
    PG("PG"),
    PG_13("PG-13"),
    R("R");

    private final String label;

    MpaaRating(String mpaaRating) {
        this.label = mpaaRating;
    }

    public static MpaaRating valueOfLabel(String label) {
        for (MpaaRating e : values()) {
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
