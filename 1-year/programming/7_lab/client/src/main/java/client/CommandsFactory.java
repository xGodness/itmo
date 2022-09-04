package client;

import client.factoryexceptions.CommandNotFoundException;
import common.commands.Command;
import client.factoryexceptions.CannotAccessCommandException;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.Set;

/**
 * Singleton Factory class. Used to get new command instance by its name (tag).
 */
public class CommandsFactory {
    private static HashMap<String, Class<? extends Command>> registeredCommands = new HashMap<>();

    /**
     * Static method to load command class to class loader. Saves loaded commands to hash map.
     *
     * @param tag    Command name
     * @param _class Command class
     * @throws CommandNotFoundException Exception thrown in case factory could not access command by its tag
     */
    public static void registerCommand(String tag, Class<? extends Command> _class) throws CommandNotFoundException {
        try {
            Class.forName(_class.getName());
            registeredCommands.put(tag, _class);
        } catch (ClassNotFoundException e) {
            throw new CommandNotFoundException("Command '" + tag + "' does not exist");
        }
    }

    /**
     * Static method to get description of the command by its tag.
     *
     * @param tag Command name
     * @return Description of the command
     * @throws CommandNotFoundException Exception thrown in case factory could not access command by its tag
     */
    public static String getDescription(String tag) throws CommandNotFoundException {
        if (registeredCommands.containsKey(tag)) {
            String description;
            Class<? extends Command> command = registeredCommands.get(tag);
            try {
                description = (String) command.getDeclaredField("description").get(command);
            } catch (NoSuchFieldException | SecurityException | IllegalAccessException e) {
                e.printStackTrace();
                throw new CommandNotFoundException("Information about command is not available at the moment. Please try again later. *beep* *beep* *beep*");
            }
            return description;
        }
        throw new CommandNotFoundException("Command '" + tag + "' does not exist");
    }

    /**
     * Static method to create new command instance by its tag.
     *
     * @param tag Command name
     *            //     * @param moviesCollection                  Current .collection. Necessary due to commands' constructors need it
     * @return New command instance
     * @throws CommandNotFoundException     Exception thrown in case factory could not access command by its tag
     * @throws CannotAccessCommandException Exception thrown in case factory could not access command because of its access modifiers
     */
    public static Command getCommand(String tag) throws CommandNotFoundException, CannotAccessCommandException {
        if (registeredCommands.containsKey(tag)) {
            try {
                return registeredCommands.get(tag).getConstructor(new Class[]{}).newInstance();
            } catch (InstantiationException | IllegalAccessException e) {
                e.printStackTrace();
                throw new CannotAccessCommandException("Error during accessing command class with tag '" + tag + "'");
            } catch (InvocationTargetException | NoSuchMethodException e) {
                e.printStackTrace();
            }
        }
        throw new CommandNotFoundException("Command '" + tag + "' does not exist");
    }

    /**
     * Static method to get all registered commands as a set.
     *
     * @return All registered commands
     */
    public static Set<String> getAllRegisteredTags() {
        return registeredCommands.keySet();
    }

}
