
window.Config={
    useWebView : false ,
    width : window.innerWidth,
    height : window.innerHeight,
    lang : "_test"
}


// if (typeof exports == "undefined") {
    var exports = window;
// }
// if (typeof require == "undefined") {
    var require = function(url) {
        console.log("require : ", url);
        return exports;
    };
// }


(function() {



    window.WebView = App.WebView;
    var appUtils = new App.AppUtils();

    window.udid = appUtils.udid;
    window.uuid = appUtils.uuid;
    window.ver = appUtils.ver;
    console.log(window.ver, window.udid, window.uuid);

    // console.log([window.screen.availWidth, window.screen.availHeight]);
    // console.log([window.innerWidth, window.innerHeight]);
    // Config.width = window.screen.availWidth * window.devicePixelRatio;
    // Config.height = window.screen.availHeight * window.devicePixelRatio; 

    if (window.innerWidth < 960) {
        Config.width *= window.devicePixelRatio;
        Config.height *= window.devicePixelRatio;
    }

    if (Config.useWebView) {
        // //TODO
        // window.webView = new WebView();
        // webView.src = window.rootPath+"index-web.html";
    } else {
        var canvas = document.getElementById("canvas");
        canvas.retinaResolutionEnabled = true;//false;
        canvas.width = Config.width;
        canvas.height = Config.height;
        if (canvas.style){
            canvas.style.width = window.innerWidth+"px";
            canvas.style.height = window.innerHeight+"px";            
        }

        var context = canvas.getContext("2d");
        console.log(context.canvas == canvas);

        window.webView = new WebView();
        //TODO
        webView.src = window.rootPath+"local/"+Config.lang+"/index.html?app=1";
    }

}());




window.getUDID = function() {
    return window.udid;
}

window.getUUID = function() {
    return window.uuid;
}
window.getAppVer = function() {
    return window.ver;
}

window.loadJSFiles = function(files, cb) {
    files.forEach(function(item, idx) {
        if (item) {
            app.include(window.rootPath+item);
        }
    });
    cb();
}



