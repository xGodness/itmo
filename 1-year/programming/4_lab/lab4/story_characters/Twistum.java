package lab4.story_characters;

import lab4.enums.Place;
import lab4.interfaces.AbleToGrab;

public class Twistum extends StoryCharacter implements AbleToGrab {
    public Twistum(Place place) {
        super("Шпунтик", place);
    }

    @Override
    public void describe() {
        System.out.println("Шпунтик -- сообразительный");
    }

    @Override
    public void grab(String thing) {
        System.out.println("Персонаж Шпунтик схватил предмет '" + thing + "'");
    }

}
