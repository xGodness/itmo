// window.onload = function () {
    // if (localStorage.length !== 0) {
        // loadTable();
    // }
// }

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
        input_y_field.value = "";
        append_message("[Warning] R parameter too long (max 16 chars)");
        exit = 1;
    }

    if (exit) {
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
        return;
    }

    append_message("[Status] OK");
    draw(r, x, y);

    let xhr = new XMLHttpRequest();
    let url = "/2-lab/main";
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            // let response_string = xhr.response;
            // addFromDomString(response_string);
            // localStorage.setItem(localStorage.length, response_string);
        }
    };

    let timezone_offset_minutes = new Date().getTimezoneOffset();
    timezone_offset_minutes = timezone_offset_minutes === 0 ? 0 : -timezone_offset_minutes;
    let data = JSON.stringify({"x": x, "y": y, "r": r, "timezone_offset_minutes": timezone_offset_minutes});
    xhr.send(data);

});

// function handleClear() {
//     let rows = document.getElementsByClassName("results-row");
//     for (let i = rows.length - 1; i >= 0; i--) {
//         rows.item(i).remove();
//     }
//     // localStorage.clear();
// }

// function loadTable() {
//     for (let i = 0; i < localStorage.length; i++) {
//         let domString = localStorage.getItem(i);
//         addFromDomString(domString);
//     }
// }

function addFromDomString(domString) {
    let dom = (new DOMParser()).parseFromString(domString, "application/xml");
    let response_cells = dom.getElementsByTagName("td");
    let results_table = document.getElementById("results-table");
    let new_row = results_table.insertRow(1);
    new_row.className = "results-row";
    for (let i = 0; i < response_cells.length; i++) {
        let cell = new_row.insertCell();
        cell.className = "results-cell";
        let p = document.createElement("p");
        p.innerText = response_cells[i].getElementsByTagName("p")[0].textContent;
        cell.appendChild(p);
    }
}

