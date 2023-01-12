let canvas = document.getElementById("canvas");
let ctx = canvas.getContext("2d");

let width = canvas.width;
let height = canvas.height;
let minX = 40;
let maxX = width - minX;
let minY = 40;
let maxY = height - minY;

let r = 2;

let cx = width / 2;
let cy = height / 2;
let tickX = (maxX - cx) / r;
let tickY = (maxY - cy) / r;

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

    for (let i = 1; i <= Math.ceil(r); i++) {
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

    graphCtx.ellipse(trX(0), trY(0), tickX, tickY, 0, 0, Math.PI / 2);

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

function loadGraph(newR) {
    drawGraph(newR);
    drawAxes();
}