package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;

import javax.validation.constraints.NotNull;

import java.sql.SQLException;

public class AddIfMaxCommand extends Command {
    public static final String tag = "add_if_max";
    public static final String description = "ADD_IF_MAX {element} ... adds new element to collection if it's value is bigger than biggest element in collection";

    public AddIfMaxCommand() {
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
            return collectionManager.addIfMax(movie, username) ? "New movie has been added" : "Specified movie has not been added";
        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            throw new CollectionException("Error while connecting to the database");
        } catch (RuntimeException e) {
            throw new CollectionException("Movie was not specified");
        }
    }

}
