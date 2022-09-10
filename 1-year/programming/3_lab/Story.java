import lab3.entities.Balloon;
import lab3.entities.Basket;

import static lab3.enums.Place.*;

public class Story {
    public static void main(String[] args) {
        Doono doono = new Doono(ON_GROUND);
        Swifty swifty = new Swifty(ON_GROUND);
        Twistum twistum = new Twistum(ON_GROUND);

        System.out.println("Персонажи:");
        Character[] characters = {doono, swifty, twistum};
        for (Character character : characters) {
            character.describe();
        }

        Balloon balloon = new Balloon();
        Basket basket = new Basket();

        System.out.println();
        swifty.grab("Веревка");
        twistum.grab("Веревка");
        swifty.setPlace(ON_BUSH);
        twistum.setPlace(ON_BUSH);
        swifty.liftUp(balloon);
        twistum.liftUp(balloon);

        if (balloon.checkIsLiftedUp()) {
            System.out.println("Зрители обрадовались");
        }

        System.out.println();
        doono.giveOrder("привязать к углам сетки корзину из березовой коры");
        balloon.attachBasket(basket);
    }
}
