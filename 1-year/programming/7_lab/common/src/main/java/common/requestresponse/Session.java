package common.requestresponse;

import java.io.Serializable;

public class Session implements Serializable {
    static final long serialVersionUID = 1L;
    private final String username;
    private final String password;

    public Session(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    @Override
    public String toString() {
        return "Session{" +
                "username='" + username + '\'' +
                ", password='" + (password == null ? null : new String(new char[password.length()]).replace("\0", "*")) + '\'' +
                '}';
    }
}
