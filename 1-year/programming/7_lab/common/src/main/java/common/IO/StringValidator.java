package common.IO;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * String validator for checking if string is correct
 */

public class StringValidator {


    private final Pattern charsetValidationPattern = Pattern.compile("[ \\wА-Яа-яЁё!\"#$%&'()*+,\\-./:;<=>?@\\[\\]^_`{|}\\\\~№]+");
    private final Pattern spacesValidationPattern = Pattern.compile("\\s+");
    private final Pattern numericValidationPatter = Pattern.compile("[0-9]+");

    public boolean numericValidation(String string) {
        if (string == null) {
            return false;
        }
        Matcher matcher = numericValidationPatter.matcher(string);
        if (matcher.find()) {
            return string.substring(matcher.start(), matcher.end()).equals(string);
        }
        return false;
    }

    public boolean stringValidation(String string) {
        return charsetValidation(string) && !spacesOnlyValidation(string);
    }

    public boolean charsetValidation(String string) {
        if (string == null) {
            return false;
        }
        Matcher matcher = charsetValidationPattern.matcher(string);
        if (matcher.find()) {
            return string.substring(matcher.start(), matcher.end()).equals(string);
        }
        return false;
    }

    public boolean spacesOnlyValidation(String string) {
        if (string == null) {
            return false;
        }
        Matcher matcher = spacesValidationPattern.matcher(string);
        if (matcher.find()) {
            return string.substring(matcher.start(), matcher.end()).equals(string);
        }
        return false;
    }
}
