package math;

import lombok.Data;
import lombok.Getter;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

@Data
public class Configuration {
    private static final String propertiesFileName = "tests.properties";
    private static boolean isLoaded = false;

    @Getter
    private static double precision;
    @Getter
    private static int iterationCnt;
    @Getter
    private static double step;
    @Getter
    private static double initialValue;

    public static void load() {
        if (isLoaded) return;

        try (InputStream inputStream = Configuration.class.getClassLoader().getResourceAsStream(propertiesFileName)) {
            Properties prop = new Properties();

            if (inputStream != null) {
                prop.load(inputStream);
            } else {
                throw new RuntimeException("property file '" + propertiesFileName + "' was not found in the classpath");
            }

            precision = Double.parseDouble(prop.getProperty("precision"));
            iterationCnt = Integer.parseInt(prop.getProperty("iterationCnt"));
            step = Double.parseDouble(prop.getProperty("step"));
            initialValue = Double.parseDouble(prop.getProperty("initialValue"));

            isLoaded = true;
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
    }

}
