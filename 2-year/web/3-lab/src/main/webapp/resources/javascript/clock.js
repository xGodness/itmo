function showTime(){
    let date = new Date();

    let day = date.getDate();
    let month = date.getMonth();
    let year = date.getFullYear();
    let hours = date.getHours();
    let minutes = date.getMinutes();
    let seconds = date.getSeconds();

    day = (day < 10) ? "0" + day : day;
    month = (month < 10) ? "0" + month : month;
    hours = (hours < 10) ? "0" + hours : hours;
    minutes = (minutes < 10) ? "0" + minutes : minutes;
    seconds = (seconds < 10) ? "0" + seconds : seconds;

    let dateTime = `${hours}:${minutes}:${seconds} ${day}.${month}.${year}`;
    let time = date.getDate() + "." + date.getMonth() + "." + date.getFullYear() + "\n" + hours + ":" + minutes + ":" + seconds;
    document.getElementById("clock-container").innerHTML = dateTime;
    // document.getElementById("clock-container").innerText = dateTime;
    // document.getElementById("clock-container").textContent = dateTime;

    setTimeout(showTime, 1000);

}

showTime();