package com.xgodness.security.handler;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class Http401UnauthorizedEntryPoint implements AuthenticationEntryPoint {

    private final ReactHeaderHandler headerHandler;

    public Http401UnauthorizedEntryPoint(ReactHeaderHandler headerHandler) {
        this.headerHandler = headerHandler;
    }

    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException arg2) throws IOException {
        headerHandler.process(request, response);
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Access Denied");
    }

}
