package com.xgodness.controller;

import com.xgodness.model.UserDTO;
import com.xgodness.repository.UserRepository;
import com.xgodness.service.UserService;
import com.xgodness.util.CredsValidator;
import com.xgodness.util.ValidationError;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class AuthController {

    private final UserService userService;
    private final UserRepository repository;
    private final CredsValidator validator;

    public AuthController(UserService userService, UserRepository repository, CredsValidator validator) {
        this.userService = userService;
        this.repository = repository;
        this.validator = validator;
    }

    @PostMapping("/register")
    public ResponseEntity<List<String>> register(@RequestBody UserDTO userDTO) {
        List<String> errorList = validator.validate(userDTO);
        if (userDTO.getUsername() != null && repository.existsByUsername(userDTO.getUsername())) {
            errorList.add(ValidationError.USERNAME_TAKEN.toString());
        }
        if (errorList.isEmpty()) {
            userService.create(userDTO.getUsername(), userDTO.getPassword());
            return new ResponseEntity<>(HttpStatus.CREATED);
        }

        return new ResponseEntity<>(errorList, HttpStatus.BAD_REQUEST);
    }

    @PostMapping("/login")
    public String login() {
        return "Successful";
    }

    @PostMapping("/ping")
    public String ping() {
        return "pong";
    }
}
