package lab5.commands;

import lab5.collection.MoviesCollection;
import lab5.exceptions.collection_exceptions.IdException;

public class UpdateCommand extends Command {
    public static final String tag = "update";
    public static final String description = "UPDATE [id] {element} ... updates element with given id";

    public UpdateCommand(MoviesCollection moviesCollection) {
        super(moviesCollection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) throws IdException {
        if (args == null || args.length == 0) {
            throw new IdException("Cannot update by id because id wasn't specified");
        }
        try {
            Long id = Long.valueOf(args[0]);
            if (id <= 0) {
                throw new IdException("Incorrect input. Positive integer expected");
            }

            if (!getMoviesCollection().checkId(id)) {
                throw new IdException("Movie with such id doesn't exist");
            }

            getMoviesCollection().updateMovie(id);
            return "Movie with id " + id + " has been updated";


        } catch (NumberFormatException e) {
            throw new IdException("Incorrect input. Positive integer expected");
        }
    }

}
