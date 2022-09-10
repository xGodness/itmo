window.onload = function () {
    draw();
};

function draw(new_r, point_x, point_y) {
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

    let r = 4;
    if (new_r != null) {
        r = new_r;
    }

    ctx.clearRect(0, 0, w, h);


    // drawing properties
    ctx.strokeStyle = black;
    ctx.fillStyle = aquamarine;
    ctx.lineWidth = 2.5;

    // draw first quarter
    ctx.beginPath();
    ctx.arc(center_x, center_y, r * tick_y, - Math.PI / 2, 0);
    ctx.lineTo(center_x, center_y);
    ctx.lineTo(center_x, center_y - r * tick_y);
    ctx.fill()
    ctx.closePath();

    // draw second quarter
    ctx.beginPath();
    ctx.moveTo(center_x, center_y - r * tick_y / 2);
    ctx.lineTo(center_x - r * tick_x / 2, center_y);
    ctx.lineTo(center_x, center_y);
    ctx.lineTo(center_x, center_y - r * tick_y / 2);
    ctx.fill();
    ctx.closePath();

    // draw fourth quarter
    ctx.beginPath();
    ctx.fillRect(center_x, center_y, r * tick_x, r * tick_y / 2);
    ctx.closePath();

    // draw x axis
    ctx.beginPath();
    ctx.moveTo(0, center_h);
    ctx.lineTo(w, center_h);
    ctx.stroke();
    ctx.closePath();

    // draw y axis
    ctx.beginPath();
    ctx.moveTo(center_w, 0);
    ctx.lineTo(center_w, h);
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

    // draw user point
    ctx.beginPath();
    ctx.strokeStyle = point_colour;
    ctx.fillStyle = point_colour;
    ctx.arc(center_x + point_x * tick_x, center_y + point_y * tick_y, 4, 0, Math.PI * 2);
    ctx.stroke();
    ctx.fill();
    ctx.closePath();

}
