package lab4.entities;

import lab4.exceptions.BalloonException;

public class Basket {
    private final String name;
    private String material;
    private Net net;

    public Basket(String name) {
        this.name = name;
    }
    public Basket(String name, String material) {
        this.name = name;
        this.material = material;
    }

    public void attachToNet(Net net) throws BalloonException {
        if (this.net != null) {
            throw new BalloonException("Невозможно прикрепить объект " + this + ", так как он уже прикреплен");
        }
        if (net.linkBasket(this)) {
            this.net = net;
            System.out.println("Теперь к объекту " + net + " прикреплен объект " + this);
            describe();
        } else throw new BalloonException("Не получилось. К объекту " + net + " уже прикреплен другой объект");
    }

    public boolean checkLinking(Net net) {
        return this.net == net;
    }

    public void describe() {
        System.out.println(this + ": четырехугольная; с каждой ее стороны есть лавочка, и на каждой лавочке может поместиться по четыре малыша");
    }

    @Override
    public String toString() {
        return (material != null) ? ("'" + name + " из материала " + this.material + "'") : ("'" + name + "'");
    }
}
