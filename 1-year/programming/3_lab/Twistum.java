import lab3.entities.Balloon;
import lab3.enums.Place;
import lab3.interfaces.AbleToGrab;
import lab3.interfaces.AbleToLiftUp;

public class Twistum extends Character implements AbleToGrab, AbleToLiftUp {
    public Twistum(Place place) {
        super("Шпунтик", place);
    }

    @Override
    public void describe() {
        System.out.println("Шпунтик -- сообразительный");
    }

    @Override
    public void grab(String thing) {
        System.out.println("Шпунтик схватил предмет \'" + thing + "\'");
    }

    @Override
    public void liftUp(Balloon balloon) {
        System.out.println("Шпунтик начинает приподнимать шар");
        balloon.liftUp();
    }

}
