package common.requestresponse;

import common.commands.Command;
import java.io.Serializable;
import java.util.Arrays;

public class Request implements Serializable {
    private RequestType type;
    private Session session;
    private Command command = null;
    private Object[] args = null;

    public Request(RequestType type) {
        this.type = type;
    }

    public Request(RequestType type, Session session) {
        this.type = type;
        this.session = session;
    }

    public Request(RequestType type, Command command, Object[] args) {
        this.type = type;
        this.command = command;
        this.args = args;
    }

    public Request(RequestType type, Session session, Command command, Object[] args) {
        this.type = type;
        this.session = session;
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

    public Session getSession() {
        return session;
    }

    public void setSession(Session session) {
        this.session = session;
    }

    @Override
    public String toString() {
        return "Request{" +
                "type=" + type +
                ", session=" + session +
                ", command=" + command +
                ", args=" + Arrays.toString(args) +
                '}';
    }
}
