package lab5.commands;

import lab5.collection.MoviesCollection;

public class SaveCommand extends Command {
    public static final String tag = "save";
    public static final String description = "SAVE ... saves collection to the file";

    public SaveCommand(MoviesCollection moviesCollection) {
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
        super.getMoviesCollection().saveCollection();
        return "Collection has been saved";
    }


}
