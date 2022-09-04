package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.collectionexceptions.CollectionException;

import javax.validation.constraints.NotNull;

import java.util.LinkedList;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.stream.Collectors;

public class ShowCommand extends Command {
    public static final String tag = "show";
    public static final String description = "SHOW ... shows all collection's elements";

    public ShowCommand() {
        super();
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(@NotNull CollectionManagerImpl collectionManager, Object[] args, String username) throws CollectionException {
        if (collectionManager.getCollectionSize() == 0) {
            throw new CollectionException("Collection is empty");
        }
        ConcurrentSkipListSet<Movie> collection = (collectionManager.getCollection());
//        collection.sort(Movie::compareTo);
        return collection.stream()
                .map(m -> m.toString().trim())
                .collect(Collectors.joining("\n"));
    }


}
