package common.collection;

import common.movieclasses.Movie;
import common.databaseexceptions.DatabaseException;
import common.collectionexceptions.CollectionException;

import java.sql.SQLException;
import java.util.LinkedList;
import java.util.concurrent.ConcurrentSkipListSet;

public interface CollectionManagerImpl {
    void addMovie(Movie movie, String username) throws SQLException, CollectionException;
    Movie removeHead(String username) throws SQLException, DatabaseException;
    void clearCollection(String username) throws SQLException;
    void updateMovie(Long id, Movie movie, String username) throws SQLException, DatabaseException;
    void removeMovie(Long id, String username) throws  SQLException, DatabaseException;
    boolean addIfMax(Movie movie, String username) throws SQLException, DatabaseException;
    Movie maxByScreenwriter() throws CollectionException, DatabaseException;
    int removeLower(Movie movie, String username) throws SQLException, DatabaseException;
    int countLessThanOscarsCount(int oscarsValue) throws DatabaseException;
    LinkedList<Movie> startsWithTagline(String taglineValue);
    int getCollectionSize();
    boolean isEmpty();
    ConcurrentSkipListSet<Movie> getCollection();
    String getInitDateTime();
}
