"use strict";

var width = window.innerWidth * window.devicePixelRatio;
var height = window.innerHeight * window.devicePixelRatio;
var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;
canvas.style.width = window.innerWidth + "px";
canvas.style.height = window.innerHeight + "px";

var context = canvas.getContext("2d");

console.log("window.orientation = ",window.orientation);

function renderSomething() {
    context.fillStyle = "#999999";
    context.fillRect(0, 0, width, height);

    context.fillStyle = "#ff3300";
    context.fillRect(0, height >> 1, width, 10);
    context.fillRect(width >> 1, 0, 10, height);

    context.fillStyle = "#fff9f0";
    context.font = "40px";
    context.textAlign = "right";
    context.fillText("Example", width - 20, 60);
}

renderSomething();
