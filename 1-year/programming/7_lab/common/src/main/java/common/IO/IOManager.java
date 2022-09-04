package common.IO;

import java.io.Console;
import java.time.Duration;
import java.time.Instant;
import java.util.*;

/**
 * Input-Output Manager
 */

public class IOManager {
    public static final String ANSI_RESET = "\u001B[0m";
    public static final String ANSI_RED = "\u001B[31m";
    public static final String ANSI_GREEN = "\u001B[32m";
    public static final String ANSI_YELLOW = "\u001B[33m";
    public static final String ANSI_BLUE = "\u001B[34m";
    public static final String ANSI_PURPLE = "\u001B[35m";
    public static final String ANSI_CYAN = "\u001B[36m";
    public static final String ANSI_WHITE = "\u001B[37m";
    private static final String[] colours = new String[]{ANSI_BLUE, ANSI_YELLOW, ANSI_CYAN, ANSI_RED, ANSI_GREEN, ANSI_PURPLE, ANSI_WHITE};
    private final Scanner defaultScanner = new Scanner(System.in).useDelimiter("\n");
    private final Random random = new Random();
    private Scanner scanner;
    private final StringValidator stringValidator;
    private final Stack<Scanner> scannerStack = new Stack<>();

    public IOManager() {
        scanner = defaultScanner;
        stringValidator = new StringValidator();
    }

    /*________________________________________________________________________________________________________________
                                                    Getting inputs
    ________________________________________________________________________________________________________________*/

    private String getNextInput() {
        String input = null;
        while (input == null) {
            if (!scannerStack.isEmpty() && !scanner.hasNext()) {
                popScanner();
            }
            try {
                input = scanner.nextLine();
                if (!scannerStack.isEmpty()) {
                    printlnOut("\n>>> " + input);
                }
            } catch (IllegalArgumentException | NoSuchElementException e) {
                System.exit(0);
            }
            catch (Exception e) {
                e.printStackTrace();
                printOut("Invalid input error. Try again: ");
            }
        }
        return input;
    }

    public String getNextInput(String preMessage) {
        printOut(preMessage);
        String input = getNextInput();
        if (input.length() > 100) {
            printlnErr("Input limit has been reached");
            return "";
        }
        return input;
    }

    public String getNextInput(String preMessage, boolean nullAllowed) {
        String input;
        while (true) {
            input = getNextInput(preMessage);
            if ((input != null && !input.equals("")) || nullAllowed) {
                return input;
            }
        }
    }

    public Double getNextDouble(String preMessage, boolean nullAllowed) {
        String input;
        Double d = null;
        while (d == null) {
            if (preMessage != null) {
                printOut(preMessage);
            }
            input = getNextInput();
            if (nullAllowed && input.trim().equals("")) return null;
            try {
                d = Double.parseDouble(input);
                if (d == Double.POSITIVE_INFINITY || d == Double.NEGATIVE_INFINITY) {
                    printlnErr("Incorrect input. Number too small or too big");
                    d = null;
                }
            } catch (NumberFormatException e) {
                printlnErr("Incorrect input. Double-type value expected");
            }
        }
        return d;
    }

    public Float getNextFloat(String preMessage, boolean nullAllowed) {
        String input;
        Float f = null;
        while (f == null) {
            if (preMessage != null) {
                printOut(preMessage);
            }
            input = getNextInput();
            if (nullAllowed && input.trim().equals("")) return null;
            try {
                f = Float.parseFloat(input);
                if (f == Float.POSITIVE_INFINITY || f == Float.NEGATIVE_INFINITY) {
                    printlnErr("Number too small or too big");
                    f = null;
                }
            } catch (NumberFormatException e) {
                printlnErr("Incorrect input. Float-type value expected");
            }
        }
        return f;
    }

    public Integer getNextInteger(String preMessage, boolean nullAllowed) {
        String input;
        Integer i = null;
        while (i == null) {
            if (preMessage != null) {
                printOut(preMessage);
            }
            input = getNextInput();
            if (nullAllowed && input.equals("")) return null;
            try {
                i = Integer.parseInt(input);
                if (i == Integer.MAX_VALUE || i == Integer.MIN_VALUE) {
                    printlnErr("Number too small or too big");
                    i = null;
                }
            } catch (NumberFormatException e) {
                printlnErr("Incorrect input. Integer-type value expected");
            }
        }
        return i;
    }

    public String getNextPassword() {
        Console console = System.console();
        while (true) {
            try {
                printOut("Password: ");
                char[] password = console.readPassword();
                if (password.length == 0) {
                    continue;
                }
                return new String(password);
            } catch (IllegalArgumentException | NoSuchElementException e) {
                System.exit(0);
            }
        }
    }

    /*________________________________________________________________________________________________________________
                                            Scanners stack methods
                                   (used for handling execute_script command)
    ________________________________________________________________________________________________________________*/

    public void pushScanner(Scanner scanner) {
        scannerStack.push(scanner);
        this.scanner = scanner;
    }

    /* returns true if empty */
    public boolean popScanner() {
        scannerStack.pop();
        if (scannerStack.isEmpty()) {
            scanner = defaultScanner;
            return true;
        } else {
            scanner = scannerStack.peek();
            return false;
        }
    }

    public boolean isScannerStackEmpty() {
        return scannerStack.isEmpty();
    }

    public void clearScannerStack() {
        scannerStack.clear();
        scanner = defaultScanner;
    }

    /*________________________________________________________________________________________________________________
                                                    Text formatting
    ________________________________________________________________________________________________________________*/

    public String redText(String message) {
        return ANSI_RED + message + ANSI_RESET;
    }

    public String yellowText(String message) {
        return ANSI_YELLOW + message + ANSI_RESET;
    }

    public String greenText(String message) {
        return ANSI_GREEN + message + ANSI_RESET;
    }

    public String statusText(String message) {
        return "[STATUS] " + message;
    }

    /*________________________________________________________________________________________________________________
                                                    Printing
    ________________________________________________________________________________________________________________*/

    public void printOut(String message) {
        System.out.print(message);
    }

    public void printlnOut(String message) {
        System.out.println(message);
    }

    public void printErr(String message) {
        printOut(ANSI_RED + message + ANSI_RESET);
    }

    public void printlnErr(String message) {
        printlnOut(ANSI_RED + message + ANSI_RESET);
    }

    public void printlnSuccess(String message) {
        printlnOut(ANSI_GREEN + message + ANSI_RESET);
    }

    public void printlnInfoFormat(String[] message) {
        if (message.length == 2) {
            System.out.format("%-54s", ANSI_YELLOW + message[0] + ANSI_RESET);
            System.out.format("%s", ANSI_YELLOW + message[1] + ANSI_RESET + "\n");
        }
    }

    public void printlnYellow(String message) {
        printlnOut(ANSI_YELLOW + message + ANSI_RESET);
    }

    public void printlnStatus(String message) {
        printlnOut(ANSI_YELLOW + "[STATUS] " + message + ANSI_RESET);
    }

    public void printlnRainbow(String message) {
        StringBuilder out = new StringBuilder();
        for (char c : message.toCharArray()) {
            out.append(randomColour()).append(c).append(ANSI_RESET);
        }
        printlnOut(out.toString());
    }

    /*________________________________________________________________________________________________________________
                                                 Validations
    ________________________________________________________________________________________________________________*/

    public boolean isStringValid(String string) {
        return stringValidator.stringValidation(string);
    }

    public boolean isNumericOnly(String string) {
        return stringValidator.numericValidation(string);
    }

    public boolean isSpacesOnly(String string) {
        return stringValidator.spacesOnlyValidation(string);
    }

    /*________________________________________________________________________________________________________________
                                              Auxiliary methods
    ________________________________________________________________________________________________________________*/

    public void sleep(int sec) {
        Instant awaitTime = Instant.now();
        while (true) {
            if (Duration.between(awaitTime, Instant.now()).getSeconds() < sec) return;
        }
    }

    private String randomColour() {
        return colours[random.nextInt(colours.length)];
    }

    public boolean hasNext() {
        return scanner.hasNext();
    }

}
