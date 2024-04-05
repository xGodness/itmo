package math;

import java.util.function.BiFunction;
import java.util.function.Function;

public class FunnyFunction {
    private static Function<Double, Double> provideLn(boolean isPrecise) {
        return isPrecise ? Logarithm::preciseValue : Logarithm::approximatedValue;
    }

    private static BiFunction<Double, Double, Double> provideLog(boolean isPrecise) {
        return isPrecise ? Logarithm::preciseValue : Logarithm::approximatedValue;
    }

    private static Function<Double, Double> provideTan(boolean isPrecise) {
        return isPrecise ? Trigonometry.Tangent::preciseValue : Trigonometry.Tangent::approximatedValue;
    }

    private static Function<Double, Double> provideCsc(boolean isPrecise) {
        return isPrecise ? Trigonometry.Cosecant::preciseValue : Trigonometry.Cosecant::approximatedValue;
    }

    public static double approximate(double x) {
        return x <= 0
                ? calculateAtXLessOrEqualsToZero(x, false)
                : calculateAtXGreaterThanToZero(x, false);
    }

    public static double calculatePrecise(double x) {
        return x <= 0
                ? calculateAtXLessOrEqualsToZero(x, true)
                : calculateAtXGreaterThanToZero(x, true);
    }

    private static double calculateAtXLessOrEqualsToZero(double x, boolean isPrecise) {
        var tan = provideTan(isPrecise);
        var csc = provideCsc(isPrecise);
        double mul = tan.apply(x) * csc.apply(x);
        return mul * mul * mul;
    }

    private static double calculateAtXGreaterThanToZero(double x, boolean isPrecise) {
        var ln = provideLn(isPrecise);
        var log = provideLog(isPrecise);
        return ((((log.apply(x, 5.0) / ln.apply(x)) + log.apply(x, 5.0)) / ln.apply(x)) + log.apply(x, 2.0))
                / (log.apply(x, 2.0) / (log.apply(x, 10.0) * (log.apply(x, 10.0) + ln.apply(x))));
    }
}
