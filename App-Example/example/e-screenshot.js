"use strict";

//==================================================
// Init Extensions (In my fork version of Ejecta ).
//==================================================
var appUtils = new Ejecta.AppUtils();


//==================================================
// Take a screenshot.
//==================================================
function takeScreenshot() {
    // You could use ".jpg" or ".png" as output file's ext-name.
    var destPath = "${Documents}/snapshot.png";
    // You could also use a offscreen canvas that you created via document.createElement().

    //    renderSomething(); // ensure that gl isn't be cleared

    appUtils.saveImage(canvas, destPath, function(filePath) {
        console.log(" >> Snapshot: " + filePath);
        // Share Screenshot Image.
    });
}

takeScreenshot();