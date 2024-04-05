package math;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import util.CSVEntry;
import util.CSVWriter;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class MathTest {
    private static double precision;
    private static int iterationCnt;
    private static double step;
    private static double initialValue;

    @BeforeAll
    static void loadConfig() {
        Configuration.load();
        precision = Configuration.getPrecision();
        iterationCnt = Configuration.getIterationCnt();
        step = Configuration.getStep();
        initialValue = Configuration.getInitialValue();
    }

    private List<CSVEntry> doTest(double step,
                        Function<Double, Double> approximatingFunction,
                        Function<Double, Double> preciseFunction) {
        double x = initialValue;

        double approxValue;
        double preciseValue;

        List<CSVEntry> csvEntries = new ArrayList<>();

        for (int i = 0; i < iterationCnt; i++, x += step) {
            approxValue = approximatingFunction.apply(x);
            preciseValue = preciseFunction.apply(x);
            csvEntries.add(new CSVEntry(x, approxValue, preciseValue));
            Assertions.assertEquals(approxValue, preciseValue, precision);
        }

        return csvEntries;
    }

    @Test
    void logarithmTest() {
        var csvEntries = doTest(step, Logarithm::preciseValue, Logarithm::approximatedValue);
        CSVWriter.write("Logarithm", csvEntries);
    }

    @Test
    void sineTest() {
        var csvEntries = doTest(-step, Trigonometry.Sine::preciseValue, Trigonometry.Sine::approximatedValue);
        csvEntries.addAll(doTest(step, Trigonometry.Sine::preciseValue, Trigonometry.Sine::approximatedValue));
        CSVWriter.write("Sine", csvEntries);
    }

    @Test
    void tangentTest() {
        var csvEntries = doTest(-step, Trigonometry.Tangent::preciseValue, Trigonometry.Tangent::approximatedValue);
        csvEntries.addAll(doTest(step, Trigonometry.Tangent::preciseValue, Trigonometry.Tangent::approximatedValue));
        CSVWriter.write("Tangent", csvEntries);
    }

    @Test
    void funnyFunctionTest() {
        var csvEntries = doTest(-step, FunnyFunction::calculatePrecise, FunnyFunction::approximate);
        csvEntries.addAll(doTest(step, FunnyFunction::calculatePrecise, FunnyFunction::approximate));
        CSVWriter.write("FunnyFunction", csvEntries);
    }

}
