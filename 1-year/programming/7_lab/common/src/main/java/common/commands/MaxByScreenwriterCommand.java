package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

public class MaxByScreenwriterCommand extends Command {
    public static final String tag = "max_by_screenwriter";
    public static final String description = "MAX_BY_SCREENWRITER ... shows element with the biggest screenwriter field value";

    public MaxByScreenwriterCommand() {
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
            Movie result = collectionManager.maxByScreenwriter();
            return result.toString();
        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        }
    }
}
