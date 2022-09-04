package lab6.collection;

import lab6.IO.IOManager;
import lab6.exceptions.collectionexceptions.CollectionException;
import lab6.exceptions.collectionexceptions.EmptyCollectionException;
import lab6.exceptions.collectionexceptions.IdException;
import lab6.exceptions.collectionexceptions.SaveCollectionException;
import lab6.exceptions.fileexceptions.FilePermissionException;
import lab6.exceptions.fileexceptions.InvalidFileNameException;
import lab6.server.Application;
import lab6.movieclasses.*;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;
import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Collection Manager class
 * Provides interaction with the collection
 */
@XmlRootElement(name = "Collection")
@XmlAccessorType(XmlAccessType.FIELD)
public class CollectionManager implements CollectionManagerImpl {
    private LinkedList<Movie> collection = new LinkedList<>();

    @XmlTransient
    private Application application;
    @XmlTransient
    private IOManager ioManager;

    private String initDateTime;
    private HashMap<Long, Movie> identifiers = new HashMap<>();
    private HashSet<Long> usedIds = new HashSet<>();


    /*________________________________________________________________________________________________________________
                                                    Constructor
    ________________________________________________________________________________________________________________*/
    public CollectionManager() {
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        initDateTime = dateFormatter.format(new Date());
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
        this.application = application;
        this.ioManager = application.getIoManager();
    }

    /*________________________________________________________________________________________________________________
                                                Commands realisation
    ________________________________________________________________________________________________________________*/
    public Movie removeHead() throws EmptyCollectionException {
        if (collection.isEmpty()) {
            throw new EmptyCollectionException("Collection is empty");
        }
        Movie headMovie = collection.getFirst();
        collection.removeFirst();

        return headMovie;
    }

    public void clearCollection() {
        collection.clear();
        identifiers.clear();
        usedIds.clear();
    }


    public void addMovie(Movie movie) {
        Long id = generateNextId();
        movie.setId(id);
        identifiers.put(id, movie);
        usedIds.add(id);
        collection.add(movie);
    }

    public void updateMovie(Long id, Movie movie) throws IdException {
        if (!checkId(id)) {
            throw new IdException("Movie with id " + id + " doesn't exist");
        }
        movie.setId(id);
        int tmpId = collection.indexOf(identifiers.get(id));
        if (tmpId < 1) {
            throw new IdException("Movie with id " + id + " doesn't exist");
        }
        collection.set(
                collection.indexOf(identifiers.get(id)),
                movie
        );
        identifiers.replace(id, movie);
    }


    public void removeMovie(Long id) throws IdException {
        if (!checkId(id)) {
            throw new IdException("Movie with id " + id + " doesn't exist");
        }
        collection.remove(identifiers.get(id));
        identifiers.remove(id);
        usedIds.remove(id);
    }

    public void saveCollection() throws SaveCollectionException, FileNotFoundException, FilePermissionException, InvalidFileNameException {
        application.saveCollection();
    }

    public Movie maxByScreenwriter() throws CollectionException {
        if (collection.isEmpty()) {
            throw new CollectionException("Collection is empty");
        }
        return Collections.max(
                collection,
                Comparator.comparing(Movie::getScreenwriter)
        );
    }

    public boolean addIfMax(Movie movie) {

        int compResult;
        try {
            compResult = movie.compareTo(maxByScreenwriter());
            if (compResult > 0) {
                addMovie(movie);
                return true;
            }
            return false;
        } catch (CollectionException e) {
            addMovie(movie);
            return true;
        }

    }

    public int countLessThanOscarsCount(int oscarsValue) throws EmptyCollectionException {
        if (collection.isEmpty()) {
            throw new EmptyCollectionException("Collection is empty");
        }
        if (oscarsValue < 1) return 0;
        int cnt = 0;
        for (Movie movie : collection) {
            if (movie.getOscarsCount() == null || movie.getOscarsCount() < oscarsValue) {
                cnt++;
            }
        }
        return cnt;
    }

    public LinkedList<Movie> startsWithTagline(String taglineValue) {
        LinkedList<Movie> result = new LinkedList<>();
        for (Movie movie : collection) {
            if (movie.startsWithTagline(taglineValue)) {
                result.add(movie);
            }
        }
        return result;
    }

    public void removeLower(Movie movie) throws CollectionException {
        if (collection.isEmpty()) {
            throw new EmptyCollectionException("Collection is empty");
        }
        for (Movie m : collection) {
            if (m.compareTo(movie) > 0) {
                collection.remove(movie);
            }
        }
    }


    /*________________________________________________________________________________________________________________
                                                ID methods
    ________________________________________________________________________________________________________________*/

    /**
     * Methods to check whether given id has already been used.
     *
     * @param id id to check
     * @return "true" if given id has already been used
     */
    public boolean checkId(Long id) {
        if (id == null || id < 1) {
            return false;
        }
        return usedIds.contains(id);
    }

    /**
     * Method to generate next non-used id.
     *
     * @return Generated id
     */
    private Long generateNextId() {
        Long id;
        if (usedIds.isEmpty()) {
            id = 1L;
        } else {
            id = Collections.max(usedIds);
            do {
                id++;
            } while (usedIds.contains(id));
        }
//        updateSortedCollection();
        return id;
    }

    /*________________________________________________________________________________________________________________
                                                    Sorting
    ________________________________________________________________________________________________________________*/

//    public void updateSortedCollection() {
//        sortedCollection = (LinkedList<Movie>) collection.clone();
//        sortedCollection.sort(Movie::compareTo);
//    }

    /*________________________________________________________________________________________________________________
                                                    Getters
    ________________________________________________________________________________________________________________*/
    public LinkedList<Movie> getCollection() {
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

    public HashSet<Long> getUsedIds() {
        return usedIds;
    }

    public boolean isEmpty() {
        return collection.isEmpty();
    }

    /*________________________________________________________________________________________________________________
                                                    Setters
    ________________________________________________________________________________________________________________*/

    public void setCollection(LinkedList<Movie> collection) {
        this.collection = collection;
    }

    public void setUsedIds(HashSet<Long> usedIds) {
        this.usedIds = usedIds;
    }

    public void setIdentifiers(HashMap<Long, Movie> identifiers) {
        this.identifiers = identifiers;
    }

}
