package domain;

import java.util.HashSet;
import java.util.Set;

public class Room {
    private final String name;
    private final Set<ActorEntity> actorsInsideSet;

    public Room(String name) {
        this.name = name;
        this.actorsInsideSet = new HashSet<>();
    }

    public String getName() {
        return name;
    }

    public boolean addActor(ActorEntity actor) {
        return actorsInsideSet.add(actor);
    }

    public boolean removeActor(ActorEntity actor) {
        return actorsInsideSet.remove(actor);
    }

    public boolean containsActor(ActorEntity actor) {
        return actorsInsideSet.contains(actor);
    }
}
