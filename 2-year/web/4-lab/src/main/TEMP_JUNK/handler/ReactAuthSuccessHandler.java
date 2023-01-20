package com.xgodness.security.handler;

import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class ReactAuthSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final ReactHeaderHandler headerHandler;

    public ReactAuthSuccessHandler(ReactHeaderHandler headerHandler) {
        this.headerHandler = headerHandler;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        headerHandler.process(request, response);
    }

}
