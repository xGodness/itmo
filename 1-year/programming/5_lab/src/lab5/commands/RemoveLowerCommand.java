package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.CollectionException;

public class RemoveLowerCommand extends Command {
    public static final String tag = "remove_lower";
    public static final String description = "REMOVE_LOWER {element} ... removes all collection's elements that are smaller than given element";

    public RemoveLowerCommand(MoviesCollection moviesCollection) {
        super(moviesCollection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) throws CollectionException {
        if (getMoviesCollection().getCollectionSize() == 0) {
            throw new CollectionException("Collection is empty");
        }
        getMoviesCollection().removeLower();
        return "Lower elements have been removed";
    }
}
