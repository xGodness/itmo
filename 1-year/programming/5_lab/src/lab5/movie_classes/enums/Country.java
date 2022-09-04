package lab5.movie_classes.enums;

public enum Country {
    UNITED_KINGDOM("UK"),
    USA("USA"),
    VATICAN("Vatican"),
    SOUTH_KOREA("South Korea"),
    NORTH_KOREA("North Korea");

    private String label;

    Country(String country) {
        this.label = country;
    }

    public static Country valueOfLabel(String label) {
        for (Country e : values()) {
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
