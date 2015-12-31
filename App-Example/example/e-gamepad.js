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
context.fillStyle = '#fff';
context.strokeStyle = '#fff';
context.lineWidth = 2;

console.log("canvas size : ", canvas.width, canvas.height)

// var scale = width / 1280;
// console.log(scale);
// context.scale(scale, scale);

var drawButton = function(button, x, y) {
    context.fillRect(x - 24, y + 24 - 48 * button.value, 48, 48 * button.value);

    context.strokeStyle = button.pressed ? '#0f0' : '#ccc';
    context.strokeRect(x - 24, y - 24, 48, 48);
    context.strokeStyle = '#fff';
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
    // context.clearRect(0, 0, width / scale + 2, height / scale + 2);
    context.clearRect(0, 0, width, height);

    // Always use 2nd gamepad for this visualization if it's present. On an
    // Apple TV when the TV Remote and a Game Controller is connected, the Remote
    // will be the first entry in the gamepads array; we want a dedicated
    // Game Controller if there is one.

    var gamepads = navigator.getGamepads();
    var gamepad = gamepads[1] || gamepads[0];

    if (!gamepad) {
        context.fillText('No Gamepads connected', 32, 32);
        // console.log('No Gamepads connected');
        return;
    }

    gamepad.allowsRotation = true;

    context.fillText('Using Gamepad: #' + gamepad.index + ' (' + gamepad.id + ')', 32, 32);

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

    context.translate(210, 210);

    // Button Mappings according to http://www.w3.org/TR/gamepad/#remapping

    drawButton(gamepad.buttons[0], 928, 354); // A
    drawButton(gamepad.buttons[1], 994, 288); // B
    drawButton(gamepad.buttons[2], 862, 288); // X
    drawButton(gamepad.buttons[3], 928, 224); // Y

    drawButton(gamepad.buttons[4], 412, 96); // L1
    drawButton(gamepad.buttons[5], 868, 96); // R1
    drawButton(gamepad.buttons[6], 288, 96); // L2
    drawButton(gamepad.buttons[7], 994, 96); // R2

    drawButton(gamepad.buttons[12], 352, 224); // Up
    drawButton(gamepad.buttons[13], 352, 354); // Down
    drawButton(gamepad.buttons[14], 288, 288); // Left
    drawButton(gamepad.buttons[15], 416, 288); // Right

    drawButton(gamepad.buttons[16], 640, 196); // Menu

    drawAnalogStick(gamepad.axes[0], gamepad.axes[1], 540, 416); // left stick
    drawAnalogStick(gamepad.axes[2], gamepad.axes[3], 736, 416); // right stick

    context.translate(-210, -210);


    // You can control whether the MENU button exits your game. Apple will reject your
    // App if it does not. For Gamepads, the B button can also act as a MENU button.
    // However, MENU should only exit the App the in certain cases.

    // The expected behavior is this:
    // > Pauses/resumes gameplay. Returns to previous screen, exits to main game menu,
    // > and/or exits to Apple TV Home screen.
    // ~ https://developer.apple.com/tvos/human-interface-guidelines/remote-and-interaction/

    // In any case, judging from other games, you're probably safe to set 'exitOnMenuPress'
    // to false during gameplay and only set it to true when you're on the Title Screen of
    // your game.

    gamepad.exitOnMenuPress = !true;

}, 16);
