// The gamepad we draw below is about 1280px wide. We just
// scale the context so that it fills the actual screen width

if (canvas.width < canvas.height) {
    context.translate(0, canvas.height);
    context.rotate(-Math.PI / 2);
    width = canvas.height;
    height = canvas.width;
}

context.textAlign = 'left';
context.font = '32px Helvetica';
context.strokeStyle = '#222222';
context.lineWidth = 2;

console.log("canvas size : ", canvas.width, canvas.height)

// var scale = width / 1280;
// console.log(scale);
// context.scale(scale, scale);

var drawButton = function(button, x, y) {
    context.fillRect(x - 24, y + 24 - 48 * button.value, 48, 48 * button.value);

    context.strokeStyle = button.pressed ?'#a30' : '#222';
    context.strokeRect(x - 24, y - 24, 48, 48);
    context.strokeStyle = '#222';
};

var drawAnalogStick = function(axisX, axisY, x, y) {
    context.beginPath();
    context.arc(x, y, 64, 0, 2 * Math.PI);
    context.stroke();

    context.beginPath();
    context.arc(x + axisX * 48, y + axisY * 48, 16, 0, 2 * Math.PI);
    context.fill();
};

setInterval(function() {
    context.fillStyle = '#ffffff';
    context.fillRect(0, 0, width, height);

    context.fillStyle = '#222222';

    var tX = 32,
        tY = canvas.height - 240;
    if (TouchInfo.start) {
        var x = TouchInfo.start.x;
        var y = TouchInfo.start.y;
        context.fillText('Start: ' + x + " , " + y, tX, tY + 0);
    } else {
        context.fillText('Start: ', tX, tY + 0);
    }
    if (TouchInfo.move) {
        var x = TouchInfo.move.x;
        var y = TouchInfo.move.y;
        context.fillText('Move: ' + x + " , " + y, tX, tY + 50);
    } else {
        context.fillText('Move: ', tX, tY + 50);
    }
    if (TouchInfo.end) {
        var x = TouchInfo.end.x;
        var y = TouchInfo.end.y;
        context.fillText('End: ' + x + " , " + y, tX, tY + 50 * 2);
    } else {
        context.fillText('End: ', tX, tY + 50 * 2);
    }

    context.fillText('Motion AG : ' + JSON.stringify(AccelerationGravityInfo), tX, tY + 50 * 3 + 20);
    context.fillText('Motion A  : ' + JSON.stringify(AccelerationInfo), tX, tY + 50 * 4 + 20);
    // console.log(JSON.stringify(gamepad.motion));
    // console.log('Using Gamepad: #' + gamepad.index + ' (' + gamepad.id + ')');


    var gamepads = navigator.getGamepads();

    context.save();
    handleGamepad(gamepads[0], context, 30, 50);
    context.restore();
    context.save();
    handleGamepad(gamepads[1], context, canvas.width / 2 + 30, canvas.height * 1 / 3 + 50);
    context.restore();


}, 16);

function handleGamepad(gamepad, context, x, y) {
    context.translate(x, y);

    if (!gamepad) {
        context.fillText('No Gamepads connected', 32, 32);
        // console.log('No Gamepads connected');
        // context.translate(-x, -y);
        return;
    }

    gamepad.allowsRotation = true;
    gamepad.exitOnMenuPress = false;
    context.fillText('Using Gamepad: #' + gamepad.index + ' (' + gamepad.id + ')', 32, 32);


    // Button Mappings according to http://www.w3.org/TR/gamepad/#remapping

    drawButton(gamepad.buttons[0], 728, 354); // A
    drawButton(gamepad.buttons[1], 794, 288); // B
    drawButton(gamepad.buttons[2], 662, 288); // X
    drawButton(gamepad.buttons[3], 728, 224); // Y

    drawButton(gamepad.buttons[4], 212, 96); // L1
    drawButton(gamepad.buttons[5], 668, 96); // R1
    drawButton(gamepad.buttons[6], 88, 96); // L2
    drawButton(gamepad.buttons[7], 794, 96); // R2

    drawButton(gamepad.buttons[12], 152, 224); // Up
    drawButton(gamepad.buttons[13], 152, 354); // Down
    drawButton(gamepad.buttons[14], 88, 288); // Left
    drawButton(gamepad.buttons[15], 216, 288); // Right

    drawButton(gamepad.buttons[16], 440, 196); // Menu

    drawAnalogStick(gamepad.axes[0], gamepad.axes[1], 340, 416); // left stick
    drawAnalogStick(gamepad.axes[2], gamepad.axes[3], 536, 416); // right stick

    // context.translate(-x, -y);
}
