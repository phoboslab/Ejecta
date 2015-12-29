"use strict";

//==================================================
// Init Extensions (In my fork version of Ejecta ).
//==================================================
var appUtils = new Ejecta.AppUtils();


//==================================================
// Download an image.
//==================================================
function downloadEjectaLogo() {
    var url = "http://impactjs.com/files/ejecta-logo.png";
    var destPath = "${Documents}/ejecta-logo.png";
    //The download function could download js file, then you could implement update-in-app.
    appUtils.download(url, destPath, function(err, filePath) {
        if (!err) {
            console.log(" >> Download: " + filePath);
            // Draw the image.
            drawImageFile(destPath);
        }
    });
}
downloadEjectaLogo();

function drawImageFile(imgPath) {
    var img = new Image();
    img.src = imgPath;
    img.onload = function() {
        var w = img.width;
        var h = img.height;
        // Draw it at center of canvas.
        if (typeof context != "undefined") {
            context.drawImage(img, width - w >> 1, height - h >> 1);
        }
    }
}
