package lab5.app;

import lab5.IO.IOManager;
import lab5.commands.*;
import lab5.exceptions.collection_exceptions.CollectionException;
import lab5.exceptions.collection_exceptions.RecursionException;
import lab5.exceptions.factory_exceptions.CannotAccessCommandException;
import lab5.exceptions.factory_exceptions.CommandNotFoundException;
import lab5.exceptions.file_exceptions.FileException;

import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * Connects IO with application.
 * Also generates new commands by user's input.
 * Static block loads all available commands to the class loader
 * and saves their descriptions to the sorted linked hash map.
 */
public class ConsoleManager {

    private Application application;
    private IOManager ioManager;


    /* Contains all commands' description */
    private final static LinkedHashMap<String, String> descriptionsMap;


    private String fileName;

    static {
        /* Registering all available commands */
        try {
            CommandsFactory.registerCommand("add", AddCommand.class);
            CommandsFactory.registerCommand("clear", ClearCommand.class);
            CommandsFactory.registerCommand("add", AddCommand.class);
            CommandsFactory.registerCommand("add_if_max", AddIfMaxCommand.class);
            CommandsFactory.registerCommand("clear", ClearCommand.class);
            CommandsFactory.registerCommand("count_less_than_oscars_count", CountLessThanOscarsCountCommand.class);
            CommandsFactory.registerCommand("filter_starts_with_tagline", FilterStartsWithTaglineCommand.class);
            CommandsFactory.registerCommand("info", InfoCommand.class);
            CommandsFactory.registerCommand("max_by_screenwriter", MaxByScreenwriterCommand.class);
            CommandsFactory.registerCommand("remove_by_id", RemoveByIdCommand.class);
            CommandsFactory.registerCommand("remove_head", RemoveHeadCommand.class);
            CommandsFactory.registerCommand("remove_lower", RemoveLowerCommand.class);
            CommandsFactory.registerCommand("save", SaveCommand.class);
            CommandsFactory.registerCommand("show", ShowCommand.class);
            CommandsFactory.registerCommand("update", UpdateCommand.class);
        } catch (CommandNotFoundException e) {
            e.printStackTrace();
        }

        /* Collecting all available commands' descriptions */
        HashMap<String, String> unsortedDescriptionsMap = new HashMap<>();
        unsortedDescriptionsMap.put("help", "HELP ... provides help");
        unsortedDescriptionsMap.put("exit", "EXIT ... closes program without saving");
        for (String tag : CommandsFactory.getAllRegisteredTags()) {
            try {
                unsortedDescriptionsMap.put(tag, CommandsFactory.getDescription(tag));
            } catch (CommandNotFoundException e) {
                e.printStackTrace();
            }
        }
        descriptionsMap = HashMapSorter.sortHashMap(unsortedDescriptionsMap);

    }

    /**
     * The only constructor. Needs Application as argument because link to the connected application is necessary.
     *
     * @param application   Connected Application instance
     */
    public ConsoleManager(Application application) {
        this.application = application;
        this.ioManager = application.getIoManager();
    }

    /**
     * Method that begins Console Manager main loop.
     */
    public void execute() {
        String input;
        LinkedList<String> parsedInput = new LinkedList<>();
        String commandTag;
        String[] commandArgs;


        while (true) {
            input = ioManager.getNextInput("Type command (type \"help\" for help): ").toLowerCase(Locale.ROOT);
            parsedInput.clear();
            commandArgs = new String[] {};
            for (String word : input.split("\\s+")) {
                parsedInput.add(word.trim());
            }

            if (parsedInput.size() == 0) {
                continue;
            }

            commandTag = parsedInput.get(0);

            switch (commandTag) {

                case ("help"):
                    for (String cmdDescription : descriptionsMap.values()) {
                        ioManager.printlnInfoFormat(cmdDescription.split("\\.\\.\\."));
                    }
                    break;

                case ("exit"):
                    ioManager.printlnStatus("Terminating program...");
                    return;

                case ("execute_script"):
                    if (parsedInput.size() == 1) {
                        ioManager.printlnErr("Cannot execute script because file name wasn't specified");
                        continue;
                    }
                    ioManager.printlnStatus("Executing script...");
                    HashSet scriptsCallStack = new HashSet();
                    scriptsCallStack.add(parsedInput.get(1));
                    try {
                        boolean recursionExitCode = executeScript(parsedInput.get(1), new HashSet<>());
                        if (!recursionExitCode) {
                            ioManager.printlnStatus("Terminating program...");
                            ioManager.clearScannerStack();
                            return;
                        }
                        ioManager.clearScannerStack();
                        break;
                    } catch (FileException | RecursionException | IOException e) {
                        ioManager.clearScannerStack();
                        ioManager.printlnErr(e.getMessage());
                        break;
                    }

                default:
                    try {
                        Command command = CommandsFactory.getCommand(commandTag, application.getMoviesCollection());
                        for (int i = 1; i < parsedInput.size(); i++) {
                            commandArgs[i - 1] = parsedInput.get(i);
                        }
                        ioManager.printlnSuccess(
                                application.executeCommand(command, commandArgs)
                        );
                    } catch (CommandNotFoundException | CannotAccessCommandException | CollectionException e) {
                        ioManager.printlnErr(e.getMessage());
                    }
                    break;
            }
        }
    }

    /**
     * Method that executes scripts from files.
     *
     * @param fileName              Name of the file contains script to execute
     * @param stackTrace            Stack of file names that already have been called
     * @return                      "true" if program must terminate after executing script (if there was "exit" command in the script)
     * @throws FileException        Exception thrown if program could not access specified script file
     * @throws IOException          Exception thrown if IO manager had caught incorrect input
     * @throws RecursionException   Exception thrown if recursion had been found
     */
    public boolean executeScript(String fileName, HashSet<String> stackTrace) throws FileException, IOException, RecursionException {
        if (stackTrace.contains(fileName)) {
            throw new RecursionException("Recursion has been found");
        }
        File file = application.getFileManager().openFile(fileName);
        stackTrace.add(fileName);
        Scanner fileScanner = new Scanner(file).useDelimiter("\n");
        ioManager.pushScanner(fileScanner);
        String input;
        String[] parsedInput;

        while (fileScanner.hasNextLine()) {

            input = fileScanner.nextLine();
            ioManager.printlnStatus(">>> " + input);
            parsedInput = input.split("\\s+");

            if (parsedInput.length == 0) {
                continue;
            }

            String commandTag = parsedInput[0].trim();

            switch (commandTag) {

                case ("help"):
                    for (String cmdDescription : descriptionsMap.values()) {
                        ioManager.printlnInfoFormat(cmdDescription.split("\\.\\.\\."));
                    }
                    break;

                case ("exit"):
                    return false;

                case ("execute_script"):
                    if (parsedInput.length == 1) {
                        ioManager.printlnErr("Script file name wasn't specified");
                        continue;
                    }
                    ioManager.printlnStatus("Executing script...");
                    boolean statusCode = executeScript(parsedInput[1], stackTrace);
                    if (!statusCode) {
                        return false;
                    }
                    break;

                default:
                    try {
                        Command command = CommandsFactory.getCommand(commandTag, application.getMoviesCollection());
                        String[] commandArgs = Arrays.copyOfRange(parsedInput, 1, parsedInput.length);
                        for (int i = 0; i < commandArgs.length; i++) {
                            commandArgs[i] = commandArgs[i].trim();
                        }
                        ioManager.printlnSuccess(
                                application.executeCommand(command, commandArgs)
                        );
                    } catch (CommandNotFoundException | CannotAccessCommandException | CollectionException e) {
                        ioManager.printlnErr(e.getMessage());
                    }
                    break;
            }

        }
        ioManager.popScanner();
        return true;
    }






}