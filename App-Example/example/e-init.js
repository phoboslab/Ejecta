var width = window.innerWidth;
var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.width = width * window.devicePixelRatio;
canvas.height = height * window.devicePixelRatio;
canvas.style.width = width + "px";
canvas.style.height = height + "px";

var context = canvas.getContext("2d");
context.fillStyle = "#000000";
context.fillRect(0, 0, canvas.width, canvas.height);

context.fillStyle = "#fff9f0";
context.font = "40px Arial";
context.textAlign = "right";
context.fillText("Example", canvas.width - 20, 60);
