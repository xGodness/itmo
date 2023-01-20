package com.xgodness.security;

import com.xgodness.entity.User;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.Collections;

@Component
public class UserTokenProvider {

    public UsernamePasswordAuthenticationToken create(User user) {
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getRole());
        return new UsernamePasswordAuthenticationToken(
                user.getUsername(),
                user.getPassword(),
                Collections.singletonList(authority)
        );
    }

}
