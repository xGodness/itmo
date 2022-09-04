package lab6.server;

import lab6.commands.CommandImpl;
import lab6.exceptions.collectionexceptions.CollectionException;

/**
 * Class that receives commands and orders them to execute.
 */
public class Invoker {
    private Application application;
    private CommandImpl command;
    private Object[] args;

    /**
     * The only constructor. Needs Application as argument because link to the connected application is necessary.
     *
     * @param application Connected Application instance
     */
    public Invoker(Application application) {
        this.application = application;
    }

    /**
     * Method that sets received command as current
     *
     * @param command Command to set
     * @param args    Commands' arguments to set
     */
    public void setCommand(CommandImpl command, Object[] args) {
        this.command = command;
        this.args = args;
    }

    /**
     * Method that executes command and returns its result
     *
     * @return Result of command execution
     * @throws CollectionException Exception thrown if error during command execution was presented
     */
    public String executeCommand() throws CollectionException {
        return command.execute(application.getMoviesCollection(), args);
    }

    /**
     * Method to see current set command
     *
     * @return Command currently set
     */
    public CommandImpl getCommand() {
        return command;
    }

    /**
     * Method to see current set command's arguments
     *
     * @return Command's arguments currently set
     */
    public Object[] getArgs() {
        return args;
    }

}
