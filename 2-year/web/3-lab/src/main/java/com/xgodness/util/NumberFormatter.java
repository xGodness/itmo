package com.xgodness.util;

public class NumberFormatter {
    public static double roundDoubleTwoDigits(Double num) {
        if (num == null) return 0;
        String formatted = String.format("%.2f", num);
        return Double.parseDouble(formatted);
    }
}
