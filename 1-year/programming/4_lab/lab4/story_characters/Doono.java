package lab4.story_characters;

import lab4.enums.Place;
import lab4.interfaces.AbleToAnnounce;
import lab4.interfaces.AbleToIgnore;
import lab4.interfaces.Supervisor;

public class Doono extends StoryCharacter implements Supervisor, AbleToIgnore, AbleToAnnounce {
    public Doono(Place place) {
        super("Знайка", place, true);
    }

    @Override
    public void describe() {
        System.out.println("Знайка -- умный");
    }

    @Override
    public void giveOrder(String order) {
        System.out.println("Персонаж Знайка велит " + order);
    }

    @Override
    public void ignore(Object obj) {
        System.out.println("Персонаж Знайка игнорирует объект '" + obj + "'");
    }

    @Override
    public void announce(String announcement) {
        System.out.println("Персонаж Знайка объявляет, что " + announcement);
    }

}