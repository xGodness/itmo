package common.requestresponse;

import java.io.Serializable;
import java.util.LinkedList;

public class Response implements Serializable {
    private ResponseType type;
    private String exitMessage;
    private LinkedList<String> runtimeMessages = null;
    private ExceptionType exceptionType = ExceptionType.NO_EXCEPTION;

    // Executed successfully
    public Response(ResponseType type, String exitMessage) {
        this.type = type;
        this.exitMessage = exitMessage;
    }

    // Executed successfully
    public Response(ResponseType type, String exitMessage, LinkedList<String> runtimeMessages) {
        this.type = type;
        this.exitMessage = exitMessage;
        this.runtimeMessages = runtimeMessages;
    }

    // Error during executing
    public Response(ResponseType type, String exitMessage, ExceptionType exceptionType) {
        this.type = type;
        this.exitMessage = exitMessage;
        this.exceptionType = exceptionType;
    }

    public ResponseType getType() {
        return type;
    }

    public void setType(ResponseType type) {
        this.type = type;
    }

    public String getExitMessage() {
        return exitMessage;
    }

    public void setExitMessage(String exitMessage) {
        this.exitMessage = exitMessage;
    }

    public LinkedList<String> getRuntimeMessages() {
        return runtimeMessages;
    }

    public void setRuntimeMessages(LinkedList<String> runtimeMessages) {
        this.runtimeMessages = runtimeMessages;
    }

    public ExceptionType getExceptionType() {
        return exceptionType;
    }

    public void setExceptionType(ExceptionType exceptionType) {
        this.exceptionType = exceptionType;
    }

    @Override
    public String toString() {
        return "Response{" +
                "type=" + type +
                ((exitMessage == null) ? "" : (", exitMessage='" + exitMessage + '\'')) +
                ((exceptionType == ExceptionType.NO_EXCEPTION) ? "" : (", exceptionType=" + exceptionType)) +
                ((runtimeMessages == null || runtimeMessages.size() == 0) ? "" : (", runtimeMessages=" + runtimeMessages)) +
                '}';
    }
}
