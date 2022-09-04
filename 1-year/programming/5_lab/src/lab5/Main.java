package lab5;

import lab5.app.Application;

/**
 * @author xGodness
 */

public class Main {
    public static void main(String[] args) {
        String fileName = null;

        if (args.length != 0) {
            fileName = args[0];
        }

        Application application = new Application();
        application.loadCollection(fileName);

        application.consoleStart();


    }

}

