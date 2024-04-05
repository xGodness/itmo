package math;

public class Trigonometry {
    static class Sine {
        private static final int seriesTermCount = 10;

        static double approximatedValue(double x) {
            double xSquared = x * x;
            double result = x;
            double lastX = x;
            int lastSign = 1;
            int lastDivisor = 1;

            for (int i = 1; i <= seriesTermCount; i++) {
                lastSign = -lastSign;
                lastX *= xSquared;
                lastDivisor *= 2 * i * (2 * i + 1);
                result += lastSign * lastX / lastDivisor;
            }

            return result;
        }

        static double preciseValue(double x) {
            return Math.sin(x);
        }
    }

    static class Tangent {
        static double approximatedValue(double x) {
            double halvedXSine = Sine.approximatedValue(x / 2);
            return Sine.approximatedValue(x) / (1 - 2 * halvedXSine * halvedXSine);
        }

        static double preciseValue(double x) {
            return Math.tan(x);
        }
    }

    static class Cosecant {
        static double approximatedValue(double x) {
            return 1 / Sine.approximatedValue(x);
        }

        static double preciseValue(double x) {
            return 1 / Math.sin(x);
        }
    }
}
