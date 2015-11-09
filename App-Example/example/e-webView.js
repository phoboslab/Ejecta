"use strict";

var webview = new Ejecta.WebView();
webview.src = "./example/webview.html"; //  http/https url ,  html-file path
webview.backgroundColor = "rgba(222,111,220,1)"; // "transparent" === "rgba(0,0,0,0)"
webview.addEventListener("load", function() {
    webview.show();
    setTimeout(function() {
        webview.backgroundColor = "transparent";
    }, 1000);
});

function funcInNative() {
    var text = "This is a function defined in Native.";
    console.log(text);
    webview.eval("funcInWebview()");
}
