import React, {useEffect} from "react";
import PointList from "./components/point-list.component";
import {connect} from "react-redux";
import {pointAction} from "./actions";
import Graph from "./components/graph.component";
import PointForm from "./components/form.component";
import ClearButton from "./components/clear-button.component";
import LogoutButton from "./components/logout.component";
const Main = (props) => {
    useEffect(() => {
        props.dispatch(pointAction.getPoints())
    });
    return (
        <div className={"app-div"}>
            <div className={"main-div"}>
                <PointForm/>
                <Graph/>
            </div>
            <LogoutButton/>
            <ClearButton/>
            <PointList/>
        </div>

    );
}

export default connect()(Main)