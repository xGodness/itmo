import React, {useState} from "react";
import {InputNumber} from "primereact/inputnumber";
import {Slider} from "primereact/slider";
import {coordsAction, pointAction} from "../actions";
import {connect} from "react-redux";
import {Label} from "reactstrap";

const PointForm = (props) => {
    const [x, setX] = useState(0);
    const [y, setY] = useState(0);
    const [r, setR] = useState(2);

    const changeCoords = (x, y, r) => {
        props.dispatch(coordsAction.updateCoords(
            {
                x: x,
                y: y,
                r: r
            }
        ))
    }

    const clickX = (e) => {
        let newX = x;
        if ((e.target.classList.contains("p-inputnumber-button-up") || e.target.classList.contains("pi-angle-up")) && x < 5) {
            newX += 0.5
        } else if ((e.target.classList.contains("p-inputnumber-button-down") || e.target.classList.contains("pi-angle-down")) && x > -5) {
            newX -= 0.5
        }
        setX(newX);
        changeCoords(newX, y, r);
    }

    const clickR = (e) => {
        let newR = r;
        if ((e.target.classList.contains("p-inputnumber-button-up") || e.target.classList.contains("pi-angle-up")) && r < 4) {
            newR += 0.5;
        } else if ((e.target.classList.contains("p-inputnumber-button-down") || e.target.classList.contains("pi-angle-down")) && r > 1) {
            newR -= 0.5;
        }
        setR(newR);
        changeCoords(x, y, newR);
    }

    const onYChange = (e) => {
        setY(e.value);
        changeCoords(x, e.value, r);
    }

    const onSubmit = (e) => {
        e.preventDefault();

        props.dispatch(
            pointAction.createPoint(
                {
                    x: x,
                    y: y,
                    r: r,
                    timeZone: (new Date()).getTimezoneOffset(),
                }
            )
        );
    }

    const onReset = () => {
        setX(0);
        setY(0);
        setR(2);
        changeCoords(0, 0, 2);
    }

    return (
        <div className={"add-div"}>
            <form onSubmit={onSubmit} className="form">
                <div className={"x-div"}>
                    <Label for={"x"}>X: </Label>
                    <InputNumber
                        className={"x-input"}
                        name={"x"}
                        placeholder="x"
                        showButtons
                        required={true}
                        readOnly
                        value={x}
                        onClick={(e) => clickX(e)}/>
                </div>
                <div className={"y-div"}>
                    <Label for={"y"}>Y: </Label>
                    <Slider
                        className={"y-input"}
                        name={"y"}
                        placeholder="y"
                        min={-5}
                        max={5}
                        step={0.1}
                        value={y}
                        onChange={(e) => onYChange(e)}/>
                </div>
                <div className={"r-div"}>
                    <Label for={"r"}>R: </Label>
                    <InputNumber
                        className={"r-input"}
                        name={"r"}
                        placeholder="r"
                        showButtons
                        required={true}
                        readOnly
                        value={r}
                        onClick={(e) => clickR(e)}/>
                </div>
                <button type={"submit"} className={"add-button"}><span>Add point</span><i></i></button>
                <button type={"reset"} className={"reset-button"} onClick={onReset}><span>Reset</span><i></i></button>
            </form>
        </div>
    );
}

export default connect()(PointForm);