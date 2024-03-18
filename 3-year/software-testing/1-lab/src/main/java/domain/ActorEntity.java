package domain;

import java.util.Objects;

public abstract class ActorEntity {
    private final String name;
    private Room room;

    public ActorEntity(String name) {
        this.name = name;
    }

    public void moveToRoom(Room room) {
        this.room.removeActor(this);
        this.room = room;
        room.addActor(this);
    }

    public String getName() {
        return name;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
        room.addActor(this);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        ActorEntity that = (ActorEntity) obj;
        return Objects.equals(name, that.name) && Objects.equals(room, that.room);
    }
}
