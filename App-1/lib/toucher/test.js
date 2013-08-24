
"use strict";


function setDomPos(dom,x,y){
    dom.style.left= x+"px";
    dom.style.top= y+"px";
}

function setDomTranslate(dom,x,y){
    dom.style.webkitTransform="translate3d("+ x+"px,"+y+"px,0px)";
}
function $id(id){
    return document.getElementById(id);
}


var controller;
function initTouchController(){
	controller=new Toucher.Controller({
		beforeInit : function(){
			this.dom=window;
		},
		preventDefaultMove :true
	});
	controller.init();
}


function isTouchingView(element){

	var parent=element.parentNode;

	var rs=element.id=="canvas" || element.getAttribute("not-ui")!==null;
	return rs;
}


var slotRadius=60;
var stickRadius=40;
var slot1,stick1;
var buttonA,buttonB;
function initJoystick(){

	slot1=$id("slot1");
	stick1=$id("stick1");
	buttonA=$id("buttonA");
	buttonB=$id("buttonB");

	var style=slot1.style;
	var cfg={
		zIndex : 101,
		position : "absolute",
		left : 100+"px",
		bottom : 200+"px",
		width : slotRadius*2+"px",
		height : slotRadius*2+"px",
		borderRadius : slotRadius+"px"
	}
	for (var p in cfg){
		style[p]=cfg[p];
	}

	var style=stick1.style;
	var cfg={
		zIndex : 102,
		position : "absolute",
		left : slotRadius-stickRadius+"px",
		top : slotRadius-stickRadius+"px",
		width : stickRadius*2+"px",
		height : stickRadius*2+"px",
		borderRadius : stickRadius+"px"
	}
	for (var p in cfg){
		style[p]=cfg[p];
	}

}


function initTouchListener(){

	var any=new Toucher.Any({

		start : function(wrappers, event, controller){
			for (var i=0;i<wrappers.length;i++){

				var x=wrappers[i].pageX;
				var y=wrappers[i].pageY;
				var id=wrappers[i].id;
				var p=Points[id];
				if (!p){
					p=Points[id]=[];
				}
				p[0]=x;
				p[1]=y;
				addLog("start : ",x,y);
			}
		},

		move : function(wrappers,event,controller){
			for (var i=0;i<wrappers.length;i++){

				var x=wrappers[i].pageX;
				var y=wrappers[i].pageY;
				var id=wrappers[i].id;
				var p=Points[id];
				if (!p){
					p=Points[id]=[];
				}
				p[0]=x;
				p[1]=y;
			}
		},

		end : function(wrappers,event,controller){
			for (var i=0;i<wrappers.length;i++){
				var id=wrappers[i].id;

				delete Points[id];
			}

		},

		cancel : function(wrappers,event,controller){
			Points={};
			testTouch.reset();
			addLog("cancel : ",wrappers,event);
		}
	});

	var tap=new Toucher.Tap({	
			maxTimeLag : 1200 ,
			maxDistance : 15,
			touchStartTime : 0,
			start : function(wrappers, event, controller){
				this.enabled=true;
				this.touchStartTime=wrappers[0].startTime;
			},

			trigger : function(x, y, wrappers,event, controller){
				var element=event.target;

				var x=wrappers[0].pageX;
				var y=wrappers[0].pageY;

				addLog("tap : ",x,y);

				if (isTouchingView(element)){

				}else{

				}
			},

			onTouchEnd : function(x,y, wrappers,event, controller){
				var element=event.target;
				this.touchStartTime=0;
			}
		}
	);

	var pan=new Toucher.Pan({
			trigger : function(dx,dy,sx,sy,x,y,wrappers,event,controller){
				var element=event.target;

				// addLog("pan : ",dx,dy);

				if (isTouchingView(element)){

				}else{

				}
			}
		}
	);

    var swipe=new Toucher.Swipe({
        minDistance : 50,
        maxTime : 2000,

		trigger : function(disX,disY,time,wrappers,event,controller){
            var vx=disX/time, vy=disY/time;

            var element=event.target;

            vx=Math.round(vx*50)/50;
            vy=Math.round(vy*50)/50;
            addLog("swipe : ", vx, vy );
           
        }
    })

	var scale=new Toucher.Scale({
			start : function(wrappers, event, controller){

			},

			trigger : function(scale,cx,cy,wrappers,event,controller){
				scale=Math.round(scale*50)/50;
	            addLog("scale : ", scale,cx,cy );

				var element=event.target;
				if (isTouchingView(element)){

				}else{

				}
			}
		}
	);




var testTouch=new Toucher.Joystick({

	maxRadius : slotRadius-10 ,

	displayed : false,
	touchId : null,
    filterWrapper : function(type,wrapper,event,controller){
    	if (wrapper.startTarget.classList.contains("padButton")){
	    	return false;
    	}
    	return true;
		// return wrapper.startTarget.id=="slot1"
		// 		|| wrapper.startTarget.id=="stick1";
	},

	onStart : function(touchWrapper,event,controller){
		if (this.displayed){
			return;
		}
		this.touchId=touchWrapper.id;

		var x=touchWrapper.pageX;
		var y=touchWrapper.pageY;

		setDomPos(slot1 , x-slotRadius , y-slotRadius);
		this.displayed=true;
		slot1.style.display="block";
	},

	onMove : function(touchWrapper,event,controller){
		if (this.touchId!=touchWrapper.id){
			return;
		}
		var x=this.moveX.toFixed(2), 
			y=this.moveY.toFixed(2);
		var distance=this.moveDistance.toFixed(2),
			rotation=this.rotation.toFixed(2)

		setDomTranslate(stick1 , x , y);
		// info.innerHTML=" ["+x+","+y+"],"+distance+","+rotation;
	},
	onEnd : function(touchWrapper,event,controller){
		if (this.touchId!=touchWrapper.id){
			return;
		}

		setDomTranslate(stick1 , 0 , 0);
		this.reset();

		// info.innerHTML=" ["+0+","+0+"]";
	},
	reset : function(){
		this.displayed=false;
		this.touchId=null;
		slot1.style.display="none";	
	}
});

	controller.addListener(any);
	controller.addListener(tap);
	controller.addListener(pan);
	controller.addListener(swipe);
	controller.addListener(scale);
	controller.addListener(testTouch);


}



