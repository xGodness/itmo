package lab4.story_characters;

import lab4.enums.Place;
import lab4.exceptions.CannotMakeChuteException;
import lab4.exceptions.CannotTeachMakeChuteException;

abstract public class StoryCharacter {
    private final String name;
    private Place place;
    private boolean canMakeChute = false;


    // ___________________________ Constructors ___________________________

    public StoryCharacter(String name, Place place) {
        this.name = name;
        this.place = place;
    }

    public StoryCharacter(String name, Place place, boolean canMakeChute) {
        this.name = name;
        this.place = place;
        this.canMakeChute = canMakeChute;
    }


    // ___________________________ Fields access methods ___________________________

    public String getName() {
        return name;
    }

    public Place getPlace(){
        return place;
    }

    public void setPlace(Place place) {
        this.place = place;
        System.out.println("Персонаж " + name + " перешел в локацию \'" + place.getName() + "\'");
    }

    public boolean getCanMakeChute() {
        return canMakeChute;
    }

    public void teachThisMakeChute(StoryCharacter character) throws CannotTeachMakeChuteException {
        System.out.println("Персонаж " + character.getName() + " хочет научить персонажа " + name + " делать парашют");
        if (!character.getCanMakeChute()) {
            throw new CannotTeachMakeChuteException("Персонаж " + character.getName() + " не умеет делать парашют и не может научить персонажа " + name + " делать парашют");
        }
        if (canMakeChute) {
            System.out.println("Персонаж " + this.name + " уже умеет делать парашют");
        }
        else {
            canMakeChute = true;
            System.out.println("Персонаж " + character.getName() + " научил персонажа " + name + " делать парашют");
        }
    }


    // ___________________________ Misc methods ___________________________

    public void makeChute(String material) throws CannotMakeChuteException {
        if (!canMakeChute) {
            throw new CannotMakeChuteException("Персонаж " + name + " не умеет делать парашют");
        }
        System.out.println("Персонаж " + name + " сделал парашют из материала '" + material + "'");
    }


    // ___________________________ Abstract methods ___________________________

    abstract public void describe();


    // ___________________________ Overridden methods ___________________________

    @Override
    public String toString() {
        return String.format("lab4.story_characters.StoryCharacter = {name: %s, currentPlace: %s}", name, place);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) return false;
        if (obj instanceof StoryCharacter) {
            return ( name.equals(((StoryCharacter) obj).getName()) &&
                     place.equals(((StoryCharacter) obj).getPlace()) );
        }
        return false;
    }

    @Override
    public int hashCode() {
        return ( name.hashCode() + place.hashCode() );
    }


    // ___________________________ Nested non-static class ___________________________
    public class Mood {
        private String currentMood;

        public Mood(String currentMood) {
            this.currentMood = currentMood;
        }
        public void setMood(String mood) {
            this.currentMood = mood;
        }

    }


}
