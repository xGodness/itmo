package lab6.commands;

import lab6.collection.CollectionManagerImpl;
import javax.validation.constraints.NotNull;

public class ClearCommand extends Command {
    public static final String tag = "clear";
    public static final String description = "CLEAR ... clears the collection";

    public ClearCommand() {
        super();
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(@NotNull CollectionManagerImpl moviesCollection, Object[] args) {
        moviesCollection.clearCollection();
        return "Collection has been cleared";
    }

}