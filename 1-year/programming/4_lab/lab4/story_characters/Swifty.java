package lab4.story_characters;

import lab4.enums.Place;
import lab4.interfaces.AbleToGrab;
import lab4.interfaces.AbleToGuess;

public class Swifty extends StoryCharacter implements AbleToGrab, AbleToGuess {
    public Swifty(Place place) {
        super("Торопыжка", place);
    }

    @Override
    public void describe() {
        System.out.println("Торопыжка -- быстрый");
    }

    @Override
    public void grab(String thing) {
        System.out.println("Персонаж Торопыжка схватил предмет '" + thing + "'");
    }

    @Override
    public void makeGuess(String guess) {
        System.out.println("Персонаж Торопыжка предполагает, что " + guess);
    }

}
