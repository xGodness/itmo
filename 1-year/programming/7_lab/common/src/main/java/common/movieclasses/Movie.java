package common.movieclasses;

import common.movieclasses.enums.MpaaRating;
import common.movieclasses.enums.MovieGenre;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Movie class that collection is storing
 */

public class Movie
        implements Comparable<Movie>, Serializable {

    private long id;
    private String name;
    private Coordinates coordinates;
    private LocalDateTime creationDate;
    private Integer oscarsCount;
    private String tagline;
    private MovieGenre genre;
    private MpaaRating mpaaRating;
    private Person screenwriter;
    private String ownerUsername;

    private String creationDateString;

    public Movie() {
    }

    public Movie(String name, Coordinates coordinates, LocalDateTime creationDate, Integer oscarsCount,
                 String tagline, MovieGenre genre, MpaaRating mpaaRating, Person screenwriter, String ownerUsername) {
        this.name = name;
        this.coordinates = coordinates;
        this.creationDate = creationDate;
        this.oscarsCount = oscarsCount;
        this.tagline = tagline;
        this.genre = genre;
        this.mpaaRating = mpaaRating;
        this.screenwriter = screenwriter;
        this.ownerUsername = ownerUsername;
        creationDateString = creationDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    public boolean startsWithTagline(String taglineValue) {
        return tagline != null && tagline.startsWith(taglineValue);
    }

    @Override
    public int compareTo(Movie m) {
        return (int) (id - m.getId());
    }

    @Override
    public String toString() {
        return "____________________________________________\n" +
                "| Movie \"" + name + "\"\n" +
                "| Owned by user \"" + ownerUsername + "\"\n" +
                "|___________________________________________\n" +
                "| ID            : " + id + "\n" +
                "| Coordinates     \n" + coordinates +
                "| Creation date : " + creationDateString + "\n" +
                "| Oscars count  : " + ((oscarsCount == null) ? "" : oscarsCount) + "\n" +
                "| Tagline       : " + ((tagline == null) ? "" : tagline) + "\n" +
                "| Genre         : " + genre + "\n" +
                "| MPAA rating   : " + mpaaRating + "\n" +
                "| Screenwriter    \n" + screenwriter + "\n" +
                "|___________________________________________\n";
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Coordinates getCoordinates() {
        return coordinates;
    }

    public void setCoordinates(Coordinates coordinates) {
        this.coordinates = coordinates;
    }

    public LocalDateTime getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(LocalDateTime creationDate) {
        this.creationDate = creationDate;
    }

    public Integer getOscarsCount() {
        return oscarsCount;
    }

    public void setOscarsCount(Integer oscarsCount) {
        this.oscarsCount = oscarsCount;
    }

    public String getTagline() {
        return tagline;
    }

    public void setTagline(String tagline) {
        this.tagline = tagline;
    }

    public MovieGenre getGenre() {
        return genre;
    }

    public void setGenre(MovieGenre genre) {
        this.genre = genre;
    }

    public MpaaRating getMpaaRating() {
        return mpaaRating;
    }

    public void setMpaaRating(MpaaRating mpaaRating) {
        this.mpaaRating = mpaaRating;
    }

    public Person getScreenwriter() {
        return screenwriter;
    }

    public void setScreenwriter(Person screenwriter) {
        this.screenwriter = screenwriter;
    }

    public String getOwnerUsername() {
        return ownerUsername;
    }

    public void setOwnerUsername(String ownerUsername) {
        this.ownerUsername = ownerUsername;
    }
}
