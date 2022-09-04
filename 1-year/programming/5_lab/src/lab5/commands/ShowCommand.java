package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.CollectionException;
import lab5.movie_classes.Movie;

public class ShowCommand extends Command {
    public static final String tag = "show";
    public static final String description = "SHOW ... shows all collection's elements";

    public ShowCommand(MoviesCollection moviesCollection) {
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
        MoviesCollection moviesCollection = super.getMoviesCollection();
        if (moviesCollection.getCollectionSize() == 0) {
            throw new CollectionException("Collection is empty");
        }
        StringBuilder result = new StringBuilder();
        for (Movie movie : moviesCollection.getCollection()) {
            result.append(movie.toString()).append("\n");
        }
        return result.toString().trim();
    }


}
