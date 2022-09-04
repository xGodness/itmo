package lab5.commands;

import lab5.collection.MoviesCollection;

public class ClearCommand extends Command {
    public static final String tag = "clear";
    public static final String description = "CLEAR ... clears the collection";

    public ClearCommand(MoviesCollection moviesCollection) {
        super(moviesCollection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) {
        getMoviesCollection().clearCollection();
        return "Collection has been cleared";
    }

}