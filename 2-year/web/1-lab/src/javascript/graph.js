window.onload = function () {
    draw();
};

function draw() {
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext("2d");

    const black = "black";
    const aquamarine = "aquamarine";

    let w = canvas.width;
    let h = canvas.height;
    let centerW = w / 2;
    let centerH = h / 2;
    let centerX = centerW;
    let centerY = centerH;
    let tickX = w / 12;
    let tickY = h / 12;

    let r = 4;


    // drawing properties
    ctx.strokeStyle = black;
    ctx.fillStyle = aquamarine;
    ctx.lineWidth = 2.5;

    // draw first quarter
    ctx.beginPath();
    ctx.arc(centerX, centerY, r * tickY, - Math.PI / 2, 0);
    ctx.lineTo(centerX, centerY);
    ctx.lineTo(centerX, centerY - r * tickY);
    ctx.fill()
    ctx.closePath();

    // draw second quarter
    ctx.beginPath();
    ctx.moveTo(centerX, centerY - r * tickY / 2);
    ctx.lineTo(centerX - r * tickX / 2, centerY);
    ctx.lineTo(centerX, centerY);
    ctx.lineTo(centerX, centerY - r * tickY / 2);
    ctx.fill();
    ctx.closePath();

    // draw fourth quarter
    ctx.beginPath();
    ctx.fillRect(centerX, centerY, r * tickX, r * tickY / 2);
    ctx.closePath();

    // draw x axis
    ctx.beginPath();
    ctx.moveTo(0, centerH);
    ctx.lineTo(w, centerH);
    ctx.stroke();
    ctx.closePath();

    // draw y axis
    ctx.beginPath();
    ctx.moveTo(centerW, 0);
    ctx.lineTo(centerW, h);
    ctx.stroke();
    ctx.closePath();

    // draw tick marks
    ctx.beginPath();
    for (let i = -6; i < 7; i++) {
        let dx = centerX + i * tickX;
        let dy = centerY + i * tickY;
        ctx.moveTo(dx, centerY + 3);
        ctx.lineTo(dx, centerY - 3);
        ctx.moveTo(centerX + 3, dy);
        ctx.lineTo(centerX - 3, dy);
    }
    ctx.stroke();
    ctx.closePath();

}
