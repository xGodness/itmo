package common.movieclasses.enums;

import java.io.Serializable;
import java.util.Locale;

public enum Country implements Serializable {
    UNITED_KINGDOM("UK"),
    USA("USA"),
    VATICAN("Vatican"),
    SOUTH_KOREA("South Korea"),
    NORTH_KOREA("North Korea");

    private String label;

    Country(String country) {
        label = country;
    }

    public static Country valueOfLabel(String label) {
        for (Country e : values()) {
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
