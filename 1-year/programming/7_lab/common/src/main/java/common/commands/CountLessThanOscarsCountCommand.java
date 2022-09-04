package common.commands;

import common.collection.CollectionManagerImpl;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

public class CountLessThanOscarsCountCommand extends Command {
    public static final String tag = "count_less_than_oscars_count";
    public static final String description = "COUNT_LESS_THAN_OSCARS_COUNT [oscarsCount] ... returns amount of elements whose oscarsCount's value is smaller than given";

    public CountLessThanOscarsCountCommand() {
        super();
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(@NotNull CollectionManagerImpl collectionManager, Object[] args, String username) throws CollectionException {
        try {
            int value = Integer.parseInt((String) args[0]);
            return Integer.valueOf(collectionManager.countLessThanOscarsCount(value)).toString();
        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        } catch (NumberFormatException e) {
            throw new CollectionException("Incorrect input. Integer expected");
        }
    }

}
