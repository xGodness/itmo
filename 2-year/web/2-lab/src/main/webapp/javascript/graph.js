const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

const black = "black";
const aquamarine = "aquamarine";
const point_colour = "#ff947f";

let w = canvas.width;
let h = canvas.height;
let center_w = w / 2;
let center_h = h / 2;
let center_x = center_w;
let center_y = center_h;
let tick_x = w / 12;
let tick_y = h / 12;

function draw() {
    let r = localStorage.getItem("R");
    if (r === "null") {
        r = 4;
    }

    ctx.clearRect(0, 0, w, h);

    // drawing properties
    ctx.strokeStyle = black;
    ctx.fillStyle = aquamarine;
    ctx.lineWidth = 2.5;

    // draw first quarter
    ctx.beginPath();
    ctx.arc(center_x, center_y, r * tick_y / 2, - Math.PI / 2, 0);
    ctx.lineTo(center_x, center_y);
    ctx.lineTo(center_x, center_y - r * tick_y / 2);
    ctx.fill()
    ctx.closePath();

    // draw second quarter
    ctx.beginPath();
    ctx.fillRect(center_x, center_y, -r * tick_x, -r * tick_y);
    ctx.closePath();

    // draw third quarter
    ctx.beginPath();
    ctx.moveTo(center_x, center_y);
    ctx.lineTo(center_x - r * tick_x, center_y);
    ctx.lineTo(center_x, center_y + r * tick_y / 2);
    ctx.lineTo(center_x, center_y);
    ctx.fill();
    ctx.closePath();

    // draw x axis
    ctx.beginPath();
    ctx.moveTo(0, center_h);
    ctx.lineTo(w, center_h);
    ctx.lineTo(w - tick_x, center_h - tick_y / 4);
    ctx.moveTo(w, center_h);
    ctx.lineTo(w - tick_x, center_h + tick_y / 4);
    ctx.stroke();
    ctx.closePath();

    // draw y axis
    ctx.beginPath();
    ctx.moveTo(center_w, 0);
    ctx.lineTo(center_w, h);
    ctx.moveTo(center_w, 0);
    ctx.lineTo(center_w - tick_x / 4, tick_y);
    ctx.moveTo(center_w, 0);
    ctx.lineTo(center_w + tick_x / 4, tick_y);
    ctx.stroke();
    ctx.closePath();

    // draw tick marks
    ctx.beginPath();
    for (let i = -6; i < 7; i++) {
        let dx = center_x + i * tick_x;
        let dy = center_y + i * tick_y;
        ctx.moveTo(dx, center_y + 3);
        ctx.lineTo(dx, center_y - 3);
        ctx.moveTo(center_x + 3, dy);
        ctx.lineTo(center_x - 3, dy);
    }
    ctx.stroke();
    ctx.closePath();
    
    // draw letters
    ctx.beginPath();
    ctx.font = "24px sans-serif";
    ctx.fillStyle = black;
    ctx.fillText("R", center_w + r * tick_x, center_y + tick_y / 1.5);
    ctx.fillText("R", center_w - r * tick_x, center_y + tick_y / 1.5);
    ctx.fillText("R", center_w + tick_x / 5, center_y + r * tick_y + 10);
    ctx.fillText("R", center_w + tick_x / 5, center_y - r * tick_y + 10);
    ctx.closePath();

}

function draw_point(point_x, point_y) {
    point_y = -point_y;
    ctx.beginPath();
    ctx.strokeStyle = point_colour;
    ctx.fillStyle = point_colour;
    ctx.arc(center_x + point_x * tick_x, center_y + point_y * tick_y, 4, 0, Math.PI * 2);
    ctx.stroke();
    ctx.fill();
    ctx.closePath();
}

function clickOnGraph(canvas, event) {
    let rect = canvas.getBoundingClientRect();

    let x = -(center_x - (event.clientX - rect.left)) / tick_x;
    let y = (center_y - (event.clientY - rect.top)) / tick_y;

    let input_r_field = document.getElementById("input-r");
    let message_field = document.getElementById("message");

    message_field.innerText = "";

    let r = input_r_field.value.replace(",", ".");
    if (r === "" || isNaN(r)) {
        input_r_field.value = "";
        message_field.innerText += "[Warning] R parameter must be valid number" + '\n';
        event.preventDefault();
        return;
    }
    if (r.length > 16) {
        input_r_field.value = "";
        message_field.innerText +=  "[Warning] R parameter too long (max 16 chars)" + '\n';
        event.preventDefault();
        return;
    }

    r = parseFloat(r);
    if (r <= 2 || r >= 5) {
        message_field.innerText += "[Warning] R parameter must be between 2 and 5 (exclusive)" + '\n';
        event.preventDefault();
        return;
    }

    $.ajax({
        type: "POST",
        url: "main",
        data: {
            "x": x,
            "y": y,
            "r": r,
            "timezone_offset": new Date().getTimezoneOffset()
        },
        success: function (result) {
            console.log(result)
            let newDom = (new DOMParser()).parseFromString(result, "text/html");
            document.getElementsByTagName('body')[0].innerHTML = newDom.body.innerHTML;
            location.reload();
        },
        dataType: "text"
    });

}

function init() {
    draw();
    canvas.addEventListener('click', event => clickOnGraph(canvas, event));
    console.log("event listener should be added");
}