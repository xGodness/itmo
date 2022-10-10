package com.xgodness.util;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

public class DateTimeConverter {
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    public static String getDateTimeFromOffset(Integer offset) {
        if (offset == null) {
            return formatter.format(LocalDateTime.now());
        }
        OffsetDateTime dateTime = LocalDateTime.now().atOffset(ZoneOffset.ofTotalSeconds(offset * 60));
        return "%s (GMT%s)".formatted(formatter.format(dateTime), getZoneByOffset(offset));
    }

    public static String getZoneByOffset(int offset) {
        if (offset == 0) {
            return "+00:00";
        }
        return String.format("%+03d:00", -offset / 60);
    }
}


