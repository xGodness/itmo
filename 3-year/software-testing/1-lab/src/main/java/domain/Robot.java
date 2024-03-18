package domain;

public class Robot extends ActorEntity {
    private final Head head;
    private RobotState state;
    private Human nearbyHuman;

    public Robot(String name, Head head, RobotState state) {
        super(name);
        this.head = head;
        this.state = state;
        nearbyHuman = null;
    }

    public boolean approachHuman(Human human) {
        if (this.nearbyHuman != null) nearbyHuman.notApproachedAnymoreBy(this);
        if (human == null) {
            setState(RobotState.STAYING);
            nearbyHuman = null;
            return true;
        }
        if (human.approachedBy(this)) {
            setState(RobotState.MOVING);
            nearbyHuman = human;
            return true;
        }
        return false;
    }

    public Head getHead() {
        return head;
    }

    public RobotState getState() {
        return state;
    }

    public void setState(RobotState state) {
        this.state = state;
        switch (state) {
            case MOVING -> head.headState = Head.HeadState.SWINGING;
            case LYING, STAYING, SITTING -> head.headState = Head.HeadState.STILL;
        }
    }

    public Human getNearbyHuman() {
        return nearbyHuman;
    }

    static class Head {
        public Head() {
            this.headState = HeadState.STILL;
        }

        private HeadState headState;

        public HeadState getHeadState() {
            return headState;
        }

        public void setHeadState(HeadState headState) {
            this.headState = headState;
        }

        enum HeadState {
            STILL,
            SWINGING
        }
    }

    public enum RobotState {
        LYING,
        SITTING,
        STAYING,
        MOVING
    }
}
