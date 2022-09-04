package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.CollectionException;
import lab5.movie_classes.Movie;

public class MaxByScreenwriterCommand extends Command {
    public static final String tag = "max_by_screenwriter";
    public static final String description = "MAX_BY_SCREENWRITER ... shows element with the biggest screenwriter field value";

    public MaxByScreenwriterCommand(MoviesCollection moviesCollection) {
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
        Movie result = getMoviesCollection().maxByScreenwriter();
        if (result == null) {
            throw new CollectionException("Collection is empty");
        }
        return result.toString();
    }
}
