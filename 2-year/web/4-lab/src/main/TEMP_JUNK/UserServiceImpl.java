package com.xgodness.service;

import com.xgodness.entity.User;
import com.xgodness.model.UserDTO;
import com.xgodness.repository.UserRepository;
import com.xgodness.util.CredsValidator;
import com.xgodness.util.RegistrationResult;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

import static com.xgodness.util.ValidationError.USERNAME_TAKEN;

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository repository;

    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    private final CredsValidator validator;

    public UserServiceImpl(UserRepository repository, BCryptPasswordEncoder bCryptPasswordEncoder, CredsValidator validator) {
        this.repository = repository;
        this.bCryptPasswordEncoder = bCryptPasswordEncoder;
        this.validator = validator;
    }

    @Override
    public RegistrationResult validateAndSaveUser(UserDTO userDTO) {

        RegistrationResult result = new RegistrationResult();
        ArrayList<String> messages = validator.validate(userDTO);
        result.setMessageList(messages); // TODO: test with existing username

        if (checkUserExistence(userDTO.getUsername())) {
            messages.add(USERNAME_TAKEN.toString());
            result.setSuccessful(false);
            result.setStatus(HttpStatus.BAD_REQUEST);
            return result;
        }

        User user = new User();
        user.setUsername(userDTO.getUsername());
        user.setPassword(bCryptPasswordEncoder.encode(userDTO.getPassword()));

        repository.save(user);

        messages.add("Successful");
        result.setSuccessful(true);
        result.setStatus(HttpStatus.CREATED);
        return result;
    }

    @Override
    public User validateAuthAndGetUser(UserDTO userDTO) {
        if (userDTO == null || userDTO.getUsername() == null || userDTO.getPassword() == null) return null;
        String username = userDTO.getUsername();
        String password = userDTO.getPassword();

        User user = findUserByUsername(username);
        if (user == null) return null;

        if (bCryptPasswordEncoder.matches(password, user.getPassword())) {
            return user;
        }

        return null;
    }

    @Override
    public User findUserByUsername(String username) {
        return repository.findByUsername(username);
    }

    @Override
    public boolean checkUserExistence(String username) {
        return repository.existsByUsername(username);
    }
}
