package common.commands;

import java.io.Serializable;

/**
 * Abstract command class
 */

public abstract class Command implements CommandImpl, Serializable {
    public static final String description = "";
    public static final String tag = "";

    public Command() {}

    public static String getTag() {
        return tag;
    }

    public static String getDescription() {
        return description;
    }

}
