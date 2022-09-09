import lab3.enums.Place;
import lab3.interfaces.Supervisor;

public class Doono extends Character implements Supervisor {
    public Doono(Place place) {
        super("Знайка", place);
    }

    @Override
    public void describe() {
        System.out.println("Знайка -- умный");
    }

    @Override
    public void giveOrder(String order) {
        System.out.println("Знайка велит " + order);
    }

}