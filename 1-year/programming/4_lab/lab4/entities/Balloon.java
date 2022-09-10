package lab4.entities;

import lab4.exceptions.BalloonException;
import lab4.story_characters.StoryCharacter;

import java.util.ArrayList;

public class Balloon {
    private final String name;
    private Net net;
    private boolean isLiftedUp = false;

    private ArrayList<StoryCharacter> liftingUpParticipants = new ArrayList<StoryCharacter>();
    private final int participantsNeeded = 2;


    public Balloon(String name) {
        this.name = name;
    }


    public void liftUp(StoryCharacter character) throws BalloonException {
        if (liftingUpParticipants.contains(character)) {
            throw new BalloonException("Не получилось. Этот персонаж уже начал приподнимать объект " + name);
        }
        if (isLiftedUp) {
            throw new BalloonException("Не получилось. Объект " + name + " уже поднят");
        }

        liftingUpParticipants.add(character);
        System.out.println("Персонаж " + character.getName() + " начал приподнимать объект " + this);
        System.out.printf("Чтобы приподнять объект %s необходимо %d персонажа (-ей). Сейчас: %d%n", name, participantsNeeded, liftingUpParticipants.size());
        if (liftingUpParticipants.size() >= participantsNeeded) {
            isLiftedUp = true;
            System.out.println("Объект " + this + " приподнялся");
            if (net != null) {
                net.hangOver(this);
            }
        }
    }

    public boolean getIsLiftedUp() {
        return isLiftedUp;
    }


    boolean linkNet(Net net) {
        if (this.net == null) {
            this.net = net;
            return true;
        }
        return false;
    }

    @Override
    public String toString() {
        return "'" + name + "'";
    }

}