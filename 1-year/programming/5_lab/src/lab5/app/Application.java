package lab5.app;

import lab5.IO.IOManager;
import lab5.collection.MoviesCollection;
import lab5.commands.Command;
import lab5.exceptions.collection_exceptions.CollectionException;
import lab5.exceptions.collection_exceptions.LoadCollectionException;
import lab5.exceptions.collection_exceptions.SaveCollectionException;
import lab5.exceptions.file_exceptions.CannotCreateFileException;
import lab5.exceptions.file_exceptions.FileAlreadyExistsException;
import lab5.exceptions.file_exceptions.FilePermissionException;
import lab5.exceptions.file_exceptions.InvalidFileNameException;
import lab5.movie_classes.Movie;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.LinkedList;

/**
 * Class-connector. Operates all others classes presented in code.
 */


public class Application {
    private IOManager ioManager;
    private MoviesCollection moviesCollection;
    private FileManager fileManager;
    private ConsoleManager consoleManager;
    private Invoker invoker;

    private String currentFileName;

    /*________________________________________________________________________________________________________________
                                                    Constructor
    ________________________________________________________________________________________________________________*/

    public Application() {
        this.ioManager = new IOManager();
        this.moviesCollection = null;
        this.fileManager = new FileManager(this);
        this.invoker = new Invoker(this);
    }

    /*________________________________________________________________________________________________________________
                                               Load or save collection
    ________________________________________________________________________________________________________________*/

    /**
     * Loads collection from the file.
     * Will be running until collection is loaded.
     *
     * @param fileName  Name of the file to load from
     */
    public void loadCollection(String fileName) {
        currentFileName = fileName;
        boolean collectionWasLoaded = false;
        while (!collectionWasLoaded) {
            try {
                MoviesCollection rawMoviesCollection = fileManager.load(currentFileName);
                LinkedList<Movie> rawCollection = rawMoviesCollection.getCollection();
                LinkedList<Movie> wrongMovies = new LinkedList<>();
                for (int i = 0; i < rawCollection.size(); i++) {
                    if (wrongMovies.contains(rawCollection.get(i))) continue;
                    if (rawCollection.get(i).getId() < 1) {
                        wrongMovies.add(rawCollection.get(i));
                        continue;
                    }
                    for (int j = i + 1; j < rawCollection.size(); j++) {
                        if (wrongMovies.contains(rawCollection.get(j))) continue;
                        if (rawCollection.get(i).getId() == rawCollection.get(j).getId()) {
                            wrongMovies.add(rawCollection.get(j));
                        }
                    }
                }
                if (wrongMovies.size() != 0) {
                    ioManager.printlnStatus("Corrupted elements were found. Fixing the file...");
                }
                rawCollection.removeAll(wrongMovies);
                moviesCollection = rawMoviesCollection;

                moviesCollection.setup(this);
                ioManager.printlnSuccess("Collection has been loaded from \"" + currentFileName + "\"");
                collectionWasLoaded = true;
            } catch (InvalidFileNameException | FilePermissionException | LoadCollectionException e) {
                ioManager.printlnErr(e.getMessage());
                currentFileName = fetchFileName();
            } catch (FileNotFoundException e) {
                ioManager.printlnErr(e.getMessage());
                boolean fileWasCreated = createBlankFile(currentFileName);
                if (fileWasCreated) {
                    moviesCollection = new MoviesCollection();
                    moviesCollection.setup(this);
                    collectionWasLoaded = true;
                } else {
                    currentFileName = fetchFileName();
                }
            }
        }
    }

    /**
     * Saves collection to the file application is currently working with.
     * File name should already been presented in Application class (field "currentFileName").
     */
    public void saveCollection() {
        boolean collectionWasSaved = false;
        while (!collectionWasSaved) {
            ioManager.printlnStatus("Saving to \"" + currentFileName + "\"...");
            try {
                fileManager.save(moviesCollection, currentFileName);
                collectionWasSaved = true;
            } catch (InvalidFileNameException | FilePermissionException | SaveCollectionException e) {
                ioManager.printlnErr(e.getMessage());
                currentFileName = fetchFileName();
            } catch (FileNotFoundException e) {
                ioManager.printlnErr(e.getMessage());
                createBlankFile(currentFileName);
            }
        }
    }

    /*________________________________________________________________________________________________________________
                                                Auxiliary methods
    ________________________________________________________________________________________________________________*/

    /**
     * Creates blank file in case file with specified name does not exist.
     *
     * @param fileName  Name of the file to create
     * @return  "true" if file was created and "false" otherwise
     */
    private boolean createBlankFile(String fileName) {
        String response = null;
        while (response == null
                || !(response.equalsIgnoreCase("y")
                || response.equalsIgnoreCase("n"))) {

            response = ioManager.getNextInput(
                    "Would you like to create new blank file \"" + currentFileName + "\"? (y/n): ");
        }

        if (response.equalsIgnoreCase("y")) {
            try {
                fileManager.create(fileName);
                currentFileName = fileName;
                return true;
            } catch (
                    InvalidFileNameException | IOException | FileAlreadyExistsException
                            | FilePermissionException | CannotCreateFileException e) {
                ioManager.printlnErr(e.getMessage());
            }
        }
        return false;
    }

    private String fetchFileName() {
        return ioManager.getNextInput("Specify file name: ");
    }

    public boolean isStringValid(String string) {
        return ioManager.isStringValid(string);
    }



    /*________________________________________________________________________________________________________________
                                                     Initializers
    ________________________________________________________________________________________________________________*/

    /**
     * Launches Console Manager for further work.
     */
    public void consoleStart() {
        if (moviesCollection == null) {
            ioManager.printlnErr("Collection not presented");
            return;
        }
        this.consoleManager = new ConsoleManager(this);
        consoleManager.execute();
    }




    /*________________________________________________________________________________________________________________
                                                        Getters
    ________________________________________________________________________________________________________________*/

    /**
     * @return  Application's IOManager
     */
    public IOManager getIoManager() {
        return ioManager;
    }

    /**
     * @return  Application's MoviesCollection
     */
    public MoviesCollection getMoviesCollection() {
        return moviesCollection;
    }

    /**
     * @return  Application's FileManager
     */
    public FileManager getFileManager() {
        return fileManager;
    }


    /*________________________________________________________________________________________________________________
                                                   Execute command
    ________________________________________________________________________________________________________________*/

    /**
     * Sets command to invoker and makes it to execute.
     *
     * @param command               Command to execute
     * @param args                  Command arguments (necessary, can be null)
     * @return                      Execution result
     * @throws CollectionException  Exception thrown during executing the command
     */
    public String executeCommand(Command command, String[] args) throws CollectionException {
        invoker.setCommand(command, args);
        return invoker.executeCommand();
    }

}
