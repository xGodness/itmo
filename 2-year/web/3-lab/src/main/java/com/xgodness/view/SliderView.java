package com.xgodness.view;

import javax.enterprise.context.RequestScoped;
import javax.inject.Named;

@Named("sliderView")
@RequestScoped
public class SliderView {
    private float value = 3;

    public float getValue() {
        return value;
    }

    public void setValue(float value) {
        this.value = value;
        System.out.printf("New R value: %f%n", value);
    }
}
