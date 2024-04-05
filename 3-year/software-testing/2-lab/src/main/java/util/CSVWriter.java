package util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.List;

public class CSVWriter {
    private static final Logger logger = LoggerFactory.getLogger(CSVWriter.class);

    public static void write(String functionName, List<CSVEntry> entries) {
        File out = new File("results/%s.csv".formatted(functionName));

        try (PrintWriter pw = new PrintWriter(out)) {
            pw.println("x,approximated,precise");
            entries.stream().map(CSVEntry::toCsv).forEach(pw::println);
        } catch (FileNotFoundException ex) {
            logger.error(ex.getMessage());
        }
    }
}
