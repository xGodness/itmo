package com.xgodness.security.handler;

import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AbstractAuthenticationTargetUrlRequestHandler;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
public class ReactLogoutSuccessHandler
        extends AbstractAuthenticationTargetUrlRequestHandler
        implements LogoutSuccessHandler {

    private final ReactHeaderHandler headerHandler;

    public ReactLogoutSuccessHandler(ReactHeaderHandler headerHandler) {
        this.headerHandler = headerHandler;
    }

    @Override
    public void onLogoutSuccess(HttpServletRequest request,
                                HttpServletResponse response,
                                Authentication authentication) {
        if (authentication != null && authentication.getDetails() != null) {
            try {
                headerHandler.process(request, response);
                request.getSession().invalidate();
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception ex) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                System.out.println(ex.getMessage());
            }
        }
    }

}
