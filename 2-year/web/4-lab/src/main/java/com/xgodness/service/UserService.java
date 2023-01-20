package com.xgodness.service;

import com.xgodness.entity.User;
import com.xgodness.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class UserService {
    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository repository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    public void create(String username, String password) {
        repository.save(new User(username, passwordEncoder.encode(password)));
    }
}
