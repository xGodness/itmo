let context, analyser, src, arr;

const bars = Array.from(document.getElementsByClassName("bar"))

let audio = document.getElementById("audio");
audio.crossOrigin = "anonymous";

let progress = document.getElementById("progress");
let progress_filled = document.getElementById("progress-filled");
let img = document.getElementById("image");
let caption = document.getElementById("caption");

const track_list = [
    {"src": "audio/VSN7_▽_Outcast.mp3", "img": "img/outcast.png", "name": "VSN7, ▽ – Outcast (Farewell Edit)"},
    {"src": "audio/Jinjer_Beggars_Dance.mp3", "img": "img/beggars_dance.png", "name": "Jinjer - Beggars Dance"},
    {"src": "audio/RADWIMPS_hyperventilation.mp3", "img": "img/hyperventilation.png", "name": "JRADWIMPS - Hyperventilation"}
]

let track_id = 0;

let play_button = document.getElementById("play-button");
let prev_button = document.getElementById("prev-button");
let next_button = document.getElementById("next-button");

window.onload = function () {
    set_track(0);
    // fetch('https://crossorigin.me/https://google.com')
    //     .then(response => response.json())
    //     .then(data => console.log(data))
    //     .catch(error => console.error(error));
}

function set_track(id) {
    let is_paused = audio.paused;
    let track = track_list[id];
    img.src = track["img"];
    img.alt = track["name"];
    caption.innerText = track["name"];
    audio.src = track["src"];

    progress_filled.style.flexBasis = "0%";
    audio.currentTime = 0;
    if (!is_paused) audio.play();
}

play_button.onclick = function () {
    if (!context) init();
    if (audio.paused) {
        play_button.innerText = "||";
        audio.play();
    } else {
        play_button.innerText = "▶";
        audio.pause();
    }
}

prev_button.onclick = function () {
    track_id = (track_id - 1 + track_list.length) % track_list.length;
    set_track(track_id);
}

next_button.onclick = function () {
    track_id = (track_id + 1) % track_list.length;
    set_track(track_id);
}

function init() {
    context = new AudioContext();
    analyser = context.createAnalyser();
    src = context.createMediaElementSource(audio);
    src.connect(analyser);
    analyser.connect(context.destination)
    loop();
}

function loop() {
    window.requestAnimationFrame(loop);
    arr = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(arr);

    let step = Math.floor(255 / bars.length)
    let cur_diff = 0

    bars.forEach(bar => {
        bar.style.height = (1.5 * arr[cur_diff]) + "px";
        cur_diff += step;
    })
}

audio.addEventListener("timeupdate", () => {
    progressUpdate();
});

function progressUpdate() {
    const percent = (audio.currentTime / audio.duration) * 100;
    progress_filled.style.flexBasis = `${percent}%`;
}

let mousedown = false;

function scrub(event) {
    audio.currentTime = (event.offsetX / progress.offsetWidth) * audio.duration;
}

audio.addEventListener("ended", () => {
    track_id = (track_id + 1) % track_list.length;
    set_track(track_id);
    audio.play();
});

progress.addEventListener("click", scrub);
progress.addEventListener("mousemove", (e) => mousedown && scrub(e));
progress.addEventListener("mousedown", () => (mousedown = true));
progress.addEventListener("mouseup", () => (mousedown = false));

