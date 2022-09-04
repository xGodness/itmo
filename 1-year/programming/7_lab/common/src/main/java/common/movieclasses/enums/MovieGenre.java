package common.movieclasses.enums;

import java.io.Serializable;
import java.util.Locale;

public enum MovieGenre implements Serializable {
    ACTION("Action"),
    WESTERN("Western"),
    DRAMA("Drama"),
    MUSICAL("Musical"),
    SCIENCE_FICTION("Sci-Fi");

    private final String label;

    MovieGenre(String genre) {
        this.label = genre;
    }

    public static MovieGenre valueOfLabel(String label) {
        for (MovieGenre e : values()) {
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
