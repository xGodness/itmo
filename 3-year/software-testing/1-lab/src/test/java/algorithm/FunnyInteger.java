package algorithm;

public class FunnyInteger implements Comparable<FunnyInteger> {
    private final int value;

    public FunnyInteger(int value) {
        this.value = value;
    }

    public int get() {
        return value;
    }

    @Override
    public int hashCode() {
        return value % 7;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof FunnyInteger) {
            return this.value == ((FunnyInteger) obj).value;
        } else {
            return false;
        }
    }

    @Override
    public int compareTo(FunnyInteger funnyInteger) {
        return (funnyInteger == null) ? 1 : value - funnyInteger.value;
    }
}
