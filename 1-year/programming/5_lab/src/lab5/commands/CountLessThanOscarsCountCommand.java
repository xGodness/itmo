package lab5.commands;

import lab5.collection.MoviesCollection;

public class CountLessThanOscarsCountCommand extends Command {
    public static final String tag = "count_less_than_oscars_count";
    public static final String description = "COUNT_LESS_THAN_OSCARS_COUNT [oscarsCount] ... returns amount of elements whose oscarsCount's value is smaller than given";

    public CountLessThanOscarsCountCommand(MoviesCollection moviesCollection) {
        super(moviesCollection);
    }

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

    @Override
    public String execute(String[] args) {
        if (args == null || args.length == 0) {
            return "Cannot count because oscarsCount wasn't specified";
        }
        int value;
        try {
            value = Integer.parseInt(args[0]);
        } catch (NumberFormatException e) {
            return "Incorrect input. Integer expected";
        }
        return Integer.valueOf(getMoviesCollection().countLessThanOscarsCount(value)).toString();
    }
}
