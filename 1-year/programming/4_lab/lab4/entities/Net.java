package lab4.entities;

import lab4.exceptions.BalloonException;

public class Net {
    private final String name;
    private String material;
    private Basket basket;
    private Balloon balloon;
    private boolean isReady = false;
    private boolean isHangedOver = false;


    public Net(String name) {
        this.name = name;
    }
    public Net(String name, String material) {
        this.name = name;
        this.material = material;
    }


    public void makeReady() {
        isReady = true;
        System.out.println(this + " готова");
    }

    public boolean getIsReady() {
        return isReady;
    }

    public boolean checkLinking(Balloon balloon) {
        return this.balloon == balloon;
    }

    public void putOnBalloon(Balloon balloon) throws BalloonException {
        if (isReady && !balloon.getIsLiftedUp() && balloon.linkNet(this)) {
            this.balloon = balloon;
            System.out.println("Объект " + this + " теперь находится на объекте " + balloon);
        }
        else {
            throw new BalloonException("Не получилось. Чтобы положить сетку на шар, сетка должна быть готова, шар не должен быть поднят и на шаре не должно быть другой сетки");
        }
    }

    public boolean getIsHangedOver() {
        return isHangedOver;
    }


    void hangOver(Balloon balloon) {
        if (balloon.getIsLiftedUp() && balloon.equals(this.balloon)) {
            isHangedOver = true;
            System.out.println("Объект " + this + " свесился вниз");
        }
    }

    boolean linkBasket(Basket basket) {
        if (this.basket == null && isHangedOver) {
            this.basket = basket;
            return true;
        }
        return false;
    }

    @Override
    public String toString() {
        return (material != null) ? ("'" + name + " из материала " + this.material + "'") : ("'" + name + "'");
    }

}
