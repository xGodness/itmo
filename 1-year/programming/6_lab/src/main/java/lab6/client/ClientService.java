package lab6.client;

import lab6.IO.IOManager;
import lab6.requestresponse.*;

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
            if (responseType == ResponseType.SUCCESS_AND_FILE_ALREADY_LOADED) {
                ioManager.printlnSuccess(response.getExitMessage());
            } else if (responseType == ResponseType.SUCCESS) {
                ioManager.printlnSuccess(response.getExitMessage());
                boolean fileWasFetched = false;
                while (!fileWasFetched) {
                    fileWasFetched = fileFetch();
                }
            } else {
                ioManager.printlnErr(response.getExitMessage());
                ioManager.printlnStatus("Reconnecting...");
                return false;
            }

            boolean isRunning = true;

            while (isRunning) {
                Request request = consoleManager.execute();
                if (request != null) {
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
                        if (request.getType() == RequestType.EXIT) {
                            isRunning = false;
                        }
                    }
                }
            }
            return true;


        } catch (Exception e) {
            e.printStackTrace();
            if (!easterEggWasFound) {
                ioManager.printlnRainbow("Wow! You have found easter egg! Congrats!");
                ioManager.sleep(2);
                ioManager.printlnYellow("Okay, just kidding. I'm going to disappoint you.");
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

    private static boolean fileFetch() throws IOException, ClassNotFoundException {
        String fileName = null;
        while (fileName == null) {
            fileName = ioManager.getNextInput("Specify file name: ");
            if (!ioManager.isStringValid(fileName)) {
                ioManager.printlnErr("File name is invalid");
                fileName = null;
            }
        }
        Request fileRequest = new Request(RequestType.LOAD, new String[]{fileName});
        sendRequest(fileRequest);
        Response response = receiveResponse();
        LinkedList<String> runtimeMessages = response.getRuntimeMessages();
        if (runtimeMessages != null) {
            runtimeMessages.forEach(ioManager::printlnStatus);
        }
        if (response.getType() == ResponseType.SUCCESS) {
            ioManager.printlnSuccess(response.getExitMessage());
            return true;
        }
        ioManager.printlnErr(response.getExitMessage());
        if (response.getExceptionType() == ExceptionType.FILE_NOT_FOUND) {
            String answer = ioManager.getNextInput("Would you like to create new blank file \"" + fileName + "\"? (y/n): ");
            if (answer.equalsIgnoreCase("y")) {
                fileRequest = new Request(RequestType.CREATE, new String[]{fileName});
                sendRequest(fileRequest);
                response = receiveResponse();
                if (response.getType() == ResponseType.SUCCESS) {
                    ioManager.printlnSuccess(response.getExitMessage());
                    return true;
                }
                ioManager.printlnErr(response.getExitMessage());
            }
        }
        return false;
    }

    private static void startClient() throws IOException {
        selectPort();
        datagramChannel = DatagramChannel.open();
        datagramChannel.bind(null);
        datagramChannel.configureBlocking(false);
    }

    private static void selectPort() {
        while (port == 0) {
            port = ioManager.getNextInteger("Specify port: ", false);
            if (port < 0) {
                ioManager.printlnErr("Incorrect input. Port must be positive integer");
                port = 0;
            }
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
        ByteBuffer buffer = ByteBuffer.allocate(4096);
        while (buffer.position() == 0 && Duration.between(awaitTime, Instant.now()).getSeconds() < 5) {
            datagramChannel.receive(buffer);
        }
        if (buffer.position() == 0) throw new IOException("Unable to reach server");
        ObjectInputStream bytesToResponseStream = new ObjectInputStream(new ByteArrayInputStream(buffer.array()));
        return (Response) bytesToResponseStream.readObject();
    }





    private static final String poweredBy =
            "\n" +
                    "░█▀▀█ █▀▀█ █───█ █▀▀ █▀▀█ █▀▀ █▀▀▄   ░█▀▀▄ █──█   ░█▀▀▄ █▀▀█   ░█▀▀ █── █▀▀ █▀▀ █▀▀█ \n" +
                    "░█▄▄█ █──█ █▄█▄█ █▀▀ █▄▄▀ █▀▀ █──█   ░█▀▀▄ █▄▄█   ░█──█ █──█   ░▀▀█ █── █▀▀ █▀▀ █──█ \n" +
                    "░█─── ▀▀▀▀ ─▀─▀─ ▀▀▀ ▀─▀▀ ▀▀▀ ▀▀▀─   ░▀▀▀─ ▄▄▄█   ░▀──▀ ▀▀▀▀   ░▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ █▀▀▀   \n\n\n";
}
