package common.commands;

import common.collection.CollectionManagerImpl;
import common.movieclasses.Movie;
import common.collectionexceptions.CollectionException;

import javax.validation.constraints.NotNull;

import java.sql.SQLException;

public class AddCommand extends Command {
    public static final String description = "ADD {element} ... adds new element to collection";
    public static final String tag = "add";

    public AddCommand() {
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
            collectionManager.addMovie(movie, username);
            return "New movie has been added";
        } catch (SQLException e) {
            e.printStackTrace();
            throw new CollectionException("Error while connecting to the database");
        }
//        catch (RuntimeException e) {
//            throw new CollectionException("Movie was not specified");
//        }
    }

}