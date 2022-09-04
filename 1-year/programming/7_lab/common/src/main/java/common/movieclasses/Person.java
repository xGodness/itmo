package common.movieclasses;

import common.movieclasses.enums.Country;
import common.movieclasses.enums.EyeColor;
import common.movieclasses.enums.HairColor;

import java.io.Serializable;
import java.time.LocalDate;

public class Person
        implements Comparable<Person>, Serializable {

    private String name;
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
        return "| \tName        : " + name + "\n" +
                "| \tBirthday    : " + ((birthday == null) ? "" : birthday) + "\n" +
                "| \tEye color   : " + eyeColor + "\n" +
                "| \tHair color  : " + hairColor + "\n" +
                "| \tNationality : " + nationality + "\n" +
                "| \tLocation      \n" + location;
    }
}
