package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

import java.util.LinkedList;
import java.util.stream.Collectors;

public class FilterStartsWithTaglineCommand extends Command {
    public static final String tag = "filter_starts_with_tagline";
    public static final String description = "FILTER_STARTS_WITH_TAGLINE [tagline] ... shows element whose tagline field starts with given substring";

    public FilterStartsWithTaglineCommand() {
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
        try {
            String tagline = (String) args[0];
            LinkedList<Movie> result = collectionManager.startsWithTagline(tagline);
            if (result == null || result.size() == 0) {
                throw new CollectionException("None of the collection elements starts with given tagline");
            }
            return result.stream()
                    .map(Movie::toString)
                    .collect(Collectors.joining("\n"));
        } catch (RuntimeException e) {
            throw new CollectionException("Tagline was not specified");
        }

    }
}
