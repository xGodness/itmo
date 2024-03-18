package math;

public class TaylorCosAtZero {
    private static final int seriesTermCount = 7;

    public static double calculate(double x) {
        double xSquared = x * x;
        double result = 1.0;
        double lastX = 1.0;
        int lastSign = 1;
        int lastDivisor = 1;

        for (int i = 1; i <= seriesTermCount; i++) {
            lastSign = -lastSign;
            lastX *= xSquared;
            lastDivisor *= 2 * i * (2 * i - 1);
            result += lastSign * lastX / lastDivisor;
        }

        return result;
    }
}
