"use strict";

var TouchInfo = {
    start: null,
    move: null,
    end: null,
};

window.addEventListener("touchstart", function(event) {
    var touches = event.changedTouches;
    var firstFinger = touches[0];
    if (firstFinger) {
        TouchInfo.end = null;
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
                // console.log("touchmove", TouchInfo.move.x, TouchInfo.move.y);
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
                TouchInfo.end = {
                    x: finger.pageX * window.devicePixelRatio,
                    y: finger.pageY * window.devicePixelRatio,
                    id: finger.identifier
                };
                console.log("touchend", TouchInfo.end.x, TouchInfo.end.y);
                break;
            }
        }
    }
});

var AccelerationGravityInfo = {
    x: 0,
    y: 0,
    z: 0,
};
var AccelerationInfo = {
    x: 0,
    y: 0,
    z: 0,
};

window.addEventListener("devicemotion", function(event) {
    AccelerationGravityInfo.x = event.accelerationIncludingGravity.x.toFixed(3);
    AccelerationGravityInfo.y = event.accelerationIncludingGravity.y.toFixed(3);
    AccelerationGravityInfo.z = event.accelerationIncludingGravity.z.toFixed(3);

    AccelerationInfo.x = event.acceleration.x.toFixed(3);
    AccelerationInfo.y = event.acceleration.y.toFixed(3);
    AccelerationInfo.z = event.acceleration.z.toFixed(3);
    //    console.log("accelerationIncludingGravity", x, y, z);
});
