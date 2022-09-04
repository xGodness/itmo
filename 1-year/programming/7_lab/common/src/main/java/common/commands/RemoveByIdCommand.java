package common.commands;

import common.collection.CollectionManagerImpl;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;
import javax.validation.constraints.NotNull;
import common.collectionexceptions.IdException;

import java.sql.SQLException;

public class RemoveByIdCommand extends Command {
    public static final String tag = "remove_by_id";
    public static final String description =
            "REMOVE_BY_ID [id] ... removes element with given id if it is owned by current user";

    public RemoveByIdCommand() {
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
            long id = Long.parseLong((String) args[0]);
            if (id <= 0) {
                throw new IdException("Incorrect input. Positive integer expected");
            }
            collectionManager.removeMovie(id, username);
            return "Movie with id " + id + "  has been removed";

        } catch (DatabaseException e) {
            throw new CollectionException(e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            throw new CollectionException("Error while connecting to the database");
        } catch (NumberFormatException e) {
            throw new CollectionException("Incorrect input. Positive integer expected");
        }
    }

}
