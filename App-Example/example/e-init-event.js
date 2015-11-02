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
