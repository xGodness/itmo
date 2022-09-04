package lab5.movie_classes;

import lab5.app.LocalDateAdapter;
import lab5.movie_classes.enums.Country;
import lab5.movie_classes.enums.EyeColor;
import lab5.movie_classes.enums.HairColor;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import java.time.LocalDate;

@XmlAccessorType(XmlAccessType.FIELD)
public class Person
        implements Comparable<Person> {

    private String name;
    @XmlJavaTypeAdapter(LocalDateAdapter.class)
    private LocalDate birthday;
    private EyeColor eyeColor;
    private HairColor hairColor;
    private Country nationality;
    private Location location;

    public Person() {
    }

    public Person(String name, LocalDate birthday, EyeColor eyeColor, HairColor hairColor, Country nationality, Location location) {
        this.name = name;
        this.birthday = birthday;
        this.eyeColor = eyeColor;
        this.hairColor = hairColor;
        this.nationality = nationality;
        this.location = location;
    }

    @Override
    public int compareTo(Person p) {
        return nationality.toString().compareTo(p.getNationality().toString());
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public LocalDate getBirthday() {
        return birthday;
    }

    public void setBirthday(LocalDate birthday) {
        this.birthday = birthday;
    }

    public EyeColor getEyeColor() {
        return eyeColor;
    }

    public void setEyeColor(EyeColor eyeColor) {
        this.eyeColor = eyeColor;
    }

    public HairColor getHairColor() {
        return hairColor;
    }

    public void setHairColor(HairColor hairColor) {
        this.hairColor = hairColor;
    }

    public Country getNationality() {
        return nationality;
    }

    public void setNationality(Country nationality) {
        this.nationality = nationality;
    }

    public Location getLocation() {
        return location;
    }

    public void setLocation(Location location) {
        this.location = location;
    }

    @Override
    public String toString() {
        return  "| \tName        : " + name + "\n" +
                "| \tBirthday    : " + ((birthday == null) ? "" : birthday) + "\n" +
                "| \tEye color   : " + eyeColor + "\n" +
                "| \tHair color  : " + hairColor + "\n" +
                "| \tNationality : " + nationality + "\n" +
                "| \tLocation      \n" + location;
    }
}
