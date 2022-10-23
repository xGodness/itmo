/* Initialization */

// To be called when the page finishes loading:
function init() {
    draw();
}


/* Canvas and context objects */

let canvas = document.getElementById('canvas');
let ctx = null;

let width = canvas.width;
let height = canvas.height;


// Returns the right boundary of the logical viewport:
function maxX() {
    return 10;
}

// Returns the left boundary of the logical viewport:
function minX() {
    return -10;
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

// Returns the distance between ticks on the X axis:
function xTickDelta() {
    return 1;
}

// Returns the distance between ticks on the Y axis:
function yTickDelta() {
    return 1;
}


// DrawAxes draws the X ad Y axes, with tick marks.
function drawAxis() {
    ctx.save();
    ctx.lineWidth = 2;
    // +Y axis
    ctx.beginPath();
    ctx.moveTo(XC(0),YC(0));
    ctx.lineTo(XC(0),YC(maxY()));
    ctx.stroke();

    // -Y axis
    ctx.beginPath();
    ctx.moveTo(XC(0),YC(0));
    ctx.lineTo(XC(0),YC(minY()));
    ctx.stroke();

    // Y axis tick marks
    let delta = yTickDelta();
    for (let i = 1; (i * delta) < maxY(); ++i) {
        ctx.beginPath();
        ctx.moveTo(XC(0) - 5, YC(i * delta));
        ctx.lineTo(XC(0) + 5, YC(i * delta));
        ctx.stroke();
    }

    for (let i = 1; (i * delta) > minY(); --i) {
        ctx.beginPath();
        ctx.moveTo(XC(0) - 5, YC(i * delta));
        ctx.lineTo(XC(0) + 5, YC(i * delta));
        ctx.stroke();
    }

    // +X axis
    ctx.beginPath();
    ctx.moveTo(XC(0),YC(0));
    ctx.lineTo(XC(maxX()),YC(0));
    ctx.stroke();

    // -X axis
    ctx.beginPath();
    ctx.moveTo(XC(0),YC(0));
    ctx.lineTo(XC(minX()),YC(0));
    ctx.stroke();

    // X tick marks
    delta = xTickDelta();
    for (let i = 1; (i * delta) < maxX(); ++i) {
        ctx.beginPath();
        ctx.moveTo(XC(i * delta),YC(0)-5);
        ctx.lineTo(XC(i * delta),YC(0)+5);
        ctx.stroke();
    }

    for (let i = 1; (i * delta) > minX(); --i) {
        ctx.beginPath();
        ctx.moveTo(XC(i * delta),YC(0)-5);
        ctx.lineTo(XC(i * delta),YC(0)+5);
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
function f2(x) {
    return 9 * Math.sqrt(Math.abs((Math.abs(x) - 1) * (Math.abs(x) - 0.75)) / ((1 - Math.abs(x)) * (Math.abs(x) - 0.75))) - 8 * Math.abs(x);
}
function f3(x) {
    return 2.25 * Math.sqrt(Math.abs((x - 0.5) * (x + 0.5)) / ((0.5 - x) * (0.5 + x)));
}
function f4(x) {
    return 3 * Math.abs(x) + 0.75 * Math.sqrt(Math.abs((Math.abs(x) - 0.75) * (Math.abs(x) - 0.5)) / ((0.75 - Math.abs(x)) * (Math.abs(x) - 0.5)));
}
function f5(x) {
    return 6 * Math.sqrt(10) / 7 + (1.5 - 0.5 * Math.abs(x)) * Math.sqrt(Math.abs(Math.abs(x) - 1) / (Math.abs(x) - 1)) - 6 * Math.sqrt(10) / 14 * Math.sqrt(4 - (Math.abs(x) - 1)**2);
}

// Clears the canvas, draws the axes and graphs the function F.
function draw() {

    if (canvas.getContext) {

        ctx = canvas.getContext('2d');
        ctx.clearRect(0,0, width, height);

        drawAxis();
        renderHead();
        renderBody();
        renderWings();

    } else {
        // Do nothing.
    }
}


function renderHead() {
    ctx.beginPath();
    ctx.moveTo(XC(-1), YC(1));
    ctx.lineTo(XC(-0.75), YC(3));
    ctx.lineTo(XC(-0.5), YC(2.25));
    ctx.lineTo(XC(0.5), YC(2.25));
    ctx.lineTo(XC(0.75), YC(3));
    ctx.lineTo(XC(1), YC(1));
    ctx.lineTo(XC(-1), YC(1));
    ctx.fill();
    ctx.stroke();
    ctx.closePath();
}

function renderBody() {
    ctx.beginPath();
    ctx.moveTo(XC(-3.1), YC(2.711));
    for (let x = minX(); x <= maxX(); x += xStep) {
        let y = f5(x);
        ctx.lineTo(XC(x),YC(y));
    }

    ctx.lineTo(XC(4), YC(-2.462));

    for (let x = maxX(); x >= minX(); x -= xStep) {
        let y = f1(x);
        ctx.lineTo(XC(x),YC(y));
    }
    ctx.lineTo(XC(-3.1), YC(2.711));
    ctx.stroke();
    ctx.fill();
    ctx.closePath();
}

function renderWings() {
    ctx.beginPath();
    ctx.ellipse(XC(0), YC(0), 140, 60, 0, -1.13, 0.96);
    ctx.stroke();
    ctx.fill();
    ctx.closePath();

    ctx.beginPath();
    ctx.ellipse(XC(0), YC(0), 140, 60, 0, 2.18, -2.01);
    ctx.stroke();
    ctx.fill();
    ctx.closePath();
}
