package lab6.requestresponse;

import lab6.commands.Command;

import java.io.Serializable;
import java.util.Arrays;

public class Request implements Serializable {
    private RequestType type;
    private Command command = null;
    private Object[] args = null;

    public Request(RequestType type) {
        this.type = type;
    }

    public Request(RequestType type, Object[] args) {
        this.type = type;
        this.args = args;
    }

    public Request(RequestType type, Command command, Object[] args) {
        this.type = type;
        this.command = command;
        this.args = args;
    }

    public RequestType getType() {
        return type;
    }

    public void setType(RequestType type) {
        this.type = type;
    }

    public Command getCommand() {
        return command;
    }

    public void setCommand(Command command) {
        this.command = command;
    }

    public Object[] getArgs() {
        return args;
    }

    public void setArgs(String[] args) {
        this.args = args;
    }

    @Override
    public String toString() {
        return "Request{" +
                "type=" + type +
                ", command=" + command +
                ", args=" + Arrays.toString(args) +
                '}';
    }
}
