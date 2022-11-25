package com.xgodness.controller;

import org.ocpsoft.rewrite.annotation.Join;
import org.ocpsoft.rewrite.el.ELBeanName;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

//@Controller
@Scope(value = "session")
@Component(value = "pointController")
@ELBeanName(value = "pointController")
@Join(path = "/", to = "index.xhtml")
public class PointController {

//    @RequestMapping("/")
    public String home() {
        return "index.xhtml";
    }

    private int cnt = 0;

    public String hello() {
        return "hello %d".formatted(cnt++);
    }

    public String save() {
        return "stub";
    }
}
