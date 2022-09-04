package common.movieclasses;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import java.io.Serializable;

@XmlAccessorType(XmlAccessType.FIELD)
public class Coordinates implements Comparable<Coordinates>, Serializable {
    private Double x;
    private Float y;

    public Coordinates() {
    }

    public Coordinates(Double x, Float y) {
        this.x = x;
        this.y = y;
    }

    public Double getX() {
        return x;
    }

    public void setX(Double x) {
        this.x = x;
    }

    public Float getY() {
        return y;
    }

    public void setY(Float y) {
        this.y = y;
    }

    @Override
    public int compareTo(Coordinates c) {
        if (c == null) return (int) (x + y);
        return (int) (x + y - c.getX() - c.getY());
    }

    @Override
    public String toString() {
        return
                "| \tX           : " + x + "\n" +
                        "| \tY           : " + y + "\n";
    }
}
