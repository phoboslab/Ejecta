var width = window.innerWidth;
var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.width = width * window.devicePixelRatio;
canvas.height = height * window.devicePixelRatio;
canvas.style.width = width + "px";
canvas.style.height = height + "px";

//var context = canvas.getContext("2d");
//context.fillStyle = "#999999";
//context.fillRect(0, 0, canvas.width, canvas.height);
//
//context.fillStyle = "#fff9f0";
//context.font = "40px";
//context.textAlign = "right";
//context.fillText("Example", canvas.width - 20, 60);
//


//var canvas = document.createElement("canvas");
//canvas.width = 200;
//canvas.height = 100;
var gl = canvas.getContext("webgl");
gl.clearColor(0.2,0,0.8,1);
gl.clear(gl.COLOR_BUFFER_BIT);
//context.drawImage(canvas,10,20);

