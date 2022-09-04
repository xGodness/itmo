package server.database;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Encryptor {
    private static String hashingAlgorithm = "sha-1";

    public static String encrypt(String text) throws NoSuchAlgorithmException {
        MessageDigest md = MessageDigest.getInstance(hashingAlgorithm);
        byte[] encryptedBytes = md.digest(text.getBytes());
        BigInteger encryptedNumeric = new BigInteger(1, encryptedBytes);
        return encryptedNumeric.toString(16);
    }

    public static void setHashingAlgorithm(String hashingAlgorithm) {
        Encryptor.hashingAlgorithm = hashingAlgorithm;
    }
}
