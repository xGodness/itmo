package com.xgodness.util;

import com.xgodness.model.UserDTO;
import org.springframework.stereotype.Component;

import java.util.ArrayList;

import static com.xgodness.util.ValidationError.PASSWORD_TOO_SHORT;
import static com.xgodness.util.ValidationError.USERNAME_TOO_SHORT;

@Component
public class CredsValidator {

    public ArrayList<String> validate(UserDTO userDTO) {
        ArrayList<String> errors = new ArrayList<>();
        validateName(userDTO.getUsername(), errors);
        validatePassword(userDTO.getPassword(), errors);
        return errors;
    }

    private void validateName(String username, ArrayList<String> errors) {
        if (username == null || username.length() == 0) {
            errors.add(USERNAME_TOO_SHORT.toString());
        }
    }

    private void validatePassword(String password, ArrayList<String> errors) {
        if (password == null || password.length() < 3) {
            errors.add(PASSWORD_TOO_SHORT.toString());
        }
    }

}
