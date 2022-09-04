package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;

import java.sql.SQLException;

public class RemoveLowerCommand extends Command {
    public static final String tag = "remove_lower";
    public static final String description = "REMOVE_LOWER {element} ... removes all collection's elements that are smaller than given element";

    public RemoveLowerCommand() {
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
            Movie movie = (Movie) args[0];
            return "Successfully removed " + collectionManager.removeLower(movie, username) + " movies";
        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        } catch (SQLException e) {
            throw new CollectionException("Error while connecting to the database");
        } catch (RuntimeException e) {
            throw new CollectionException("Movie was not specified");
        }
    }
}
