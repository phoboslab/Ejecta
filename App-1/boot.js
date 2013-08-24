
"use strict";

var Config = {
    FPS: 60,
    width: 1024,
    height: 768,
    scale: 1,
};



if (window.App) {

    Config.width = window.innerWidth;
    Config.height = window.innerHeight;
    if (window.innerWidth < 960) {
        Config.width *= window.devicePixelRatio;
        Config.height *= window.devicePixelRatio;
    }

        var canvas = document.getElementById("canvas");
        canvas.retinaResolutionEnabled = true;//false;
        canvas.width = Config.width;
        canvas.height = Config.height;
        if (canvas.style){
            canvas.style.width = window.innerWidth;
            canvas.style.height = window.innerHeight;            
        }

        var context = canvas.getContext("2d");
        console.log(context.canvas == canvas);
        
} else {
    window.Web = true;
    calcWindowSize();

    if (window.screen.width<1280){
        Config.width = window.innerWidth;
        Config.height = window.innerHeight;
        
    }
    // alert([Config.width,Config.height])
    if (window.innerWidth < 960) {
        Config.width *= window.devicePixelRatio;
        Config.height *= window.devicePixelRatio;
    }
}


if (typeof exports == "undefined") {
    var exports = window;
}

if (typeof require == "undefined") {
    var require = function(url) {
        console.log("require : ", url);
        return exports;
    };
}



function loadJSFiles(files,cb){
    if (window.App) {
        files.forEach(function(item, idx) {
            if (item) {
                AppCore.include(item);
            }
        });
        cb();
    } else {
        includeJSList(files, cb);
    }
}


;(function() {
    var App = !! window.App;
    var Web = !! window.Web;

    var baseScripts = [

    App ? "lib/Base.js" : null,
    App ? "lib/DomBase.js" : null,

        "lib/Event.js",
        "lib/Timer.js",
        "lib/ResourcePool.js",
        "lib/ProcessQ.js",
        "lib/Sound.js",
        "lib/CordovaUtils.js",
        "lib/Slider.js",
    App ? "lib/ViewBridge.js" : null,


        "res/res-list.js",
        
    //     "ui/ui-action.js",
    // Web ? "ui/ui-ctrl.js" : null,
    // App ? "ui/ui-ctrl-proxy.js" : null,


    ];

    loadJSFiles(baseScripts, function() {
        window.baseScriptsLoaded = true;
    });


}(this));




;(function() {

    window.onload = function() {
        window.pageLoaded = true;
    };

    var bootApp=function(){
        // if (window.pageLoaded && !UICtrl.preloadImages.called){
        //     UICtrl.preloadImages();
        //     UICtrl.preloadImages.called=true;
        // }
        if (window.App && !window.pageLoaded) {
            // if (webView.isLoaded()){
                // ViewBridge.initInNative(webView);
                window.pageLoaded=true;
            // }
        }
        window.uiLoaded=true;
        if (!window.baseScriptsLoaded || !window.pageLoaded || !window.uiLoaded) {
            setTimeout(bootApp, 10);
            return;
        }
        // UICtrl.init();
        // UICtrl.initContainer(Config.width,Config.height);
        // 
        // 
        // UICtrl.initAllUI();
        // UICtrl.initEvent();

        // UICtrl.showSplash();
        // UICtrl.showLoading();

        loadAllResources();

    };
    bootApp();



}());



function loadAllResources(){

    var interval=1;
    var delay=1;
    var paiallel= true;

    var loader=new ProcessQ({
        interval : interval,
        delay : delay ,
        paiallel : paiallel,
        onProgressing : function(timeStep, queue){
            var loaded=queue.finishedWeight,
                total=queue.totalWeight,
                results=queue.resultPool;
            return onLoading(loaded,total,results);
        },
        onFinish : function(queue){
            var loaded=queue.finishedWeight,
                total=queue.totalWeight,
                results=queue.resultPool;

            for (var id in results){
                if (id==="temp"){
                    delete results[id];
                }else{
                    ResourcePool.add(id, results[id]);
                }
            }
            console.log( "resource loaded : ", loaded, total );

            setTimeout(function() {
                onLoad( loaded, total, results );
            },delay);
        }
    });

    var onLoading = function(loadedCount, totalCount, res) {
            var v=Math.floor(loadedCount/totalCount*100);
            // UICtrl.updateLoading(v);
        };

    var onLoad = function(){
        bootGame();
    }

    loader.items=Config.resList;
    loader.init();
    loader.start();
    return loader;
}



function bootGame(){

    var App = !! window.App;
    var Web = !! window.Web;

    var gameScripts = [

        "lib/LinkedList.js",
        "lib/Animation.js",
        "lib/Game.js",
        "lib/Camera.js",
        "lib/EntityTemplate.js",

        "js/common.js",
        "js/Scene.js",
        "js/Background.js",
        // "js/Block.js",
        // "js/Player.js",
        // "js/Enemy.js",
        // "js/Item.js",


        "data/scene-0.js",
        
        "js/game.js",
 

    ];

    loadJSFiles(gameScripts, function() {
        window.gameScriptsLoaded=true;
        init();
    });

}

function init() {

    if (init.called) {
        return;
    }
    init.called = true;

    game.init();


    // UICtrl.hideLoading();
    // UICtrl.hideSplash();
    

    // UICtrl.showMainScreen();

    game.start();

}


