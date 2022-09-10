const submit_button = document.getElementById("submit");
submit_button.addEventListener("click", function handleClick(event) {
    const input_y_field = document.getElementById("input-y");
    const input_r_field = document.getElementById("input-r");
    const message_field = document.getElementById("message");
    const radio_x = document.querySelectorAll("input[name='input-x-radio']");
    message_field.innerText = "";

    function append_message(message) {
        message_field.innerText += message + '\n';
    }

    let y = input_y_field.value;
    let r = input_r_field.value;

    let exit = 0;
    let x = null;
    for (let i = 0; i < radio_x.length; i++) {
        if (radio_x[i].checked) {
            x = radio_x[i].value;
            break;
        }
    }
    if (x == null) {
        append_message("[Warning] X parameter is not specified");
        exit = 1;
    };
    if (y === "" || isNaN(y)) {
        input_y_field.value = "";
        append_message("[Warning] Y parameter must be valid number");
        exit = 1;
    }
    if (r === "" || isNaN(r)) {
        input_r_field.value = "";
        append_message("[Warning] R parameter must be valid number");
        exit = 1;
    }
    x = parseFloat(x);
    y = parseFloat(y);
    r = parseFloat(r);
    if (r <= 0 || r > 6) {
        append_message("[Warning] R parameter must be positive and not greater than 6");
        return;
    }
    if (exit) {
        return;
    }

    append_message("[Status] OK");
    draw(r, x, y);

    try {
        const response = fetch("php/main.php", {
            method: "post",
            body: {
                "x": x,
                "y": y,
                "r": r
            }
        });
        append_message(response);
    } catch (err) {
        append_message(err);
    }

});


