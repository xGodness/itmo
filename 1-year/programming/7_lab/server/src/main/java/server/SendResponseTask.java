package server;

import common.requestresponse.Response;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;

public class SendResponseTask implements Runnable {
    private final DatagramSocket serverSocket;
    private final Response response;
    private final InetSocketAddress clientSocketAddress;

    public SendResponseTask(DatagramSocket serverSocket, Response response, InetSocketAddress clientSocketAddress) {
        this.serverSocket = serverSocket;
        this.response = response;
        this.clientSocketAddress = clientSocketAddress;
    }

    @Override
    public void run() {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        System.out.println(response);
        try {
            ObjectOutputStream responseToBytes = new ObjectOutputStream(byteArrayOutputStream);
            responseToBytes.writeObject(response);
            DatagramPacket packet = new DatagramPacket(byteArrayOutputStream.toByteArray(), byteArrayOutputStream.size(), clientSocketAddress);
            System.out.println(byteArrayOutputStream.size());
            serverSocket.send(packet);
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }
    }

}
