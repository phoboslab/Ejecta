
;(function(scope,undefined){
"use strict";

    var ns=scope.Toucher=scope.Toucher||{};
    var CONST=ns.CONST=ns.CONST||{};

    CONST.touches="touches";
    CONST.targetTouches="targetTouches";
    CONST.changedTouches="changedTouches";
    CONST.defaultTouchId=1;

    var Controller=ns.Controller = function(cfg){   

        for (var property in cfg ){
            this[property]=cfg[property];
        }

        this.wrapperClass=this.wrapperClass||ns.TouchWrapper;
    };

    Controller.prototype={
        constructor : ns.Controller ,

        wrapperClass : null,

        host : window ,
        dom : document,

        supportMultiTouch : false , 
        useMouse : false,
        useCapture : true ,
        preventDefault : false ,  // is preventDefault All

        preventDefaultStart : false ,
        preventDefaultMove : false ,
        preventDefaultEnd : false ,
        preventDefaultCancel : false ,

        offsetLeft : 0 ,
        offsetTop : 0 ,

        touchTimeLag : 30,
        maxTouch : 5,
        startTouches : null,
        moveTouches : null,
        endTouches : null,

        beforeInit : function(){},
        init : function(){

            this.listenerList=[];

            this.startTouches=[];
            this.moveTouches=[];
            this.endTouches=[];

            this.startTouches.lastTime
                =this.moveTouches.lastTime
                =this.endTouches.lastTime=0;

            this.touched={};
            this.touchedCount=0;

            this.beforeInit();

            var dom=this.dom;
            this.updateOffset(dom);

            this.supportMultiTouch="ontouchstart" in this.dom;
            if (!this.supportMultiTouch){
                this.useMouse=true;
            }

            if ( this.useMouse ){
                CONST.NOT_START=null;
                CONST.START="mousedown";
                CONST.MOVE="mousemove";
                CONST.END="mouseup";
            }else{
                CONST.NOT_START=null;
                CONST.START="touchstart";
                CONST.MOVE="touchmove";
                CONST.END="touchend";
            }

            var Me=this;
            dom.addEventListener(CONST.START, function(event){   
                if (Me.beforeStar!==null && Me.beforeStar(event)===false){
                    return;
                }
                Me.onStart(event);
                if (Me.preventDefaultStart || Me.preventDefault){
                    event.preventDefault();
                }
            }, this.useCapture );

            dom.addEventListener(CONST.MOVE, function(event){
                if (Me.beforeMove!==null && Me.beforeMove(event)===false){
                    return;
                }
                Me.onMove(event);   
                if (Me.preventDefaultMove|| Me.preventDefault){
                    event.preventDefault();
                }       
            }, this.useCapture );

            dom.addEventListener(CONST.END, function(event){
                if (Me.beforeEnd!==null && Me.beforeEnd(event)===false){
                    return;
                }
                Me.onEnd(event);
                if (Me.preventDefaultEnd|| Me.preventDefault){
                    event.preventDefault();
                }           
            }, this.useCapture );

            this.onInit();
        },
        onInit : function(){},

        updateOffset : function(dom){
            dom=dom||this.dom;

            if (dom.getBoundingClientRect!==undefined){
                var x=window.pageXOffset, y=0;
                if (x||x===0){
                    y=window.pageYOffset;
                }else{
                    x=document.body.scrollLeft;
                    y=document.body.scrollTop;
                }
                var rect=dom.getBoundingClientRect();
                this.offsetLeft=rect.left+x;
                this.offsetTop=rect.top+y;
                return;
            }
            var left = dom.offsetLeft, top = dom.offsetTop;
            while( (dom = dom.parentNode) 
                    && dom !== document.body && dom !== document ){
                left += dom.offsetLeft;
                top += dom.offsetTop;
            }
            this.offsetLeft=left;
            this.offsetTop=top;
        },

        beforeStar : null,
        onStart : function(event){
            var wrappers=this.getStartWrappers(event);
            this._emit("start",wrappers,event);
        },

        beforeMove : null,
        onMove : function(event){
            var wrappers=this.getMoveWrappers(event);
            this._emit("move",wrappers,event);
        },

        beforeEnd : null,
        onEnd : function(event){
            var wrappers=this.getEndWrappers(event);
            this._emit("end",wrappers,event);
        },

        addTouches : function(queue,item){
            if (queue.length>=this.maxTouch){
                queue.shift();
            }
            queue.push(item);
        },
        
        removeFromTouches : function(queue,item){
            if (queue.length>=this.maxTouch){
                queue.shift();
            }
            queue.push(item);
        },

        getStartWrappers : function(event){ 
            var _now=Date.now();
            var changedList=event[CONST.changedTouches]||[event];

            var startWrappers=[];
            for (var i=0,len=changedList.length;i<len;i++){
                var touch=changedList[i];
                var id=touch.identifier;
                var touchId=id||id===0?id:CONST.defaultTouchId;

                var touchWrapper=this.touched[touchId];

                touchWrapper=new this.wrapperClass(touchId);
                this.touched[ touchId ]=touchWrapper;
                this.touchedCount++;    
                touchWrapper.start(touch,event);            
                startWrappers.push(touchWrapper);

                var _touches=this.startTouches;
                if (_now-_touches.lastTime>this.touchTimeLag){
                    _touches.length=0;
                }
                _touches.lastTime=_now;
                _touches.push(touchWrapper);
            }           
            return startWrappers;
        },

        getMoveWrappers : function(event){  
            var _now=Date.now();
            var changedList=event[CONST.changedTouches]||[event];

            var moveWrappers=[];
            for (var i=0,len=changedList.length;i<len;i++){
                var touch=changedList[i];
                var id=touch.identifier;
                var touchId=id||id===0?id:CONST.defaultTouchId;

                var touchWrapper=this.touched[touchId];

                if ( touchWrapper ){

                    if (!touchWrapper.moveTime){
                        var _touches=this.moveTouches;
                        if (_now-_touches.lastTime>this.touchTimeLag){
                            _touches.length=0;
                        }
                        _touches.lastTime=_now;
                        _touches.push(touchWrapper);
                    }

                    touchWrapper.move(touch,event);
                    moveWrappers.push(touchWrapper);    
                    
                }
            }
            return moveWrappers;
        },

        getEndWrappers : function(event){   
            var _now=Date.now();
            var changedList=event[CONST.changedTouches]||[event];
        
            var _touched={};
            if (!this.useMouse){
                // TODO : CONST.touches or CONST.targetTouches , it's a question!
                var _touchedList=event[CONST.touches];
                for (var j=_touchedList.length-1;j>=0;j--){
                    var t=_touchedList[j];
                    _touched[t.identifier]=true;
                }
            }

            var endWrappers=[];
            for (var i=0,len=changedList.length;i<len;i++){
                var touch=changedList[i];
                var id=touch.identifier;
                var touchId=id||id===0?id:CONST.defaultTouchId;

                if ( !_touched[touchId]){
                    var touchWrapper=this.touched[touchId];
                    if ( touchWrapper ){
                        touchWrapper.end(touch);
                        
                        delete this.touched[touchId];
                        this.touchedCount--;
                        
                        endWrappers.push(touchWrapper);

                        var _touches=this.endTouches;
                        if (_now-_touches.lastTime>this.touchTimeLag){
                            _touches.length=0;
                        }
                        _touches.lastTime=_now;
                        _touches.push(touchWrapper);
                        this.removeWrapper(this.startTouches,touchId);
                        this.removeWrapper(this.moveTouches,touchId);
                    }
                }
            }

            return endWrappers;
        },

        removeWrapper : function(list,id){
            for (var i=list.length-1;i>=0;i--){
                if (list[i].identifier==id){
                    list.splice(i, 1);
                    return id;
                }
            }
            return false;
        },
        _emit : function(type,wrappers,event){

            for (var i=0,len=this.listenerList.length;i<len;i++){
                var listener=this.listenerList[i];
                if (listener[type]!=null){
                    var validWrappers=listener.filterWrappers(type,wrappers,event,this);
                    if (validWrappers===true){
                        validWrappers=wrappers;
                    }
                    if (validWrappers && validWrappers.length>0){
                        if (listener[type](validWrappers,event,this)===false){
                            break;
                        }
                    }
                }
            }
        },

        addListener : function(listener){
            listener.controller=this;
            listener.offsetLeft=this.offsetLeft;
            listener.offsetTop=this.offsetTop;
            listener.init();
            this.listenerList.push(listener);
            // TODO : order by listener.order
            listener.order=listener.order||0;
        },

        removeListener : function(listener){
            for (var i=this.listenerList.length-1;i>=0;i--){
                if (this.listenerList[i]==listener){
                    this.listenerList.splice(i, 1);
                    listener.controller=null;
                    return listener;
                }
            }
            return null;
        },

        removeAllListener : function(){
            for (var i=this.listenerList.length-1;i>=0;i--){
                listener.controller=null;
            }
            this.listenerList.length=0;
        }

    };


    
}(this));

