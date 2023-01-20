import {pointAction} from "../actions";
import {Button} from "reactstrap";
import {connect} from "react-redux";
import React from "react";

function click(props) {
    props.dispatch(pointAction.clearPoints())
}
const ClearButton = (props) => (
    <Button className={"clear-button"} onClick={() => click(props)}><span>Clear</span><i></i></Button>
)
export default connect()(ClearButton)