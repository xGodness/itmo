package domain;

import java.util.HashSet;
import java.util.Set;

public class Human extends ActorEntity {
    private final Set<ActorEntity> isApproachedBySet;

    public Human(String name) {
        super(name);
        isApproachedBySet = new HashSet<>();
    }

    public boolean approachedBy(ActorEntity actor) {
        Room room = getRoom();
        return room != null && room.equals(actor.getRoom()) && isApproachedBySet.add(actor);
    }

    public boolean notApproachedAnymoreBy(ActorEntity actor) {
        return isApproachedBySet.remove(actor);
    }

    public boolean isApproachedBy(ActorEntity actor) {
        return isApproachedBySet.contains(actor);
    }
}
