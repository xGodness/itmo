package math;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;

public class TaylorCosAtZeroTest {
    private static final double precision = 1e-4;

    private static double trueCosValue(double x) {
        return Math.cos(x);
    }

    @ParameterizedTest
    @CsvFileSource(resources = "cos-x-params.csv")
    void simpleTest(double x) {
        Assertions.assertEquals(TaylorCosAtZero.calculate(x), trueCosValue(x), precision);
    }

}
