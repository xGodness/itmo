package com.xgodness.util;

public enum ValidationError {
    USERNAME_TAKEN("User with such name already exists"),
    USERNAME_TOO_SHORT("Username must contain at least 1 character"),
    PASSWORD_TOO_SHORT("Password must contain at least 3 characters");

    private final String label;

    ValidationError(String label) {
        this.label = label;
    }

    @Override
    public String toString() {
        return label;
    }
}
