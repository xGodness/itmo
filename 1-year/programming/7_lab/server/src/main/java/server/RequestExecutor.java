package server;

import common.collectionexceptions.CollectionException;
import common.commands.Command;
import common.databaseexceptions.DatabaseException;
import common.requestresponse.*;
import server.database.DBManager;

import java.net.InetSocketAddress;
import java.sql.SQLException;

public class RequestExecutor extends Thread {
    private final RequestHandler masterHandler;
    private final Application application;
    private final DBManager dbManager;
    private final Request request;
    private final InetSocketAddress clientSocketAddress;

    public RequestExecutor(RequestHandler masterHandler, Application application, Request request, InetSocketAddress clientSocketAddress) {
        this.masterHandler = masterHandler;
        this.application = application;
        dbManager = application.getDbManager();
        this.request = request;
        this.clientSocketAddress = clientSocketAddress;
    }

    @Override
    public void run() {
        Response response = null;

        if (request.getType() == RequestType.CONNECT) {
            response = confirmConnect();
        } else if (request.getType() == RequestType.REGISTER) {
            Session session = request.getSession();
            response = registerUser(
                    session.getUsername(),
                    session.getPassword()
            );
        } else if (request.getType() == RequestType.LOGIN) {
            Session session = request.getSession();
            response = loginUser(
                    session.getUsername(),
                    session.getPassword()
            );
        } else if (request.getType() == RequestType.EXECUTE_COMMAND) {
            Session session = request.getSession();
            response = executeCommand(
                    request.getCommand(),
                    request.getArgs(),
                    session.getUsername(),
                    session.getPassword()
            );
        }

        if (response != null) {
            masterHandler.sendResponse(response, clientSocketAddress);
        }

    }

    private Response confirmConnect() {
        return new Response(ResponseType.SUCCESS, "Connection established");
    }

    private Response registerUser(String user, String password) {
        try {
            dbManager.register(user, password);
            return new Response(ResponseType.SUCCESS, "User '" + user + "' has been registered");
        } catch (DatabaseException e) {
            return new Response(ResponseType.ERROR, e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            return new Response(ResponseType.ERROR, "Could not access database");
        }
    }

    private Response loginUser(String user, String password) {
        try {
            dbManager.login(user, password);
            return new Response(ResponseType.SUCCESS, "Logged in successfully");
        } catch (DatabaseException e) {
            return new Response(ResponseType.ERROR, e.getMessage());
        } catch (SQLException e) {
            e.printStackTrace();
            return new Response(ResponseType.ERROR, "Could not access database");
        }
    }

    private Response executeCommand(Command command, Object[] cmdArgs,
                                    String username, String password) {
        if (!validateLogin(username, password)) {
            return new Response(ResponseType.ERROR, "Access denied: user must be logged in to execute commands");
        }
        try {
            String exitMessage = application.executeCommand(command, cmdArgs, username);
            return new Response(ResponseType.SUCCESS, exitMessage);
        } catch (CollectionException e) {
            return new Response(ResponseType.ERROR, e.getMessage(), ExceptionType.EXECUTE_COMMAND_EXCEPTION);
        }
    }

    private boolean validateLogin(String user, String password) {
        try {
            dbManager.login(user, password);
            return true;
        } catch (SQLException | DatabaseException e) {
            return false;
        }
    }

}
