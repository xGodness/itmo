package lab5.commands;

import lab5.collection.MoviesCollection;

public class AddCommand extends Command {
    public static final String description = "ADD {element} ... adds new element to collection";
    public static final String tag = "add";

    public AddCommand(MoviesCollection moviesCollection) {
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
        super.getMoviesCollection().addMovie();
        return "New movie has been added";
    }

}