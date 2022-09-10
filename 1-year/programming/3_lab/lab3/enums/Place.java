package lab3.enums;


public enum Place {
    ON_GROUND("На земле"),
    ON_BUSH("На кусте");

    private final String name;

    Place(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }
}
