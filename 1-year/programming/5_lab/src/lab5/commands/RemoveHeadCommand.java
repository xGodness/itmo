package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.EmptyCollectionException;
import lab5.movie_classes.Movie;

public class RemoveHeadCommand extends Command {
    public static final String tag = "remove_head";
    public static final String description = "REMOVE_HEAD ... shows first element in the collection and removes it";

    public RemoveHeadCommand(MoviesCollection moviesCollection) {
        super(moviesCollection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) throws EmptyCollectionException {
        Movie movie = getMoviesCollection().removeHead();
        return movie.toString();
    }

}
