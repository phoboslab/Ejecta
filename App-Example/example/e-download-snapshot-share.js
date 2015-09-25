//==================================================
// Draw something on screen canvas.
//==================================================
context.fillStyle = "#ff3300";
context.fillRect(0, canvas.height >> 1, canvas.width, 12);
context.fillRect(canvas.width >> 1, 0, 12, canvas.height);



//==================================================
// Init Extensions (In my fork version of Ejecta ).
//==================================================
var appUtils = new Ejecta.AppUtils();
var social = new Ejecta.Social();


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
        context.drawImage(img, canvas.width - w >> 1, canvas.height - h >> 1);
        // Take Screenshot.
        takeScreenshot();
    }
}

//==================================================
// Take a screenshot.
//==================================================
function takeScreenshot() {
    // You could use ".jpg" or ".png" as output file's ext-name.
    var destPath = "${Documents}/snapshot.png";
    // You could also use a offscreen canvas that you created via document.createElement().
    appUtils.saveImage(canvas, destPath, function(filePath) {
        console.log(" >> Snapshot: " + filePath);
        // Share Screenshot Image.
        shareImage(destPath);
    });
}


//==================================================
// Share the screenshot that you took.
//==================================================
function shareImage(imgPath) {
    // You can't open social dialog as soon as app starts.
    // You must wait a moment for initialization of SocialSDK.
    var snsName = "twitter"; // twitter , facebook , sinaweibo (Chinese twitter)
    var message = "test message";
    var shareUrl = "http://impactjs.com";

    // // Test openShare()
    // social.openShare(message, imgPath);
    // return;

    // Test showPostDialog()
    social.showPostDialog(snsName, message, imgPath, shareUrl,
        function(statusCode) {
            console.log(" >> Share: " + statusCode + ", " + imgPath);
        }
    );

}
