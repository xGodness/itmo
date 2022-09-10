
import lab3.entities.Balloon;
import lab3.enums.Place;
import lab3.interfaces.AbleToGrab;
import lab3.interfaces.AbleToLiftUp;

public class Swifty extends Character implements AbleToGrab, AbleToLiftUp {
    public Swifty(Place place) {
        super("Торопыжка", place);
    }

    @Override
    public void describe() {
        System.out.println("Торопыжка -- быстрый");
    }

    @Override
    public void grab(String thing) {
        System.out.println("Торопыжка схватил предмет \'" + thing + "\'");
    }

    @Override
    public void liftUp(Balloon balloon) {
        System.out.println("Торопыжка начинает приподнимать шар");
        balloon.liftUp();
    }

}
