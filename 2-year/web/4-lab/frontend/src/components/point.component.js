import React from "react";
import {connect} from "react-redux";

const Point = ({x, y, r, curTime, executionTime, hit}) => (
    <tr>
        <td>
            ({x}, {y})
        </td>
        <td>
            {r}
        </td>
        <td>
            {curTime}
        </td>
        <td>
            {(executionTime / 1000000).toFixed(3)}
        </td>
        <td>
            {hit ? "Penetration" : "Failure"}
        </td>
    </tr>
);

export default connect()(Point);