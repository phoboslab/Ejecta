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


var TouchInfo = {
    start: null
};

window.addEventListener("touchstart", function(event) {
    var touches = event.changedTouches;
    var firstFinger = touches[0];
    if (firstFinger) {
        TouchInfo.start = {
            x: firstFinger.pageX * window.devicePixelRatio,
            y: firstFinger.pageY * window.devicePixelRatio,
            id: firstFinger.identifier
        };
        console.log(JSON.stringify(TouchInfo));
    }
});

window.addEventListener("touchend", function(event) {
    if (TouchInfo.start) {
        var touches = event.changedTouches;
        for (var i = 0; i < touches.length; i++) {
            var finger = touches[i];
            if (finger.identifier === TouchInfo.start.id) {
                TouchInfo.start = null;
                break;
            }
        }
    }
});
