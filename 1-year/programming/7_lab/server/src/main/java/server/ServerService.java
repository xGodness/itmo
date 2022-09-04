package server;

import server.database.DBManager;
import common.IO.IOManager;

import java.io.*;
import java.net.*;
import java.sql.SQLException;
import java.util.NoSuchElementException;
import java.util.Scanner;
import java.util.concurrent.atomic.AtomicBoolean;

public class ServerService {
    private static DatagramSocket socket = null;
    private static DatagramPacket packet = null;
    private static Application application;
    private static DBManager dbManager;
    private static RequestHandler requestHandler;
    private static final IOManager ioManager = new IOManager();

    public static void main(String[] callArgs) {
        System.out.println(duck);
        System.out.println(please);

        runServerMainLoop();
    }

    private static void runServerMainLoop() { //TODO: logger?
        AtomicBoolean isRunning = new AtomicBoolean(true);

        Thread serverConsole = new Thread(() -> {
            Scanner consoleScanner = new Scanner(System.in);
            while (true) {
                if (consoleScanner.hasNext()) {
                    try {
                        String input = consoleScanner.nextLine();
                        if (input.equalsIgnoreCase("exit")) {
                            isRunning.set(false);
                        }
                    } catch (NoSuchElementException | IllegalArgumentException e) {
                        System.exit(1337);
                    }
                }
            }
        });

        try {
            startServer();
            serverConsole.start();
            application = new Application(dbManager);
            requestHandler = new RequestHandler(socket, application);

            application.loadCollection();
            ioManager.printlnStatus("Collection has been loaded");

            while (isRunning.get()) {
                packet = receivePacket();

                if (packet == null || packet.getPort() < 0) {
                    continue;
                }
                requestHandler.readRequest(packet);
            }
        } catch (NoSuchElementException e) {
            System.exit(1337);
        } catch (Exception e) {
            e.printStackTrace();
            ioManager.printlnOut(fatalError);
            System.exit(exitCode);
        }
    }

    private static void startServer() {
        int port;

        while (true) {
            port = ioManager.getNextInteger("Specify port: ", false);
            if (port < -1 || port > 65535) {
                ioManager.printlnErr("Incorrect input. Port must be integer from 0 to 65535");
                continue;
            }
            try {
                socket = new DatagramSocket(port);
                ioManager.printlnSuccess("Server has been started on port " + port);
                break;
            } catch (SocketException e) {
                ioManager.printlnErr("Incorrect input. Try again");
            }
        }

        int hostNum;
        String host;
        String user;
        String password;

        while (true) {
            hostNum = ioManager.getNextInteger(
                    "Choose database to connect to ([1] helios [2] localhost): ", false);
            switch (hostNum) {
                case 1:
                    host = "jdbc:postgresql://pg:5432/studs";
                    user = "s335151";
                    password = ioManager.getNextPassword();
                    break;
                case 2:
                    host = "jdbc:postgresql://localhost:5432/postgres";
                    user = "postgres";
                    password = "gfhjkm";
                    break;
                default:
                    continue;
            }
            try {
                dbManager = new DBManager(host, user, password);
                break;
            } catch (SQLException e) {
                e.printStackTrace();
                ioManager.printlnErr("Error while connecting database. Try again");
            }
        }

        Thread terminationHook = new Thread(() -> {
            socket.close();
            try {
                dbManager.close();
                ioManager.printlnStatus("Connection closed");
            } catch (SQLException e) {
                ioManager.printlnStatus("Unable to close connection to the database");
            }
        });

        Runtime.getRuntime().addShutdownHook(terminationHook);

    }

    private static DatagramPacket receivePacket() throws IOException {
        if (socket == null) throw new SocketException("Socket and/or packet has not been initialised yet");
        byte[] bytes = new byte[4096];
        packet = new DatagramPacket(bytes, bytes.length);
        socket.receive(packet);
        return packet;
    }



    /* _________________________________________________END_________________________________________________ */


    /* _________________________________You are not supposed to be here...__________________________________ */


    private static final String duck =
            "\n\n\n\n" +
                    "                                    ██████        \n" +
                    "                                  ██      ██      \n" +
                    "                                ██          ██    \n" +
                    "                                ██      ██  ██    \n" +
                    "                                ██        ░░░░██  \n" +
                    "                                  ██      ████    \n" +
                    "                    ██              ██  ██        \n" +
                    "                  ██  ██        ████    ██        \n" +
                    "                  ██    ████████          ██      \n" +
                    "                  ██                        ██    \n" +
                    "                    ██                      ██    \n" +
                    "                    ██    ██      ████      ██    \n" +
                    "                     ██    ████████      ██       \n" +
                    "                      ██                  ██      \n" +
                    "                        ████          ████        \n" +
                    "                            ██████████            \n" +
                    "\n\n";
    private static final String please =
            "\n\n\n\n" +
                    "██████╗░███████╗░░░░░░░░░██████╗░███████╗███╗░░██╗████████╗██╗░░░░░███████╗\n" +
                    "██╔══██╗██╔════╝░░░░░░░░██╔════╝░██╔════╝████╗░██║╚══██╔══╝██║░░░░░██╔════╝\n" +
                    "██████╦╝█████╗░░░░░░░░░░██║░░██╗░█████╗░░██╔██╗██║░░░██║░░░██║░░░░░█████╗░░\n" +
                    "██╔══██╗██╔══╝░░░░░░░░░░██║░░╚██╗██╔══╝░░██║╚████║░░░██║░░░██║░░░░░██╔══╝░░\n" +
                    "██████╦╝███████╗░░░░░░░░╚██████╔╝███████╗██║░╚███║░░░██║░░░███████╗███████╗\n" +
                    "╚═════╝░╚══════╝░░░░░░░░░╚═════╝░╚══════╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚══════╝\n" +
                    "\n" +
                    "██████╗░██╗░░░░░███████╗░█████╗░░██████╗███████╗░░░░░░░░░\n" +
                    "██╔══██╗██║░░░░░██╔════╝██╔══██╗██╔════╝██╔════╝░░░░░░░░░\n" +
                    "██████╔╝██║░░░░░█████╗░░███████║╚█████╗░█████╗░░░░░░░░░░░\n" +
                    "██╔═══╝░██║░░░░░██╔══╝░░██╔══██║░╚═══██╗██╔══╝░░░░░░░░░░░\n" +
                    "██║░░░░░███████╗███████╗██║░░██║██████╔╝███████╗██╗██╗██╗\n" +
                    "╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝╚═╝╚═╝╚═╝" +
                    "\n\n\n\n";
    private static final String fatalError =
                    "████████████████████████████████████████\n" +
                    "████████████████████████████████████████\n" +
                    "██████▀░░░░░░░░▀████████▀▀░░░░░░░▀██████\n" +
                    "████▀░░░░░░░░░░░░▀████▀░░░░░░░░░░░░▀████\n" +
                    "██▀░░░░░░░░░░░░░░░░▀▀░░░░░░░░░░░░░░░░▀██\n" +
                    "██░░░░░░░░░░░░░░░░░░░▄▄░░░░░░░░░░░░░░░██\n" +
                    "██░░░░░░░░░░░░░░░░░░█░█░░░░░░░░░░░░░░░██\n" +
                    "██░░░░░░░░░░░░░░░░░▄▀░█░░░░░░░░░░░░░░░██\n" +
                    "██░░░░░░░░░░████▄▄▄▀░░▀▀▀▀▄░░░░░░░░░░░██\n" +
                    "██▄░░░░░░░░░████░░░░░░░░░░█░░░░░░░░░░▄██\n" +
                    "████▄░░░░░░░████░░░░░░░░░░█░░░░░░░░▄████\n" +
                    "██████▄░░░░░████▄▄▄░░░░░░░█░░░░░░▄██████\n" +
                    "████████▄░░░▀▀▀▀░░░▀▀▀▀▀▀▀░░░░░▄████████\n" +
                    "██████████▄░░░░░░░░░░░░░░░░░░▄██████████\n" +
                    "████████████▄░░░░░░░░░░░░░░▄████████████\n" +
                    "██████████████▄░░░░░░░░░░▄██████████████\n" +
                    "████████████████▄░░░░░░▄████████████████\n" +
                    "██████████████████▄▄▄▄██████████████████\n" +
                    "████████████████████████████████████████\n" +
                    "████████████████████████████████████████\n" +
                    "Congrats! Server has died.";
    private static final int exitCode = 314159265; //zdec


}