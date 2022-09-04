package client;

import client.factoryexceptions.CommandNotFoundException;
import client.factoryexceptions.FactoryException;
import common.collectionexceptions.RecursionException;
import common.commands.*;
import common.requestresponse.*;
import common.fileexceptions.FileException;
import common.movieclasses.Movie;
import common.IO.IOManager;

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

    /* Contains commands' description */
    private final static LinkedHashMap<String, String> descriptionsHashMap;
    private static final String pepper = "E#;Ax.W=";

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
        descriptionsHashMap = HashMapSorter.sortHashMap(unsortedDescriptionsHashMap);

    }

    private final IOManager ioManager;
    private final MovieBuilder movieBuilder;
    private final ClientFileManager fileManager;
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

    public Request authorize() {
        int opCode = 0;
        while (opCode != 1 && opCode != 2) {
            opCode = ioManager.getNextInteger("Login [1] or register [2]: ", false);
        }
        String username = ioManager.getNextInput("Username: ", false);
        String password = ioManager.getNextPassword();
        Session session = new Session(username, pepper + password);
        if (opCode == 1) {
            return new Request(RequestType.LOGIN, session);
        }
        return new Request(RequestType.REGISTER, session);
    }

    /**
     * Method that begins Console Manager iteration.
     */
    public Request execute(String username) {
        String input = ioManager.getNextInput("Type command (type \"help\" for help): ").toLowerCase(Locale.ROOT);
        if (!scriptStackTrace.isEmpty() && ioManager.isScannerStackEmpty()) {
            scriptStackTrace.clear();
        }
        String commandTag;
        LinkedList<String> parsedInput = new LinkedList<>();
        Arrays.stream(input.split("\\s+"))
                .map(String::trim)
                .forEach(parsedInput::add);
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
                break;

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
                        Movie movie = movieBuilder.buildMovie(username);
                        if (commandArgs[0] == null) commandArgs[0] = movie;
                        else commandArgs[1] = movie;
                    }
                    return new Request(RequestType.EXECUTE_COMMAND, command, commandArgs);
                } catch (FactoryException e) {
                    ioManager.printlnErr(e.getMessage());
                    return null;
                }
        }
        return null;
    }


    /**
     * Method that executes scripts from file.
     *
     * @param  fileName Name of the file contains script to execute
     * @throws FileException      Exception thrown if program could not access specified script file
     * @throws IOException        Exception thrown if IO manager had caught incorrect input
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