package lab5.movie_classes.enums;

public enum HairColor {
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

    @Override
    public String toString() {
        return label;
    }

}
