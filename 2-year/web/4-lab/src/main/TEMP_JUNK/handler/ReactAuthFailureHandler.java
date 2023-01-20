package com.xgodness.security.handler;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class ReactAuthFailureHandler extends SimpleUrlAuthenticationFailureHandler {

    private final ReactHeaderHandler headerHandler;

    public ReactAuthFailureHandler(ReactHeaderHandler headerHandler) {
        this.headerHandler = headerHandler;
    }

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException {
        headerHandler.process(request, response);
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication failed");
    }

}
