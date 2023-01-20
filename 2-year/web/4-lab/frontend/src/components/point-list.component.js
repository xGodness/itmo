import React from "react";
import {connect} from "react-redux";
import Point from "./point.component";

const PointList = (props) => (
    <div>
        <table className={"results"}>
            <thead>
            <tr>
                <td className={"coords-col"}>Coords</td>
                <td className={"radius-col"}>Radius</td>
                <td className={"cur-time-col"}>Current time</td>
                <td className={"ex-time-col"}>Execution time (ms)</td>
                <td className={"result-col"}>Result</td>
            </tr>
            </thead>
            <tbody>
            {
                props.points.map(point => {
                    return (
                        <Point {...point} key={point.id}/>
                    );
                })
            }
            </tbody>
        </table>
    </div>
);

const mapStateToProps = (state) => {
    const {points} = state;
    return {
        points
    };
}

export default connect(mapStateToProps)(PointList);