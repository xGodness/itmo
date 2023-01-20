package com.xgodness.config;

import com.xgodness.security.filter.AuthFilter;
import com.xgodness.security.StartTimeFilter;
import com.xgodness.security.handler.Http401UnauthorizedEntryPoint;
import com.xgodness.security.handler.ReactAuthFailureHandler;
import com.xgodness.security.handler.ReactAuthSuccessHandler;
import com.xgodness.security.handler.ReactLogoutSuccessHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {
    private final Http401UnauthorizedEntryPoint authEntryPoint;
    private final ReactAuthFailureHandler authFailHandler;
    private final ReactAuthSuccessHandler authSucHandler;
    private final ReactLogoutSuccessHandler logoutSucHandler;
    private final StartTimeFilter startTimeFilter;
    private final AuthFilter authFilter;

    public WebSecurityConfig(Http401UnauthorizedEntryPoint authEntryPoint,
                             ReactAuthFailureHandler authFailHandler,
                             ReactAuthSuccessHandler authSucHandler,
                             ReactLogoutSuccessHandler logoutSucHandler,
                             StartTimeFilter startTimeFilter,
                             AuthFilter authFilter) {
        this.authEntryPoint = authEntryPoint;
        this.authFailHandler = authFailHandler;
        this.authSucHandler = authSucHandler;
        this.logoutSucHandler = logoutSucHandler;
        this.startTimeFilter = startTimeFilter;
        this.authFilter = authFilter;
    }


    protected void configure(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
//                .exceptionHandling().authenticationEntryPoint(authEntryPoint).and()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
                .cors(Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        .antMatchers("/login").permitAll()
                        .antMatchers("/register").permitAll()
                        .antMatchers(
                                "/",
                                "/favicon.png",
                                "/favicon.ico",
                                "/static/**",
                                "/**/*.json",
                                "/**/*.html").permitAll()
                        .anyRequest().authenticated()
                )
                .formLogin(form -> form
                        .loginProcessingUrl("/login")
                        .successHandler(authSucHandler)
                        .failureHandler(authFailHandler)
                        .usernameParameter("username")
                        .passwordParameter("password")
                )
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessHandler(logoutSucHandler)
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID"))
                .httpBasic().authenticationEntryPoint((request, response, authException) ->
                        response.sendError(HttpStatus.UNAUTHORIZED.value(), HttpStatus.UNAUTHORIZED.getReasonPhrase()));

        http.addFilterBefore(startTimeFilter, UsernamePasswordAuthenticationFilter.class);
        http.addFilterBefore(authFilter, StartTimeFilter.class);
        http.headers().cacheControl();

//                .csrf().disable()
//                .authorizeRequests().antMatchers("*").permitAll()
//                .anyRequest().permitAll()
//                .and()
//                .formLogin().permitAll()
//                .and()
//                .logout().permitAll()
//                .and()
//                .httpBasic();

            /*.csrf().disable()
            .authorizeRequests()
                .antMatchers("/", "/index", "/home", "/#/signup").permitAll()
                .anyRequest().authenticated()
                .and()
            .formLogin()
                .loginPage("/#/signin").permitAll()
                .and()
            .logout()
                .permitAll()
                .and()
            .httpBasic();*/
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        final UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration corsConfiguration = new CorsConfiguration().applyPermitDefaultValues();
        corsConfiguration.setAllowedMethods(List.of("GET", "POST", "DELETE", "OPTIONS"));
        source.registerCorsConfiguration("/**", corsConfiguration);
        return source;
    }

    /*@Bean
    public BCryptPasswordEncoder bCryptPasswordEncoder () {
        return new BCryptPasswordEncoder();
    }*/

}
