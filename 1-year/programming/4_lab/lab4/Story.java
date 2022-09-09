package lab4;

import lab4.entities.Balloon;
import lab4.entities.Basket;
import lab4.entities.Net;
import lab4.exceptions.BalloonException;
import lab4.exceptions.CannotMakeChuteException;
import lab4.exceptions.CannotTeachMakeChuteException;
import lab4.exceptions.RejoiceReasonException;
import lab4.interfaces.Viewers;
import lab4.story_characters.StoryCharacter;
import lab4.story_characters.Doono;
import lab4.story_characters.Swifty;
import lab4.story_characters.Twistum;

import static lab4.enums.Place.*;

public class Story {

    public static class Daycycle { // <--- Static nested class
        static void nextDay() {
            System.out.println("Наступает следующий день");
        }
    }

    public static void main(String[] args) {

        // _________________________________________________________________________________

        Doono doono = new Doono(ON_GROUND);
        Swifty swifty = new Swifty(ON_GROUND);
        Twistum twistum = new Twistum(ON_GROUND);

        System.out.println("Персонажи:");
        StoryCharacter[] characters = {doono, swifty, twistum};
        for (StoryCharacter character : characters) {
            character.describe();
        }
        System.out.println();

        // _________________________________________________________________________________

        class Jest { // <--- Local class
            private String name = "Насмешка над персонажем ";

            public Jest(StoryCharacter character) {
                name += character.getName();
                System.out.println("Над персонажем " + character.getName() + " насмехаются");
            }

            @Override
            public String toString() {
                return name;
            }
        }

        Jest jest = new Jest(doono);
        doono.ignore(jest);
        System.out.println();

        // _________________________________________________________________________________

        Balloon balloon = new Balloon("Воздушный шар");
        Net net = new Net("Сетка", "Шелк");
        Basket basket = new Basket("Корзина", "Березовая кора");

        net.makeReady();

        if (!net.getIsReady()) {
            throw new RuntimeException("Невозможно продолжить историю. Сетка еще не готова");
        }

        doono.giveOrder("накинуть объект " + net + " на объект " + balloon);
        try {
            net.putOnBalloon(balloon);
        } catch (BalloonException e) {
            System.out.println(e.getMessage());
        }

        if (!net.checkLinking(balloon)) {
            throw new RuntimeException("Невозможно продолжить историю. Не удалось накинуть сетку на шар");
        }

        doono.giveOrder("подцепить объект " + balloon + " веревкой снизу, привязать к ветке орехового куста и подтянуть кверху");

        swifty.grab("Веревка");
        swifty.setPlace(ON_BUSH);
        try {
            balloon.liftUp(swifty);
        } catch (BalloonException e) {
            System.out.println(e.getMessage());
        }

        twistum.grab("Веревка");
        twistum.setPlace(ON_BUSH);
        try {
            balloon.liftUp(twistum);
        } catch (BalloonException e) {
            System.out.println(e.getMessage());
        }


        Viewers viewers = new Viewers() { }; // <--- Anonymous class

        if (balloon.getIsLiftedUp()) {
            viewers.rejoice();
        }
        else {
            throw new RejoiceReasonException("Cannot continue story. Viewers must rejoice but there is nothing to rejoice at");
        }

        doono.giveOrder("привязать к объекту " + net + " объект " + basket);
        try {
            basket.attachToNet(net);
        } catch (BalloonException e) {
            System.out.println(e.getMessage());
        }

        if (!basket.checkLinking(net)) {
            throw new RuntimeException("Невозможно продолжить историю. Не удалось прикрепить корзину к сетке");
        }

        doono.announce("работа по постройке шара закончена");
        swifty.makeGuess("уже можно лететь");
        doono.announce("еще надо приготовить для всех парашюты");

        System.out.println();

        // _________________________________________________________________________________


        Story.Daycycle.nextDay();

        try {
            swifty.teachThisMakeChute(doono);
        } catch (CannotTeachMakeChuteException e) {
            System.out.println(e.getMessage());
        }

        try {
            twistum.teachThisMakeChute(doono);
        } catch (CannotTeachMakeChuteException e) {
            System.out.println(e.getMessage());
        }

        for (StoryCharacter character : characters) {
            System.out.println("Персонаж " + character.getName() + " хочет сделать парашют");
            try {
                character.makeChute("Пушинки одуванчика");
            } catch (CannotMakeChuteException e) {
                System.out.println(e.getMessage());
            }
        }

    }
}
