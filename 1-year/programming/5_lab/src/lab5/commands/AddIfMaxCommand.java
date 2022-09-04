package lab5.commands;

import lab5.collection.MoviesCollection;

public class AddIfMaxCommand extends Command {
    public static final String tag = "add_if_max";
    public static final String description = "ADD_IF_MAX {element} ... adds new element to collection if it's value is bigger than biggest element in collection";

    public AddIfMaxCommand(MoviesCollection moviesCollection) {
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
        return getMoviesCollection().addIfMax() ? "New movie has been added" : "Specified movie has not added";
    }

}
