package com.xgodness.view;

import lombok.Data;

import javax.annotation.PostConstruct;
import javax.inject.Named;
import java.util.ArrayList;
import java.util.List;

@Data
@Named("radioView")
public class RadioView {
    private List<Integer> xChoices;
    private Integer xValue = 0;

    @PostConstruct
    public void init() {
        xChoices = new ArrayList<>();
        for (int x = -4; x <= 4; x++) {
            xChoices.add(x);
        }
    }


}
