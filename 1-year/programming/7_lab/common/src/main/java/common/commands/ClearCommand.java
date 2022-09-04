package common.commands;

import common.collection.CollectionManagerImpl;

import javax.validation.constraints.NotNull;
import common.collectionexceptions.CollectionException;

import java.sql.SQLException;

public class ClearCommand extends Command {
    public static final String tag = "clear";
    public static final String description = "CLEAR ... removes all movies in the collection owned by user";

    public ClearCommand() {
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
            collectionManager.clearCollection(username);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new CollectionException("Error while connecting to the database");
        }
        return "Collection has been cleared";
    }

}