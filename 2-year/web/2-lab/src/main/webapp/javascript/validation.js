const submit_form = document.getElementById("submit-form");
submit_form.addEventListener("submit", function handleSubmit(event) {
    const input_y_field = document.getElementById("input-y");
    const input_r_field = document.getElementById("input-r");
    const message_field = document.getElementById("message");
    const radio_x = document.querySelectorAll("input[name='x']");
    message_field.innerText = "";

    function append_message(message) {
        message_field.innerText += message + '\n';
    }

    let y = input_y_field.value.replace(",", ".");
    let r = input_r_field.value.replace(",", ".");

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
    }
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

    if (y.length > 16) {
        input_y_field.value = "";
        append_message("[Warning] Y parameter too long (max 16 chars)");
        exit = 1;
    }

    if (r.length > 16) {
        input_r_field.value = "";
        append_message("[Warning] R parameter too long (max 16 chars)");
        exit = 1;
    }

    if (exit) {
        event.preventDefault();
        return;
    }

    x = parseFloat(x);
    y = parseFloat(y);
    r = parseFloat(r);

    if (r <= 2 || r >= 5) {
        append_message("[Warning] R parameter must be between 2 and 5 (exclusive)");
        exit = 1;
    }
    if (y <= -3 || y >= 3) {
        append_message("[Warning] Y parameter must be between -3 and 3 (exclusive)");
        exit = 1;
    }

    if (exit) {
        event.preventDefault();
        return;
    }

    document.getElementById("input_timezone_offset").value = new Date().getTimezoneOffset();

    // append_message("[Status] OK");
    // draw(r, x, y);

});

