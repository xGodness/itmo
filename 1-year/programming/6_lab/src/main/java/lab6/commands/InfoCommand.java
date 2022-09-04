package lab6.commands;

import lab6.collection.CollectionManagerImpl;
import lab6.exceptions.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

public class InfoCommand extends Command {
    public static final String tag = "info";
    public static final String description = "INFO ... provides information about collection";

    public InfoCommand() {
        super();
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(@NotNull CollectionManagerImpl moviesCollection, Object[] args) throws CollectionException {
        if (moviesCollection.isEmpty()) throw new CollectionException("Collection is empty");
        return
                "Collection type     : " + moviesCollection.getCollection().getClass() + "\n" +
                "Initialization date : " + moviesCollection.getInitDateTime() + "\n" +
                "Collection size     : " + moviesCollection.getCollectionSize();
    }

}
