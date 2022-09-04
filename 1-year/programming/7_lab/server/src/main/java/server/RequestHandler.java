package server;

import common.requestresponse.Request;
import common.requestresponse.Response;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class RequestHandler {
    private final DatagramSocket serverSocket;
    private final Application application;
    private final ExecutorService readRequestCachedPool = Executors.newCachedThreadPool();
    private final ExecutorService sendResponseFixedPool = Executors.newFixedThreadPool(10);

    public RequestHandler(DatagramSocket serverSocket, Application application) {
        this.serverSocket = serverSocket;
        this.application = application;
    }

    public void readRequest(DatagramPacket packet) {
        ReadRequestTask task = new ReadRequestTask(this, packet);
        readRequestCachedPool.submit(task);
    }

    public void executeRequest(Request request, InetSocketAddress clientSocketAddress) {
        RequestExecutor requestExecutor = new RequestExecutor(this, application, request, clientSocketAddress);
        requestExecutor.start();
    }

    public void sendResponse(Response response, InetSocketAddress clientSocketAddress) {
        SendResponseTask task = new SendResponseTask(serverSocket, response, clientSocketAddress);
        sendResponseFixedPool.submit(task);
    }

}
