package com.xgodness.util;

import lombok.Data;
import org.springframework.http.HttpStatus;

import java.util.ArrayList;

@Data
public class RegistrationResult {
    private boolean isSuccessful;
    private ArrayList<String> messageList;
    private HttpStatus status;
}
