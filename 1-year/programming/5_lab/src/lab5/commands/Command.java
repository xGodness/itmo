package lab5.commands;

import lab5.collection.MoviesCollection;

/**
 * Abstract command class
 */

public abstract class Command implements CommandImpl {
    public static final String description = "";
    public static final String tag = "";

    private MoviesCollection moviesCollection;

    public Command(MoviesCollection moviesCollection) {
        this.moviesCollection = moviesCollection;
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    public MoviesCollection getMoviesCollection() {
        return moviesCollection;
    }
}
