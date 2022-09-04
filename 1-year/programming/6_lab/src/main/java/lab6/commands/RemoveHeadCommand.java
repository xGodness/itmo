package lab6.commands;

import lab6.exceptions.collectionexceptions.CollectionException;
import lab6.collection.CollectionManagerImpl;
import javax.validation.constraints.NotNull;
import lab6.movieclasses.Movie;

public class RemoveHeadCommand extends Command {
    public static final String tag = "remove_head";
    public static final String description = "REMOVE_HEAD ... shows first element in the collection and removes it";

    public RemoveHeadCommand() {
        super();
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(@NotNull CollectionManagerImpl moviesCollection, Object[] args) throws CollectionException {
        Movie movie = moviesCollection.removeHead();
        return movie.toString();
    }

}
