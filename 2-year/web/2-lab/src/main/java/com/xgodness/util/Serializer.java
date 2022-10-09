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
        return mapper.readValue(json, ResultRow[].class);
    }
}
