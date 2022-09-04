package server;

import common.collection.CollectionManagerImpl;
import common.collectionexceptions.CollectionException;
import common.movieclasses.Movie;
import common.IO.IOManager;
import server.database.DBManager;
import common.databaseexceptions.DatabaseException;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.stream.Collectors;

/**
 * Collection Manager class
 * Provides interaction tools for the collection
 */
public class CollectionManager implements CollectionManagerImpl {
//    private LinkedList<Movie> collection = new LinkedList<>();
    private ConcurrentSkipListSet<Movie> collection = new ConcurrentSkipListSet<>();

    private IOManager ioManager;
    private DBManager dbManager;

    private final String initDateTime;


    /*________________________________________________________________________________________________________________
                                                    Constructor
    ________________________________________________________________________________________________________________*/
    public CollectionManager() {
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        initDateTime = dateFormatter.format(new Date());
    }

    public CollectionManager(ConcurrentSkipListSet<Movie> collection) {
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        initDateTime = dateFormatter.format(new Date());
        this.collection = collection;
    }

    /*________________________________________________________________________________________________________________
                                                    Setup
    ________________________________________________________________________________________________________________*/

    /**
     * Method to bind collection with application.
     *
     * @param application Application instance to connect with
     */
    public void setup(Application application) {
        this.ioManager = application.getIoManager();
        this.dbManager = application.getDbManager();
    }

    /*________________________________________________________________________________________________________________
                                                Commands realisation
    ________________________________________________________________________________________________________________*/

    public void addMovie(Movie movie, String username) throws SQLException, CollectionException {
        if (collection.size() >= 100) {
            throw new CollectionException("Unable to add movie: collection size limit has been reached (100 movies)");
        }
        dbManager.add(movie, username);
        collection.add(movie);
    }
    public Movie removeHead(String username) throws SQLException, DatabaseException {
        Movie movie = dbManager.removeHead(username);
        collection.remove(movie);
        return movie;
    }

    public void clearCollection(String username) throws SQLException {
        dbManager.clear(username);
        Set<Movie> moviesToRemove = collection.stream()
                .filter(m -> m.getOwnerUsername().equals(username))
                .collect(Collectors.toSet());
        collection.removeAll(moviesToRemove);
    }

    public void updateMovie(Long id, Movie movie, String username) throws SQLException, DatabaseException {
        dbManager.update(movie, id, username);
        Movie target = collection.stream()
                .filter(m -> m.getId() == id)
                .findFirst()
                .get();
        collection.remove(target);
        collection.add(movie);
    }

    public void removeMovie(Long id, String username) throws SQLException, DatabaseException {
        dbManager.remove(id, username);
        collection.remove(
                collection.stream()
                        .filter(m -> m.getId() == id)
                        .findFirst()
                        .get()
        );
    }

    public boolean addIfMax(Movie movie, String username) throws SQLException, DatabaseException {
        if (movie.compareTo(maxByScreenwriter()) > 0) {
            dbManager.add(movie, username);
            collection.add(movie);
            return true;
        }
        return false;
    }

    public int removeLower(Movie movie, String username) throws SQLException, DatabaseException {
        int removedCount = dbManager.removeLower(movie, username);
        if (removedCount == 0) {
            throw new DatabaseException("There are no movies lower than given and owned by user \"" + username + "\"");
        }
        Set<Movie> moviesToRemove = collection.stream()
                .filter(m -> m.getOwnerUsername().equals(username))
                .collect(Collectors.toSet());
        collection.removeAll(moviesToRemove);
        return removedCount;
    }

    public Movie maxByScreenwriter() throws DatabaseException {
        if (collection.isEmpty()) {
            throw new DatabaseException("Collection is empty");
        }
        return Collections.max(
                collection,
                Comparator.comparing(Movie::getScreenwriter)
        );
    }

    public int countLessThanOscarsCount(int oscarsValue) throws DatabaseException {
        if (collection.isEmpty()) {
            throw new DatabaseException("Collection is empty");
        }
        if (oscarsValue < 1) {
            return 0;
        }
        return (int) collection.stream()
                .filter(m -> {
                    Integer cnt = m.getOscarsCount();
                    return  cnt == null || cnt < oscarsValue;
                })
                .count();
    }

    public LinkedList<Movie> startsWithTagline(String taglineValue) {
        return collection.stream()
                .filter(m -> m.startsWithTagline(taglineValue))
                .collect(Collectors.toCollection(LinkedList<Movie>::new));
    }


    /*________________________________________________________________________________________________________________
                                                    Getters
    ________________________________________________________________________________________________________________*/
    public ConcurrentSkipListSet<Movie> getCollection() {
        return collection;
    }

    public IOManager getIOManager() {
        return ioManager;
    }

    public String getInitDateTime() {
        return initDateTime;
    }

    public int getCollectionSize() {
        return collection.size();
    }

    public boolean isEmpty() {
        return collection.isEmpty();
    }

    /*________________________________________________________________________________________________________________
                                                    Setters
    ________________________________________________________________________________________________________________*/

    public void setCollection(ConcurrentSkipListSet<Movie> collection) {
        this.collection = collection;
    }

}
