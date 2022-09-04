package lab6.movieclasses;

import lab6.movieclasses.enums.MpaaRating;
import lab6.movieclasses.enums.MovieGenre;
import lab6.server.jaxbadapters.LocalDateTimeAdapter;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Movie class that collection is storing
 */

@XmlAccessorType(XmlAccessType.FIELD)
public class Movie
        implements Comparable<Movie>, Serializable {

    private long id;
    private String name;
    private Coordinates coordinates;
    @XmlJavaTypeAdapter(LocalDateTimeAdapter.class)
    private LocalDateTime creationDate;
    private Integer oscarsCount;
    private String tagline;
    private MovieGenre genre;
    private MpaaRating mpaaRating;
    private Person screenwriter;

    private String creationDateString;

    public Movie() {
    }

    public Movie(String name, Coordinates coordinates, LocalDateTime creationDate, Integer oscarsCount,
                 String tagline, MovieGenre genre, MpaaRating mpaaRating, Person screenwriter) {
        this.name = name;
        this.coordinates = coordinates;
        this.creationDate = creationDate;
        this.oscarsCount = oscarsCount;
        this.tagline = tagline;
        this.genre = genre;
        this.mpaaRating = mpaaRating;
        this.screenwriter = screenwriter;

//        DateTimeFormatter dateFormatter = new Date("dd/MM/yyyy HH:mm:ss");
        creationDateString = creationDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    public boolean startsWithTagline(String taglineValue) {
        return tagline != null && tagline.startsWith(taglineValue);
    }

    @Override
    public int compareTo(Movie m) {
        return coordinates.compareTo(m.getCoordinates());
    }

    @Override
    public String toString() {
        return "____________________________________________\n" +
                "| Movie \"" + name + "\":\n" +
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

    // Getters

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


}
