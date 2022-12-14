/*
 ______________________________________________________________
|____________________________ NOTE ____________________________|
| I do not recommend you to try to understand how does it work |
|______________________________________________________________|

*/

/* Canvas and context objects */

let canvas = document.getElementById('canvas');
let ctx = null;

let width = canvas.width;
let height = canvas.height;
const magicX = 5;

let batmanCtx = new Path2D();

let r = 4;

// Returns the right boundary of the logical viewport:
function maxX() {
    return magicX / r * 7 / 5;
}

// Returns the left boundary of the logical viewport:
function minX() {
    return -magicX / r * 7 / 5;
}

// Returns the top boundary of the logical viewport:
function maxY() {
    return maxX() * height / width;
}

// Returns the bottom boundary of the logical viewport:
function minY() {
    return minX() * height / width;
}

// Returns the physical x-coordinate of a logical x-coordinate:
function XC(x) {
    return (x - minX()) / (maxX() - minX()) * width;
}

// Returns the physical y-coordinate of a logical y-coordinate:
function YC(y) {
    return height - (y - minY()) / (maxY() - minY()) * height;
}


// ------------------------------------------------------------------------
function maxXabs() {
    return magicX;
}
function minXabs() {
    return -magicX;
}
function maxYabs() {
    return maxXabs() * height / width;
}
function minYabs() {
    return minXabs() * height / width;
}
function XCabs(x) {
    return (x - minXabs()) / (maxXabs() - minXabs()) * width;
}
function YCabs(y) {
    return height - (y - minYabs()) / (maxYabs() - minYabs()) * height;
}

function inverseXC(x) {
    return x * (maxXabs() - minXabs()) / width + minXabs();
}
function inverseYC(y) {
    return (height - y) / height * (maxYabs() - minYabs()) + minYabs();
}
// ------------------------------------------------------------------------


// Returns the distance between ticks on the X axis:
function xTickDelta() {
    return 1;
}

// Returns the distance between ticks on the Y axis:
function yTickDelta() {
    return 1;
}


// DrawAxes draws the X ad Y axes, with tick marks.
function drawAxes() {
    ctx.save();
    ctx.lineWidth = 2;
    // +Y axis
    ctx.beginPath();
    ctx.moveTo(XCabs(0), YCabs(0));
    ctx.lineTo(XCabs(0), YCabs(maxYabs()));
    ctx.stroke();

    // -Y axis
    ctx.beginPath();
    ctx.moveTo(XCabs(0), YCabs(0));
    ctx.lineTo(XCabs(0), YCabs(minYabs()));
    ctx.stroke();

    // Y axis tick marks
    let delta = yTickDelta();
    for (let i = 1; (i * delta) < maxYabs(); ++i) {
        ctx.beginPath();
        ctx.moveTo(XCabs(0) - 5, YCabs(i * delta));
        ctx.lineTo(XCabs(0) + 5, YCabs(i * delta));
        ctx.stroke();
    }

    for (let i = 1; (i * delta) > minYabs(); --i) {
        ctx.beginPath();
        ctx.moveTo(XCabs(0) - 5, YCabs(i * delta));
        ctx.lineTo(XCabs(0) + 5, YCabs(i * delta));
        ctx.stroke();
    }

    // +X axis
    ctx.beginPath();
    ctx.moveTo(XCabs(0), YCabs(0));
    ctx.lineTo(XCabs(maxXabs()), YCabs(0));
    ctx.stroke();

    // -X axis
    ctx.beginPath();
    ctx.moveTo(XCabs(0), YCabs(0));
    ctx.lineTo(XCabs(minXabs()), YCabs(0));
    ctx.stroke();

    // X tick marks
    delta = xTickDelta();
    for (let i = 1; (i * delta) < maxXabs(); ++i) {
        ctx.beginPath();
        ctx.moveTo(XCabs(i * delta), YCabs(0) - 5);
        ctx.lineTo(XCabs(i * delta), YCabs(0) + 5);
        ctx.stroke();
    }

    for (let i = 1; (i * delta) > minXabs(); --i) {
        ctx.beginPath();
        ctx.moveTo(XCabs(i * delta), YCabs(0) - 5);
        ctx.lineTo(XCabs(i * delta), YCabs(0) + 5);
        ctx.stroke();
    }
    ctx.restore();
}


// When rendering, xStep determines the horizontal distance between points:
let xStep = (maxX() - minX()) / width / 64;


/* Rendering functions */

function f1(x) {
    return Math.abs(x / 2) - (3 * Math.sqrt(33) - 7) / 112 * x**2 - 3 + Math.sqrt(1 - (Math.abs(Math.abs(x) - 2) - 1)**2);
}

function f5(x) {
    return 6 * Math.sqrt(10) / 7 + (1.5 - 0.5 * Math.abs(x)) * Math.sqrt(Math.abs(Math.abs(x) - 1) / (Math.abs(x) - 1)) - 6 * Math.sqrt(10) / 14 * Math.sqrt(4 - (Math.abs(x) - 1)**2);
}

// Clears the canvas, draws the axes and graphs the function F.
function draw() {

    if (canvas.getContext) {

        // ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, width, height);

        batmanCtx = new Path2D();

        // ctx.fillStyle = 'magenta';
        ctx.fillStyle = 'white';
        // ctx.fillStyle = '#87ab08';

        ctx.strokeStyle = 'crimson';

        r /= 5;

        renderHead(batmanCtx);
        renderBody(batmanCtx);
        renderWings(batmanCtx);
        ctx.fill(batmanCtx);

        drawAxes();

        // addBatmanListener(batmanCtx);

    } else {
        // Do nothing.
    }

}

function renderHead(batmanCtx) {
    batmanCtx.moveTo(XC(-1), YC(1));
    batmanCtx.lineTo(XC(-0.75), YC(3));
    batmanCtx.lineTo(XC(-0.5), YC(2.25));
    batmanCtx.lineTo(XC(0.5), YC(2.25));
    batmanCtx.lineTo(XC(0.75), YC(3));
    batmanCtx.lineTo(XC(1), YC(1));
    batmanCtx.lineTo(XC(-1), YC(1));
}

function renderBody(batmanCtx) {
    batmanCtx.moveTo(XC(-3.1), YC(2.711));
    for (let x = minX(); x <= maxX(); x += xStep) {
        let y = f5(x);
        batmanCtx.lineTo(XC(x), YC(y));
    }

    batmanCtx.lineTo(XC(4), YC(-2.462));

    for (let x = maxX(); x >= minX(); x -= xStep) {
        let y = f1(x);
        batmanCtx.lineTo(XC(x), YC(y));
    }

    batmanCtx.lineTo(XC(-3.1), YC(2.711));
}

function renderWings(batmanCtx) {
    batmanCtx.moveTo(XC(3.5), YC(0));
    batmanCtx.ellipse(XC(0), YC(0), XC(7) - XC(0), YC(0) - YC(3), 0, -1.13, 0.96);
    ctx.stroke(batmanCtx);

    batmanCtx.moveTo(XC(-3.5), YC(0));
    batmanCtx.ellipse(XC(0), YC(0), XC(7) - XC(0), YC(0) - YC(3), 0, 2.18, -2.01);
    ctx.stroke(batmanCtx);
}

function addBatmanListener(batmanCtx) {
    canvas.addEventListener('mousemove', (event) => {
        // Check whether point is inside
        const isPointInPath = ctx.isPointInPath(batmanCtx, event.offsetX, event.offsetY);
        ctx.fillStyle = isPointInPath ? 'green' : 'red';

        // Draw
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.stroke(batmanCtx);
        ctx.fill(batmanCtx);

        drawAxes();
    });
}

function checkPoint(x, y) {
    return ctx.isPointInPath(batmanCtx, XCabs(x), YCabs(y));
}

function drawPoints() {
    console.log("[INFO] drawing start...")
    let rows = document.querySelectorAll("#results-table tr");
    console.log(`[INFO] found ${rows.length} rows in table (including header)`);
    let data;
    let x, y;
    for (let i = 1; i < rows.length; i++) {
        data = rows[i].querySelectorAll("td");
        x = parseFloat(data[0].innerHTML);
        y = parseFloat(data[1].innerHTML);

        if (isNaN(x) || isNaN(y)) return;

        ctx.beginPath();
        ctx.arc(XCabs(x), YCabs(y), 4, 0, 2 * Math.PI, false);
        ctx.fillStyle = checkPoint(x, y) ? "green" : "red";
        ctx.fill();
        ctx.closePath();

        console.log(`[INFO] drew point: x=${x}, y=${y}`);
    }
}

function restoreDefaultXY() {
    document.getElementById("radio-x-0").click();
    document.getElementsByName("submit-form:input-y_hinput")[0].setAttribute("value", "0");
    document.getElementById("submit-form:input-y_input").setAttribute("value", "0");
    document.getElementById("submit-form:input-y").setAttribute("value", "0");
}

function processClick(event) {
    let rect = canvas.getBoundingClientRect();

    let x = inverseXC(event.clientX - rect.left);
    let y = inverseYC(event.clientY - rect.top);

    document.getElementsByName("submit-form:input-x_hinput")[0].setAttribute("value", x);
    document.getElementsByName("submit-form:input-y_hinput")[0].setAttribute("value", y);

    document.getElementById("submit-form:submit-button").click();
    restoreDefaultXY();
}

function changeX(x) {
    document.getElementsByName("submit-form:input-x_hinput")[0].setAttribute("value", x);
}

function getOffsetString() {
    return (new Date()).getTimezoneOffset().toString();
}

function setOffsetAndHit() {
    document.getElementById("submit-form:input-offset")
        .setAttribute("value", getOffsetString());

    let x = document.getElementsByName("submit-form:input-x_hinput")[0].getAttribute("value");
    let y = document.getElementsByName("submit-form:input-y_hinput")[0].getAttribute("value");
    let hit = checkPoint(x, y);

    document.getElementById("submit-form:input-hit").setAttribute("value", hit);
}

function addCanvasListener() {
    document.getElementById("canvas").addEventListener("click", (event) => {
        processClick(event);
    });
}

/* Initialization */

function initVars() {
    if (canvas === null) {
        canvas = document.getElementById('canvas');
    }
    if (ctx === null) {
        ctx = canvas.getContext('2d');
    }
    width = canvas.width;
    height = canvas.height;
}

function initGraph(newR) {
    if (newR) {
        r = newR;
        console.log("new r value: " + r);
    } else r = 4;

    if (canvas === null || ctx === null) {
        initVars();
    }
    draw();
    drawPoints();
}

function init() {
    initVars();
    initGraph();
    addCanvasListener();
}