package com.xgodness.controller;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller(value = "pointController")
@Scope(value = "session")
public class PointController {
    private final String indexPage = "index.xhtml";

    @RequestMapping("/")
    public String defaultRedirect() {
        return indexPage;
    }

}
