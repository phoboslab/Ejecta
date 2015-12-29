"use strict";

//==================================================
// Init Extensions (In my fork version of Ejecta ).
//==================================================
var appUtils = new Ejecta.AppUtils();
var social = new Ejecta.Social();


//==================================================
// Take a screenshot.
//==================================================
function takeScreenshot() {
    // You could use ".jpg" or ".png" as output file's ext-name.
    var destPath = "${Documents}/snapshot.png";
    // You could also use a offscreen canvas that you created via document.createElement().

    // renderSomething(); // ensure that gl isn't be cleared

    appUtils.saveImage(canvas, destPath, function(filePath) {
        console.log(" >> Snapshot: " + filePath);
        // Share Screenshot Image.
        shareImage(destPath);
    });
}

setTimeout(function() {
    takeScreenshot();
}, 500);


//==================================================
// Share the screenshot that you took.
//==================================================
function shareImage(imgPath) {
    // You can't open social dialog as soon as app starts.
    // You must wait a moment for initialization of SocialSDK.
    var snsName = "facebook"; // twitter , facebook , sinaweibo (Chinese twitter)
    var message = "test message";
    var shareUrl = "http://impactjs.com";

    // Test openShare()
    social.openShare(message, imgPath);
    return;

    // Test showPostDialog()
    social.showPostDialog(snsName, message, imgPath, shareUrl,
        function(statusCode) {
            console.log(" >> Share: " + statusCode + ", " + imgPath);
        }
    );

}
