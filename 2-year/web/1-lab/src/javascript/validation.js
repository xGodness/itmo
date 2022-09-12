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
    if (r <= 2 || r >= 5) {
        append_message("[Warning] R parameter must be between 2 and 5 (not inclusive)");
        exit = 1;
    }
    if (y <= -3 || y >= 3) {
        append_message("[Warning] Y parameter must be between -3 and 3 (not inclusive)");
        exit = 1;
    }
    if (exit) {
        return;
    }

    append_message("[Status] OK");
    draw(r, x, y);
    
    let xhr = new XMLHttpRequest();
    let url = "http://localhost:8888";
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            let data = JSON.stringify({"x": x, "y": y, "r": r});
            xhr.send(data);
        }
    };
    xhr.onload = function (e) {
        console.log("AAAAAAAAAAAAA");
        let response_json = xhr.response;
        console.log(JSON.parse(response_json));
        //
        // const results_table = document.getElementById("results-table");
        // let row = results_table.insertRow();
        // let data_map = new Map(Object.entries(JSON.parse(response_json)));
        // console.log(data_map);
        // for (let i = 0; i < data_map.keys.length; i++) {
        //     let cell = row.insertCell();
        //     cell.innerText = data_map.keys()[i];
        // }
    };



});


