
;(function(scope,undefined){
"use strict";

var Game=scope.Game=function(cfg){
    scope.merger(this,cfg);
}


Game.prototype={
    constructor : Game,

    FPS : 60 ,
    timer : null ,
    resources : null,

    width : 800,
    height : 480,
    viewWidth : null,
    viewHeight : null,

    container : null ,
    viewport : null ,
    canvas : "canvas",
    context : null,
    
    sceneIndex : 0 ,
    currentScene : null,
    
    uiManager : null ,
    
    loader : null ,
    state : null,

    gameTime : 0,
    mainLoop : null,

    init : function(){

        this.viewWidth=this.viewWidth||this.width;
        this.viewHeight=this.viewHeight||this.height;
    
        this.scenes=this.scenes||[];
        this.timeout=this.timeout||Math.floor(1000/this.FPS);
        this.timeStep=this.timeStep||this.timeout;
        this.maxTimeStep=this.maxTimeStep||Math.floor(this.timeStep*1.5)
        this.timer=new scope.Timer(this.timer);     

        this.initContainer();

        // this.uiManager=new DomUIManager(this.uiManager)
        if (this.uiManager){
            this.uiManager.init(this);
            
        }

        this.initLoader();

        var Me=this;
        this.callRun = function(){
            Me.run();
        }

        this.onInit();

    },
    onInit : scope.noop ,

    initContainer : function(){
        this.container=scope.$id(this.container)||this.container;
        if (typeof this.container=="string"){
            this._container=this.container;
            this.container=null;
        }
        // if (!this.container){
        //  this.container=document.createElement("div");
        //  document.body.appendChild(this.container);
        // }
        if (this.container){
            scope.merger(this.container.style,{
                visibility : "visible",
                position : "relative" ,
                overflow : "hidden" ,       
                padding : "0px" ,
                opacity : "1" ,
                width : this.width+"px" ,
                height : this.height+"px",
                marginLeft : "50%",
                left : -this.width/2+"px"
            });             
        }       

    },

    initLoader : function(){
        if (this.loader===false){
            return;
        }
        var Me=this;
        var loader=this.loader||{};
        var delay=loader.delay || 1;
        this.loader=new scope.ProcessQ({
            interval : loader.interval || 1,
            delay : delay ,
            paiallel : loader.paiallel||false,
            onNext : function(timeStep, queue){
                var loaded=queue.finishedWeight,
                    total=queue.totalWeight,
                    results=queue.resultPool;
                return Me.onLoading(loaded,total,results);
            },
            onFinish : function(queue){
                var loaded=queue.finishedWeight,
                    total=queue.totalWeight,
                    results=queue.resultPool;
                for (var id in results){
                    scope.ResourcePool.add(id, results[id]);
                }
                Me.onLoad=Me.onLoad||Me.ready;
                setTimeout(function() {
                    Me.onLoad(loaded,total,results);
                },delay);
            }
        });
    },

    beforeLoad : scope.noop ,   
    load : function(force){     
        if (this.beforeLoad(force)===false){
            return false;
        }
        var resources=this.resources?[].concat(this.resources):[];
        this.loader.items=resources;
        this.loader.init();
        this.loader.start();
    },
    onLoading : scope.noop,
    onLoad : null,


    initViewport : function(){
        if (this.container){
            this.viewport=document.createElement("div");
            this.container.appendChild(this.viewport);      
            var domStyle=this.viewport.style;
            scope.merger(domStyle,{
                position : "absolute" ,
                left : "0px",
                top : "0px",
                overflow : "hidden" ,   
                padding : "0px" ,
                width : this.viewWidth+"px" ,
                height : this.viewHeight+"px" ,
                className : "viewport",
                display : "block" ,   
                backgroundColor : "transparent"
            });         
        }   
    },

    initCanvas : function(){
        
        this.canvas=scope.$id(this.canvas)||this.canvas;

        // this.canvas=this.canvas||document.createElement("canvas");

        var domStyle=this.canvas.style;
        if (domStyle){
            scope.merger(domStyle,{
                position : "absolute" ,
                left : "0px",
                top : "0px",
                zIndex : 100
            });         
        }


        this.canvas.width=this.viewWidth;
        this.canvas.height=this.viewHeight;
        this.context=this.canvas.getContext('2d');

        if (this.viewport){
            this.viewport.appendChild(this.canvas);
        }

    },

    ready : function(){
        if (this.container){
            var rect=this.container.getBoundingClientRect();
            this.pos={
                left : rect.left+window.scrollX,
                top : rect.top+window.scrollY,
                right : rect.right+window.scrollX,
                bottom : rect.bottom+window.scrollY,
                width : rect.width,
                height : rect.height
            };
        }else{
            this.pos={
                left : 0,
                top : 0,
                right : this.viewWidth,
                bottom : this.viewHeight,
                width : this.viewWidth,
                height : this.viewHeight
            }
        }

        this.initViewport();
        this.initCanvas();
        this.initUI();
        this.initEvent();

        this.onReady();
    },
    initUI : scope.noop ,
    initEvent : scope.noop ,
    onReady : scope.noop,
 
    getSceneInstance : scope.noop , 
   
    loadScene : function(index){
        var scene=this.getSceneInstance(index);
        this.scenes[index]=scene||null;
        if (scene){
            scene.index=index;
        }
        return scene;
    },

    activeScene : function(index){
       var scene=this.scenes[index];
        this.currentScene=scene||null;
        if (scene){
            this.sceneIndex=scene.index;
            this.currentScene.init(this); 
            return true;           
        }else{
            return false;
        }
    }, 
    beforeStart : null,
    start : function(index){
        if (this.beforeStart){
            this.beforeStart(index);
        }
        this.cancelLoop();
        this.leaveScene();

        index=index||0;
        var scene=this.loadScene(index);
        if ( !this.activeScene(index) ){
            return false;
        }
        this.enterScene(this.currentScene);
        return true;
    },

    enterScene : function(scene){
        this.currentScene=scene;
        if (scene.beforeRun){
            scene.beforeRun(this);
        }   
        var Me=this;
        // setTimeout(function(){
            // Me.gameTime+=10;    
            Me.state=Game.PLAYING;  
            Me.timer.start();
            Me.gameTime=Date.now();
            Me.frameCount=0;
            Me.run();
        // },10)
    },
    leaveScene : function(){
        if (this.currentScene && this.currentScene.destructor){
            this.currentScene.destructor();
        }
    },
    restart : function(){   
        this.stop();
        this.start(this.sceneIndex);        
    },

    doLoop : function(fn){
        // this.mainLoop=requestAnimationFrame( this.callRun );
        this.mainLoop=setTimeout(this.callRun, this.timeout);
    },
    cancelLoop : function(fn){
        console.log("cancelLoop mainLoop : "+this.mainLoop);
        if (this.mainLoop!==null){
            // cancelAnimationFrame( this.mainLoop );
            clearTimeout(this.mainLoop);  
            this.mainLoop=null;          
        }
    },
    blank : 0,
    run : function(){

        var count=0;
        if (this.state==Game.PLAYING) {

            this.doLoop();
            var now=this.timer.tick();
            var timeStep=this.timer.timeStep;

                
            this.gameTime+=timeStep;

            this.frameCount++;
            timeStep=Math.min(timeStep,this.timeout<<1);

            this.handleInput(timeStep);
            
            // this.toRun=!this.toRun;
            // if (!this.toRun){
            //     return;
            // }

            if (this.paused){
                this.onPausing(timeStep,now);
            }else if ( timeStep>0 ){
                // timeStep=this.timeStep;
                this.beforeLoop(timeStep,now);
                this.timer.runTasks(timeStep,now);

                this.update(timeStep,now);
                
                // Plan A
                // var t=this.blank+timeStep;
                // do{
                    // this.update(this.timeStep);
                    // t-=this.timeStep;
                    // count++;
                // }while(t>=this.timeStep)
                // this.blank=t;
                
                // Plan B
                // this.update(this.timeStep);
                // var d=timeStep-this.timeStep;
                // if (this.blank>=this.timeStep){
                //     this.update(this.timeStep);
                //     count=this.blank;
                //     this.blank=0;
                // }else if(d>3){
                //     this.blank+=d;
                // }

                this.render(timeStep,now);
                this.afterLoop(timeStep,now);
            }

        }else if (this.state==Game.STOP) {
            this.stop();
        }else{
            this[this.state]&&this[this.state]();
        }
        if (count>1){
            console.log("count",count)
        }

    },
    onPausing : scope.noop,
    
    update : function(timeStep,now){
        var c=this.currentScene;
        if (c.handleInput){
            c.handleInput(timeStep);
        }
        c.update(timeStep,now);
    },
    render : function(timeStep){
        this.currentScene.render(this.context,timeStep);
    },
    handleInput :  scope.noop,
    beforeLoop : scope.noop,
    afterLoop : scope.noop,
    
    pause : function(){
        this.paused=1;
        this.onPause();
    },
    onPause : scope.noop,
    resume : function(){
        this.paused=0;
        this.onResume();
    },
    onResume : scope.noop,
    exit : scope.noop,

    stop : function(){
        this.state=Game.STOP;
        this.paused=0;
        this.cancelLoop();
        if (this.currentScene){
            if (this.currentScene.destructor){
                this.currentScene.destructor(this);
            }
            this.scenes[this.sceneIndex]=null;
            this.currentScene=null;
        }       
        this.onStop();
    },
    onStop : scope.noop ,

    //TODO
    geStatus : function(){},
    //TODO
    isPlaying : function(){},

    destructor : scope.noop
    
};

Game.PLAYING="playing";
Game.STOP="stop";


})(this);
