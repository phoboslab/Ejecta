var width = window.innerWidth;
var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.retinaResolutionEnabled = true;
canvas.width = width * window.devicePixelRatio;
canvas.height = height * window.devicePixelRatio;
canvas.style.width = width + "px";
canvas.style.height = height + "px";

var context = canvas.getContext("2d");


function renderSomething() {
    context.fillStyle = "#999999";
    context.fillRect(0, 0, canvas.width, canvas.height);

    context.fillStyle = "#ff3300";
    context.fillRect(0, canvas.height >> 1, canvas.width, 10);
    context.fillRect(canvas.width >> 1, 0, 10, canvas.height);

    context.fillStyle = "#fff9f0";
    context.font = "40px";
    context.textAlign = "right";
    context.fillText("Example", canvas.width - 20, 60);
}

renderSomething();
