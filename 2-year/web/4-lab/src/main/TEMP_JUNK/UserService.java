package com.xgodness.service;

import com.xgodness.entity.User;
import com.xgodness.model.UserDTO;
import com.xgodness.util.RegistrationResult;

public interface UserService {
    RegistrationResult validateAndSaveUser(UserDTO userDTO);

    User validateAuthAndGetUser(UserDTO userDTO);

    User findUserByUsername(String username);
    boolean checkUserExistence(String username);
}
