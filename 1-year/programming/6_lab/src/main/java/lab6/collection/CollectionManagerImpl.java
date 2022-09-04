package lab6.collection;

import lab6.exceptions.collectionexceptions.CollectionException;
import lab6.exceptions.fileexceptions.FileException;
import lab6.movieclasses.Movie;

import java.io.FileNotFoundException;
import java.util.LinkedList;

public interface CollectionManagerImpl {
    Movie removeHead() throws CollectionException;
    void clearCollection();
    void addMovie(Movie movie);
    void updateMovie(Long id, Movie movie) throws CollectionException;
    void removeMovie(Long id) throws CollectionException;
    void saveCollection() throws CollectionException, FileException, FileNotFoundException;
    Movie maxByScreenwriter() throws CollectionException;
    boolean addIfMax(Movie movie);
    int countLessThanOscarsCount(int oscarsValue) throws CollectionException;
    LinkedList<Movie> startsWithTagline(String taglineValue);
    void removeLower(Movie movie) throws CollectionException;
    int getCollectionSize();
    boolean isEmpty();
    LinkedList<Movie> getCollection();
    String getInitDateTime();
    boolean checkId(Long id);
}
