package lab6.client;

import lab6.exceptions.collectionexceptions.RecursionException;
import lab6.exceptions.factoryexceptions.CommandNotFoundException;
import lab6.exceptions.factoryexceptions.FactoryException;
import lab6.exceptions.fileexceptions.FileException;
import lab6.movieclasses.Movie;
import lab6.requestresponse.*;
import lab6.IO.IOManager;
import lab6.commands.*;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Connects client.lab6.IO with application.
 * Also generates new lab6.commands by user's input.
 * Static block loads all available lab6.commands to the class loader
 * and saves their descriptions to the sorted linked hash map.
 */
public class ConsoleManager {

    /* Contains all lab6.lab6.client.lab6.commands' description */
    private final static LinkedHashMap<String, String> descriptionsHashMap;

    static {
        /* Registering all available lab6.lab6.client.lab6.commands */
        try {
            CommandsFactory.registerCommand("add", AddCommand.class);
            CommandsFactory.registerCommand("clear", ClearCommand.class);
            CommandsFactory.registerCommand("add_if_max", AddIfMaxCommand.class);
            CommandsFactory.registerCommand("clear", ClearCommand.class);
            CommandsFactory.registerCommand("count_less_than_oscars_count", CountLessThanOscarsCountCommand.class);
            CommandsFactory.registerCommand("filter_starts_with_tagline", FilterStartsWithTaglineCommand.class);
            CommandsFactory.registerCommand("info", InfoCommand.class);
            CommandsFactory.registerCommand("max_by_screenwriter", MaxByScreenwriterCommand.class);
            CommandsFactory.registerCommand("remove_by_id", RemoveByIdCommand.class);
            CommandsFactory.registerCommand("remove_head", RemoveHeadCommand.class);
            CommandsFactory.registerCommand("remove_lower", RemoveLowerCommand.class);
            CommandsFactory.registerCommand("show", ShowCommand.class);
            CommandsFactory.registerCommand("update", UpdateCommand.class);
        } catch (CommandNotFoundException e) {
            e.printStackTrace();
        }

        /* Collecting all available command descriptions */
        HashMap<String, String> unsortedDescriptionsHashMap = new HashMap<>();
        unsortedDescriptionsHashMap.put("help", "HELP ... provides help");
        unsortedDescriptionsHashMap.put("exit", "EXIT ... saves collection and closes program");

        Map<String, String> descriptionMap = CommandsFactory
                .getAllRegisteredTags()
                .stream()
                .collect(Collectors
                        .toMap(t -> t, t -> {
                                    try {
                                        return CommandsFactory.getDescription(t);
                                    } catch (CommandNotFoundException ignored) {}
                                    return ""; } ));
        unsortedDescriptionsHashMap.putAll(descriptionMap);


//        for (String tag : CommandsFactory.getAllRegisteredTags()) {
//            try {
//                unsortedDescriptionsHashMap.put(tag, CommandsFactory.getDescription(tag));
//            } catch (CommandNotFoundException e) {
//                e.printStackTrace();
//            }
//        }
        descriptionsHashMap = HashMapSorter.sortHashMap(unsortedDescriptionsHashMap);

    }

    //    private Application application;
    private IOManager ioManager;
    private MovieBuilder movieBuilder;
    private ClientFileManager fileManager;
    private HashSet<String> scriptStackTrace;
    private LinkedList<String> commandsWithMovieArg = new LinkedList<>();
    private LinkedList<String> commandsWithNotMovieArgs = new LinkedList<>();


    public ConsoleManager(IOManager ioManager) {
        this.ioManager = ioManager;
        movieBuilder = new MovieBuilder(ioManager);
        fileManager = new ClientFileManager(ioManager);
        scriptStackTrace = new HashSet<>();
        commandsWithMovieArg.add("add");
        commandsWithMovieArg.add("add_if_max");
        commandsWithMovieArg.add("remove_lower");
        commandsWithMovieArg.add("update");
        commandsWithNotMovieArgs.add("count_less_than_oscars_count");
        commandsWithNotMovieArgs.add("filter_starts_with_tagline");
        commandsWithNotMovieArgs.add("remove_by_id");
        commandsWithNotMovieArgs.add("update");
    }


    /**
     * Method that begins Console Manager iteration.
     */
    public Request execute() {
        if (ioManager.isScannerStackEmpty() && !scriptStackTrace.isEmpty()) {
            scriptStackTrace.clear();
        }
        String input;
        LinkedList<String> parsedInput = new LinkedList<>();
        String commandTag;
        input = ioManager.getNextInput("Type command (type \"help\" for help): ").toLowerCase(Locale.ROOT);
        for (String word : input.split("\\s+")) {
            parsedInput.add(word.trim());
        }
        if (parsedInput.size() == 0) {
            return null;
        }
        commandTag = parsedInput.pollFirst();
        switch (commandTag) {
            case ("help"):
                descriptionsHashMap.values()
                        .stream()
                        .map(s -> s.split("\\.\\.\\."))
                        .forEach(ioManager::printlnInfoFormat);
//                for (String cmdDescription : descriptionsHashMap.values()) {
//                    ioManager.printlnInfoFormat(cmdDescription.split("\\.\\.\\."));
//                }
                return null;
            case ("exit"):
                return new Request(RequestType.EXIT);
            case ("execute_script"):
                if (parsedInput.size() == 0) {
                    ioManager.printlnErr("Too few arguments");
                    return null;
                }
                ioManager.printlnStatus("Executing script...");
                try {
                    executeScript(parsedInput.getFirst());
                } catch (FileException | IOException | RecursionException e) {
                    ioManager.printlnErr(e.getMessage());
                    if (e instanceof RecursionException) {
                        scriptStackTrace.clear();
                        ioManager.printlnStatus("Terminating script execution...");
                        ioManager.clearScannerStack();
                        return null;
                    }
                }
            default:
                try {
                    Command command = CommandsFactory.getCommand(commandTag);
                    Object[] commandArgs = new Object[2];
                    if (commandsWithNotMovieArgs.contains(commandTag)) {
                        if (parsedInput.size() == 0) {
                            ioManager.printlnErr("Too few arguments");
                            return null;
                        }
                        commandArgs[0] = parsedInput.get(0);
                    }
                    if (commandsWithMovieArg.contains(commandTag)) {
                        Movie movie = movieBuilder.buildMovie();
                        if (commandArgs[0] == null) commandArgs[0] = movie;
                        else commandArgs[1] = movie;
                    }
                    return new Request(RequestType.EXECUTE_COMMAND, command, commandArgs);
                } catch (FactoryException e) {
//                    ioManager.printlnErr(e.getMessage());
                    return null;
                }


        }
    }


    /**
     * Method that executes scripts from file.
     *
     * @param fileName Name of the file contains script to execute
     * @throws FileException      Exception thrown if program could not access specified script file
     * @throws IOException        Exception thrown if lab6.lab6.client.lab6.IO manager had caught incorrect input
     * @throws RecursionException Exception thrown if recursion had been found
     */
    public void executeScript(String fileName) throws FileException, IOException, RecursionException {
        if (scriptStackTrace.contains(fileName)) {
            throw new RecursionException("Recursion has been found");
        }
        File file = fileManager.openFile(fileName);
        scriptStackTrace.add(fileName);
        Scanner fileScanner = new Scanner(file).useDelimiter("\n");
        ioManager.pushScanner(fileScanner);
    }

}