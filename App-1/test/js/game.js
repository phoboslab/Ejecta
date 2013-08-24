
"use strict";

var game=new Game({
    container : "container",
    
    FPS : Config.FPS,
    timeStep : Config.timeStep,

    width : Config.width,
    height : Config.height,

    resources : null,

    loader : false,

    baseTime : function(){
        return 0;
    },
    now : function(){
        return Date.now();
    },
    initEvent : function(){

        var Me=this;
        window.addEventListener("keydown", function(event) {
            KeyState[event.keyCode] = true;
        }, true);

        window.addEventListener("keyup", function(event) {
            KeyState[event.keyCode] = false;
        }, true);

        window.addEventListener("devicemotion", function(event){
          var ax = event.accelerationIncludingGravity.x;
          var f=1;
          if (ax<-f){
            KeyState[Key.A] = true;
            KeyState[Key.D] = false;
          }else if(ax>f){
            KeyState[Key.A] = false;
            KeyState[Key.D] = true;
          }else{
            KeyState[Key.A] = false;
            KeyState[Key.D] = false;
          }
        },true);

        var Me=this;
        window.addEventListener("touchmove", function(event) {
            event.preventDefault();
        }, true);

        window.addEventListener("mousedown", function(event) {
            event.preventDefault();
            Me.mouseDown=true;
        }, true);
        window.addEventListener("mouseup", function(event) {
            event.preventDefault();
            Me.mouseDown=false;
        }, true);
        window.addEventListener("mousemove", function(event) {
            if (Me.mouseDown && Me.currentScene){
                Me.currentScene.buildBladePath(event.pageX, event.pageY);
            };
            event.preventDefault();
        }, true);

        hideAddressBar();

    },
    
    initUI : function(){
        var Me=this;
    }, 
    onInit : function(){
        this.ready();
    },
    onReady : function(){
        var Me=this;

        console.log("game ready")
    },
    getSceneInstance : function(index){
        index=index||0;
        var scene=createScene(index);
        return scene;
    },
    afterLoop : function(timeStep,now){
        if (this.currentScene && this.currentScene.afterLoop ){
            this.currentScene.afterLoop(timeStep,now);
        }
    },
    exit : function(){
        window.location.reload();
    },

});

