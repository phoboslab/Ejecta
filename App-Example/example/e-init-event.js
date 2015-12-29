"use strict";

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
        console.log("touchstart", TouchInfo.start.x, TouchInfo.start.y);
    }
});

window.addEventListener("touchmove", function(event) {
    if (TouchInfo.start) {
        var touches = event.changedTouches;
        for (var i = 0; i < touches.length; i++) {
            var finger = touches[i];
            if (finger.identifier === TouchInfo.start.id) {
                TouchInfo.move = {
                    x: finger.pageX * window.devicePixelRatio,
                    y: finger.pageY * window.devicePixelRatio,
                    id: finger.identifier
                };
//                console.log("touchmove", TouchInfo.move.x, TouchInfo.move.y);
                break;
            }
        }
    }
});

window.addEventListener("touchend", function(event) {
    if (TouchInfo.start) {
        var touches = event.changedTouches;
        for (var i = 0; i < touches.length; i++) {
            var finger = touches[i];
            if (finger.identifier === TouchInfo.start.id) {
                TouchInfo.start = null;
                TouchInfo.move = null;
                var end = {
                    x: finger.pageX * window.devicePixelRatio,
                    y: finger.pageY * window.devicePixelRatio,
                    id: finger.identifier
                };
                console.log("touchend", end.x, end.y);
                break;
            }
        }
    }
});

window.addEventListener("devicemotion", function(event) {
    var x = event.accelerationIncludingGravity.x;
    var y = event.accelerationIncludingGravity.y;
    var z = event.accelerationIncludingGravity.z;
//    console.log("accelerationIncludingGravity", x, y, z);
});

