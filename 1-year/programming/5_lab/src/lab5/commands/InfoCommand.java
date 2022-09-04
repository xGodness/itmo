package lab5.commands;

import lab5.collection.MoviesCollection;

public class InfoCommand extends Command {
    public static final String tag = "info";
    public static final String description = "INFO ... provides information about collection";

    public InfoCommand(MoviesCollection collection) {
        super(collection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) {
        return
                        "Collection type     : " + super.getMoviesCollection().getCollection().getClass() + "\n" +
                        "Initialization date : " + super.getMoviesCollection().getInitDateTime() + "\n" +
                        "Collection size     : " + super.getMoviesCollection().getCollectionSize();
    }

}
