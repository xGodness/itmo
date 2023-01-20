package com.xgodness.util;

import com.xgodness.model.UserDTO;
import org.springframework.stereotype.Component;

import java.util.Base64;

@Component
public class AuthHeaderParser {

    /* Since header uses template "Bearer {token}" */
    private static final int BEGIN_INDEX = 6;

    public UserDTO parse(String authHeader) {
        if (authHeader == null) return null;
        String token = authHeader.substring(BEGIN_INDEX).trim();
        token = new String(Base64.getDecoder().decode(token));
        String[] tokenSplit = token.split(":");
        if (tokenSplit[0] == null || tokenSplit[1] == null) return null;
        return new UserDTO(tokenSplit[0], tokenSplit[1]);
    }

}
