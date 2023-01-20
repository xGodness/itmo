import React, {createRef} from "react";
import {connect} from "react-redux";
import {pointAction} from "../actions";
import "../css/canvas.css";

const Graph = (props) => {

    let {x, y, r} = props.coords;
    const ref = createRef();
    function initGraph() {
        let canvas = ref.current;
        let ctx = canvas.getContext("2d");

        let width = canvas.width;

        let height = canvas.height;
        let minX = 40;
        let maxX = width - minX;
        let minY = 40;
        let maxY = height - minY;

        ctx.clearRect(0, 0, width, height);

        if (!r) {
            r = 2;
        }

        let cx = width / 2;
        let cy = height / 2;
        let tickX = (maxX - cx) / 5;
        let tickY = (maxY - cy) / 5;

        let graphCtx = new Path2D();

        function trX(x) {
            return cx + x * tickX;
        }

        function trY(y) {
            return (y < 0) ? (-y * tickY + cy) : (cy - y * tickY);
        }

        function drawAxes() {
            ctx.stroke();

            ctx.beginPath();

            ctx.moveTo(minX, cy);
            ctx.lineTo(maxX, cy);
            ctx.stroke();

            ctx.moveTo(cx, minY);
            ctx.lineTo(cx, maxY);
            ctx.stroke();

            for (let i = 1; i <= Math.ceil(5); i++) {
                ctx.moveTo(trX(i), cy + 5);
                ctx.lineTo(trX(i), cy - 5);
                ctx.moveTo(trX(-i), cy + 5);
                ctx.lineTo(trX(-i), cy - 5);
                ctx.moveTo(cx + 5, trY(i));
                ctx.lineTo(cx - 5, trY(i));
                ctx.moveTo(cx + 5, trY(-i));
                ctx.lineTo(cx - 5, trY(-i));
            }

            ctx.stroke();
            ctx.closePath();
        }

        function drawGraph(newR) {
            if (newR) r = newR;
            if (r <= 0 || r > 5) r = 2;

            graphCtx = new Path2D();

            graphCtx.moveTo(trX(0), trY(0));
            graphCtx.lineTo(trX(0), trY(r));
            graphCtx.lineTo(trX(r), trY(0));
            graphCtx.lineTo(trX(0), trY(0));

            graphCtx.ellipse(trX(0), trY(0), tickX * r, tickY * r, 0, 0, Math.PI / 2);

            graphCtx.moveTo(trX(0), trY(0));
            graphCtx.lineTo(trX(0), trY(-r));
            graphCtx.lineTo(trX(-r), trY(-r));
            graphCtx.lineTo(trX(-r), trY(0));
            graphCtx.lineTo(trX(0), trY(0));

            ctx.fillStyle = "grey";
            ctx.fill(graphCtx);
        }

        function checkPoint(x, y) {
            return ctx.isPointInPath(graphCtx, trX(x), trY(y));
        }

        function drawPoints() {
            props.points.forEach(point => {
                ctx.beginPath();
                ctx.arc(trX(point.x), trY(point.y), 4, 0, 2 * Math.PI, false);
                let color = checkPoint(point.x, point.y) ? "green" : "red";
                ctx.strokeStyle = color;
                ctx.fillStyle = color;
                ctx.fill();
                ctx.closePath();
            })
        }

        ctx.fillStyle = "grey";
        ctx.strokeStyle = "black";

        drawGraph();
        drawAxes();
        drawPoints();
        ctx.beginPath();
        let color = "blue";
        ctx.strokeStyle = color;
        ctx.fillStyle = color;
        ctx.arc(trX(x), trY(y), 4, 0, 2 * Math.PI, false);
        ctx.fill();
        ctx.closePath();
    }

    React.useEffect(() => initGraph(), [initGraph]);

    const onClick = (e) => {
        props.dispatch(pointAction.createPoint({
            x: ((e.nativeEvent.offsetX - 200) / 32).toFixed(2),
            y: ((200 - e.nativeEvent.offsetY) / 32).toFixed(2),
            r: props.coords.r,
            timeZone: (new Date()).getTimezoneOffset()
        }))
    }

    return (
        <div className={"graph-div"}>
            <div className={"canvas-container"}>
            <canvas ref={ref} width="400" height="400" onClick={(e) => onClick(e)}/>
        </div>
    </div>
    );
}


const mapStateToProps = (state) => {
    const {coords, points} = state;
    return {
        coords,
        points
    };
}

export default connect(mapStateToProps)(Graph);
