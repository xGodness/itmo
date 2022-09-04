package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;
import common.collectionexceptions.IdException;

import java.sql.SQLException;

public class UpdateCommand extends Command {
    public static final String tag = "update";
    public static final String description = "UPDATE [id] {element} ... updates element with given id";

    public UpdateCommand() {
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
            Long id = Long.valueOf((String) args[0]);
            Movie movie = (Movie) args[1];
            collectionManager.updateMovie(id, movie, username);
            return "Movie with id " + id + " has been updated";
        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            throw new CollectionException("Error while connecting to the database");
        } catch (RuntimeException e) {
            throw new IdException("Incorrect input. Positive integer and movie expected");
        }
    }
}
