package lab5.movie_classes.enums;

public enum MovieGenre {
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

    @Override
    public String toString() {
        return label;
    }

}
