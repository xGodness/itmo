package domain;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class DomainTest {

    @Test
    void simpleTest() {
        Room room = new Room("room");
        Robot robot = new Robot(
                "robot",
                new Robot.Head(),
                Robot.RobotState.SITTING
        );
        Human human = new Human("Trillian");

        Assertions.assertFalse(robot.approachHuman(human));
        Assertions.assertEquals(Robot.RobotState.SITTING, robot.getState());
        Assertions.assertEquals(Robot.Head.HeadState.STILL, robot.getHead().getHeadState());
        Assertions.assertNull(robot.getNearbyHuman());

        robot.setRoom(room);
        human.setRoom(room);
        Assertions.assertTrue(room.containsActor(robot));
        Assertions.assertTrue(room.containsActor(human));
        Assertions.assertTrue(robot.approachHuman(human));
        Assertions.assertEquals(Robot.RobotState.MOVING, robot.getState());
        Assertions.assertEquals(Robot.Head.HeadState.SWINGING, robot.getHead().getHeadState());
        Assertions.assertTrue(human.isApproachedBy(robot));
        Assertions.assertEquals(human, robot.getNearbyHuman());

        Assertions.assertTrue(robot.approachHuman(null));
        Assertions.assertFalse(human.isApproachedBy(robot));
        Assertions.assertEquals(Robot.RobotState.STAYING, robot.getState());
    }
}
