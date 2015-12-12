//==================================================
// Initialize the screen canvas.
//==================================================

//ejecta.include("example/e-init.js");
// ejecta.include("example/e-init-gl.js");
//ejecta.include("example/e-init-event.js");



//==================================================
// Examples
//==================================================

//ejecta.include("example/e-appUtils.js");

// ejecta.include("example/e-download-snapshot-share.js");

// ejecta.include("example/e-admob.js");

// ejecta.include("example/e-chartboost.js");

//ejecta.include("example/e-vungle.js");

// ejecta.include("example/e-encrypt.js");

// ejecta.include("example/e-alertView.js");

// ejecta.include("example/e-webView.js");

// ejecta.include("example/e-localNotification.js");

// ejecta.include("example/e-websocket.js");

// ejecta.include("example/e-gamepad.js");

// init default screen canvas & context
var width = window.innerWidth;
var height = window.innerHeight;

var canvas = document.getElementById('canvas');
canvas.width = width * window.devicePixelRatio;
canvas.height = height * window.devicePixelRatio;
canvas.style.width = width + "px";
canvas.style.height = height + "px";
var context = canvas.getContext("2d");


setTimeout(startTest, 100);

function startTest() {
    
    // resize screen canvas
    canvas.width = 960;
    canvas.height = 541;
    canvas.style.width = 568 + "px";
    canvas.style.height = 320 + "px";
    
    setInterval(function() {
                context.fillStyle = "rgba(220,220,220,1)";
                context.fillRect(0, 0, canvas.width, canvas.height);
                
                context.fillStyle = "black";
                context.fillText(Date.now() + "", 50, 100);
                
                context.strokeStyle = "rgba(0,0,0,0.5)";
                context.beginPath();
                context.arc(100, 100, 100, 0, Math.PI * 2);
                context.closePath();
                context.stroke();
                
                }, 33)
}
