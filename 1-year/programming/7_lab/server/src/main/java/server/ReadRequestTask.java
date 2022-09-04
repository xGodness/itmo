package server;

import common.requestresponse.Request;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.net.DatagramPacket;
import java.net.InetSocketAddress;

public class ReadRequestTask implements Runnable {
    private final RequestHandler masterHandler;
    private final DatagramPacket packet;

    public ReadRequestTask(RequestHandler masterHandler, DatagramPacket packet) {
        this.masterHandler = masterHandler;
        this.packet = packet;
    }

    @Override
    public void run() {
        InetSocketAddress clientSocketAddress = new InetSocketAddress(packet.getAddress(), packet.getPort());
        try {
            ObjectInputStream bytesToRequestStream = new ObjectInputStream(new ByteArrayInputStream(packet.getData()));
            Request request = (Request) bytesToRequestStream.readObject();
            masterHandler.executeRequest(request, clientSocketAddress);
        } catch (IOException | ClassNotFoundException e) {
            System.out.println(e.getMessage());
        }
    }

}
