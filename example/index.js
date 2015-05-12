var width = window.innerWidth;
var height = window.innerHeight;

var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;
var context = canvas.getContext('2d');
context.font = "16px Arial";
context.fillStyle = "#ffffff";
context.strokeStyle = "blue";
context.beginPath();
context.arc(100, 100, 100, 0, Math.PI * 2, false);
context.stroke()
context.closePath();


if (Ejecta.AppUtils) {

    window.appUtils = new Ejecta.AppUtils();

    window.systemLocal = appUtils.systemLocal;

    console.log("ver", appUtils.ver);
    console.log("udid", appUtils.udid);
    console.log("uuid", appUtils.uuid);
    console.log("systemLocal", appUtils.systemLocal);

}

if (Ejecta.WebView) {

    window.webview = new Ejecta.WebView();
    webview.hide();
    webview.src = "webview.html";

    webview.addEventListener("load", function() {

        ejecta.include("lib/WebviewBridge.js");
        if (typeof WebviewBridge != "undefined") {
            WebviewBridge.initInNative(webview);
        }
        webview.show();

    });

}

function funcInNative() {
    var text = "This is a function defined in native.";
    console.log(text);
    context.fillText(text, 10, 200);

    setTimeout(function() {
        WebviewBridge.evalRemote("funcInWebview()");
    }, 500);
}
