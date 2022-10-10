package com.xgodness.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.xgodness.model.ResultRow;

public class Serializer {
    private static final JsonMapper mapper = new JsonMapper();

    public static String serialize(Object obj) throws JsonProcessingException {
        return mapper.writeValueAsString(obj);
    }

    public static ResultRow[] deserializeRows(String json) throws JsonProcessingException {
        ResultRow[] rows = mapper.readValue(json, ResultRow[].class);
        ResultRow r;
        int l = rows.length;
        for (int i = 0; i < l / 2; i++) {
            r = rows[i];
            System.out.println(r);
            rows[i] = rows[l - i - 1];
            rows[l - i - 1] = r;
        }
        return rows;
    }
}
