package server;

import common.commands.CommandImpl;
import common.collectionexceptions.CollectionException;

/**
 * Class that receives commands and orders them to execute.
 */
public class CommandInvoker {
    private Application application;
    private CommandImpl command;
    private Object[] args;
    private String username;

    /**
     * The only constructor. Needs Application as argument because link to the connected application is necessary.
     *
     * @param application Connected Application instance
     */
    public CommandInvoker(Application application) {
        this.application = application;
    }

    /**
     * Method that sets received command as current
     *
     * @param command Command to set
     * @param args    Commands' arguments to set
     */
    public void setCommand(CommandImpl command, Object[] args, String username) {
        this.command = command;
        this.args = args;
        this.username = username;
    }

    /**
     * Method that executes command and returns its result
     *
     * @return Result of command execution
     * @throws CollectionException Exception thrown if error during command execution was presented
     */
    public String executeCommand() throws CollectionException {
        return command.execute(application.getCollectionManager(), args, username);
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

    /**
     * Method to see current set username
     *
     * @return Username currently set
     */
    public String getUsername() {
        return username;
    }

}
