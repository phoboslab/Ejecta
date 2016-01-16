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
var GravityInfo = {
    x: 0,
    y: 0,
    z: 0,
};

window.addEventListener("devicemotion", function(event) {
    AccelerationGravityInfo.x = event.accelerationIncludingGravity.x;
    AccelerationGravityInfo.y = event.accelerationIncludingGravity.y;
    AccelerationGravityInfo.z = event.accelerationIncludingGravity.z;

    if (event.acceleration) {
        AccelerationInfo.x = event.acceleration.x;
        AccelerationInfo.y = event.acceleration.y;
        AccelerationInfo.z = event.acceleration.z;

        GravityInfo.x = AccelerationGravityInfo.x - AccelerationInfo.x;
        GravityInfo.y = AccelerationGravityInfo.y - AccelerationInfo.y;
        GravityInfo.z = AccelerationGravityInfo.z - AccelerationInfo.z;
    }

    if (AccelerationGravityInfo.x) {
        AccelerationGravityInfo.x = AccelerationGravityInfo.x.toFixed(3);
        AccelerationGravityInfo.y = AccelerationGravityInfo.y.toFixed(3);
        AccelerationGravityInfo.z = AccelerationGravityInfo.z.toFixed(3);
    }
    if (AccelerationInfo.x) {
        AccelerationInfo.x = AccelerationInfo.x.toFixed(3);
        AccelerationInfo.y = AccelerationInfo.y.toFixed(3);
        AccelerationInfo.z = AccelerationInfo.z.toFixed(3);
    }
    if (GravityInfo.x) {
        GravityInfo.x = GravityInfo.x.toFixed(3);
        GravityInfo.y = GravityInfo.y.toFixed(3);
        GravityInfo.z = GravityInfo.z.toFixed(3);
    }
});
