package com.xgodness.security.filter;

import com.xgodness.entity.User;
import com.xgodness.model.UserDTO;
import com.xgodness.security.SecurityContextProvider;
import com.xgodness.security.UserTokenProvider;
import com.xgodness.service.UserService;
import com.xgodness.util.AuthHeaderParser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class AuthFilter extends OncePerRequestFilter {

    private final String AUTHORIZATION = "Authorization";

    private final UserService userService;
    private final UserTokenProvider tokenProvider;
    private final SecurityContextProvider contextProvider;
    private final AuthHeaderParser headerParser;

    public AuthFilter(UserService userService,
                      UserTokenProvider tokenProvider,
                      SecurityContextProvider contextProvider,
                      AuthHeaderParser headerParser) {
        this.userService = userService;
        this.tokenProvider = tokenProvider;
        this.contextProvider = contextProvider;
        this.headerParser = headerParser;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(AUTHORIZATION);
        if (authHeader == null) return;

        UserDTO userDTO = headerParser.parse(authHeader);
        SecurityContext context = contextProvider.getContext();
        if (context.getAuthentication() != null) return;

        User user = userService.validateAuthAndGetUser(userDTO);
        if (user == null) return;

        Authentication auth = tokenProvider.create(user);
        context.setAuthentication(auth);
        request.setAttribute("username", user.getUsername());

        chain.doFilter(request, response);
    }
}
