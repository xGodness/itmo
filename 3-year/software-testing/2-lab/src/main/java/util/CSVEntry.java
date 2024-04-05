package util;

public record CSVEntry(double x, double approxValue, double preciseValue) {
    public String toCsv() {
        return "%f,%f,%f".formatted(x, approxValue, preciseValue);
    }
}
