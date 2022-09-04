package client;

import common.IO.IOManager;
import common.requestresponse.*;

import java.io.*;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;
import java.time.Duration;
import java.time.Instant;
import java.util.LinkedList;

public class ClientService {
    private static int port = 0;
    private static DatagramChannel datagramChannel = null;
    private static InetSocketAddress serverSocketAddress;
    private static IOManager ioManager = new IOManager();
    private static ConsoleManager consoleManager = new ConsoleManager(ioManager);
    private static boolean easterEggWasFound = false;

    private static Session session = null;

    public static void main(String[] callArgs) {
        System.out.println(poweredBy);
        boolean doneSuccessfully = mainLoop();
        while (!doneSuccessfully) {
            doneSuccessfully = mainLoop();
        }
    }

    private static boolean mainLoop() {
        try {
            startClient();
            Response response = establishConnection();
            ResponseType responseType = response.getType();
            if (responseType == ResponseType.ERROR) {
                ioManager.printlnErr(response.getExitMessage());
                ioManager.printlnStatus("Reconnecting...");
                return false;
            } else {
                // ---------------------------------- Authorization loop ----------------------------------
                while (session == null) {
                    Request authorizationRequest = consoleManager.authorize();
                    sendRequest(authorizationRequest);
                    Response authorizationResponse = receiveResponse();
                    if (authorizationResponse.getType() == ResponseType.SUCCESS) {
                        ioManager.printlnSuccess(authorizationResponse.getExitMessage());
                        session = authorizationRequest.getSession();
                    } else {
                        ioManager.printlnErr(authorizationResponse.getExitMessage());
                    }
                }
                // ---------------------------------- Main loop ----------------------------------
                boolean isRunning = true;
                while (isRunning) {
                    Request request = consoleManager.execute(session.getUsername());
                    if (request != null) {
                        if (request.getType() == RequestType.EXIT) {
                            ioManager.printlnStatus("Disconnecting...");
                            isRunning = false;
                            continue;
                        }
                        request.setSession(session);
                        sendRequest(request);
                        response = receiveResponse();
                        responseType = response.getType();
                        if (responseType == ResponseType.ERROR) {
                            ioManager.printlnErr(response.getExitMessage());
                        } else {
                            LinkedList<String> runtimeMessages = response.getRuntimeMessages();
                            if (runtimeMessages != null) {
                                response.getRuntimeMessages().forEach(ioManager::printlnStatus);
                            }
                            ioManager.printlnSuccess(response.getExitMessage());
                        }
                    }
                }
                return true;
            }
            } catch(Exception e) {
                e.printStackTrace();
                if (!easterEggWasFound) {
                    ioManager.printlnRainbow("Wow! You have found easter egg! Congrats!");
                    ioManager.sleep(2);
                    ioManager.printlnYellow("Okay, just kidding. I'm going to disappoint you. It seems something went wrong. Let me see...");
                    ioManager.sleep(2);
                    easterEggWasFound = true;
                }
                ioManager.printlnErr("Server is not available at the moment.");
                ioManager.sleep(2);
                return false;
            }
    }


    /*______________________________________________________________________________________________________________*/
    /*                                     Initialize client service methods                                        */

    private static void startClient() throws IOException {
        selectPort();
        datagramChannel = DatagramChannel.open();
        datagramChannel.bind(null);
        datagramChannel.configureBlocking(false);
    }

    private static void selectPort() {
        while (true) {
            port = ioManager.getNextInteger("Specify port: ", false);
            if (port > -1 && port < 65535) {
                break;
            }
            ioManager.printlnErr("Incorrect input. Port must be integer from 0 to 65535");
        }
    }

    /*______________________________________________________________________________________________________________*/

    private static Response establishConnection() throws IOException, ClassNotFoundException {
        ioManager.printlnStatus("Connecting to the server...");
        if (datagramChannel == null) throw new SocketException("Datagram channel has not been initialised yet");
        serverSocketAddress = new InetSocketAddress(InetAddress.getLocalHost(), port);
        ioManager.printlnStatus(serverSocketAddress.toString());
        sendRequest(new Request(RequestType.CONNECT));
        return receiveResponse();
    }

    private static void sendRequest(Request request) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream(4096);
        ObjectOutputStream requestToBytesStream = new ObjectOutputStream(byteArrayOutputStream);
        requestToBytesStream.writeObject(request);
        datagramChannel.send(ByteBuffer.wrap(byteArrayOutputStream.toByteArray()), serverSocketAddress);
    }

    private static Response receiveResponse() throws IOException, ClassNotFoundException {
        Instant awaitTime = Instant.now();
        ByteBuffer buffer = ByteBuffer.allocate(65536);
        while (buffer.position() == 0 && Duration.between(awaitTime, Instant.now()).getSeconds() < 5) {
            datagramChannel.receive(buffer);
        }
        if (buffer.position() == 0) throw new IOException("Unable to reach server");
        ObjectInputStream bytesToResponseStream = new ObjectInputStream(new ByteArrayInputStream(buffer.array()));
        return (Response) bytesToResponseStream.readObject();
    }



    /* _________________________________________________END_________________________________________________ */


    /* _________________________________You are not supposed to be here...__________________________________ */



    private static final String poweredBy =
            "\n" +
                    "░█▀▀█ █▀▀█ █───█ █▀▀ █▀▀█ █▀▀ █▀▀▄   ░█▀▀▄ █──█   ░█▀▀▄ █▀▀█   ░█▀▀ █── █▀▀ █▀▀ █▀▀█ \n" +
                    "░█▄▄█ █──█ █▄█▄█ █▀▀ █▄▄▀ █▀▀ █──█   ░█▀▀▄ █▄▄█   ░█──█ █──█   ░▀▀█ █── █▀▀ █▀▀ █──█ \n" +
                    "░█─── ▀▀▀▀ ─▀─▀─ ▀▀▀ ▀─▀▀ ▀▀▀ ▀▀▀─   ░▀▀▀─ ▄▄▄█   ░▀──▀ ▀▀▀▀   ░▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ █▀▀▀   \n\n\n";
}
