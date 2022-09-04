package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.CollectionException;
import lab5.movie_classes.Movie;

import java.util.LinkedList;

public class FilterStartsWithTaglineCommand extends Command {
    public static final String tag = "filter_starts_with_tagline";
    public static final String description = "FILTER_STARTS_WITH_TAGLINE [tagline] ... shows element whose tagline field starts with given substring";

    public FilterStartsWithTaglineCommand(MoviesCollection moviesCollection) {
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
        if (args == null || args.length == 0) {
            throw new CollectionException("Cannot filter because tagline wasn't specified");
        }
        LinkedList<Movie> result = getMoviesCollection().startsWithTagline(args[0]);
        if (result == null || result.size() == 0) {
            throw new CollectionException("None of the collection elements starts with given tagline");
        }
        StringBuilder stringBuilder = new StringBuilder();
        for (Movie movie : result) {
            stringBuilder.append(movie).append("\n");
        }
        return stringBuilder.toString();
    }
}
