package math;

public class Logarithm {
    private static final int seriesTermCount = 200;

    public static double approximatedValue(double x) {
        if (x == 0) return Double.NEGATIVE_INFINITY;
        if (x < 0) return Double.NaN;

        double val = (x - 1) / (x + 1);
        double constant = val * val;
        double result = 0;

        for (int i = 0; i < seriesTermCount; i++) {
            result += val / (2 * i + 1);
            val *= constant;
        }

        return result * 2;
    }

    public static double approximatedValue(double x, double base) {
        return Logarithm.approximatedValue(x) / Logarithm.approximatedValue(base);
    }

    public static double preciseValue(double x) {
        return Math.log(x);
    }

    public static double preciseValue(double x, double base) {
        return Math.log(x) / Math.log(base);
    }
}
