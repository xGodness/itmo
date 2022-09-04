package common.movieclasses;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import java.io.Serializable;

@XmlAccessorType(XmlAccessType.FIELD)
public class Location implements Comparable<Location>, Serializable {

    private int x;
    private double y;
    private String name;

    public Location() {
    }

    public Location(int x, double y, String name) {
        this.x = x;
        this.y = y;
        this.name = name;
    }

    public int getX() {
        return x;
    }

    public void setX(int x) {
        this.x = x;
    }

    public double getY() {
        return y;
    }

    public void setY(double y) {
        this.y = y;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public int compareTo(Location l) {
        if (name == null && l.getName() == null) return 0;
        if (name == null) return l.getName().compareTo("");
        if (l.getName() == null) return name.compareTo("");
        return name.compareTo(l.getName());
    }

    @Override
    public String toString() {
        return "| \t\tName    : " + name + "\n" +
                "| \t\tX       : " + x + "\n" +
                "| \t\tY       : " + y;
    }
}
