package server.database;

import java.util.Random;

public class SaltGenerator {
    private static final String chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
    private static final int charsCount = chars.length();
    public static String generateSalt() {
        StringBuilder sb = new StringBuilder();
        Random random = new Random();
        while (sb.length() < 8) {
            sb.append(chars.charAt(random.nextInt(charsCount)));
        }
        return sb.toString();
    }
}
