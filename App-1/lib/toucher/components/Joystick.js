

Toucher.Joystick=Toucher.Listener.extend({

	maxRadius : 100,
	moveX : 0,
	moveY : 0,
	moveDistance : 0,
	rotation : 0,

	RAD_TO_DEG : 180/Math.PI,

	stickRect : null,
	buttonRect : null ,
	stickId : null,
	buttonId : null,
	isInRect : function(rect,x,y){
		return rect && rect[0]<x && x <rect[2]
				&& rect[1]<y && y <rect[3];
	},

	isOnStick : function(x,y){
		return this.isInRect(this.stickRect,x,y);
	},	
	isOnButton : function(x,y){
		return this.isInRect(this.buttonRect,x,y);
	},	

	start : function(wrappers,event,controller){
		for (var i=0;i<wrappers.length;i++){
			var w=wrappers[i];
			if (this.stickId===null && this.isOnStick(w.pageX,w.pageY)){
				this.stickId=w.id;
				this.onStartStick(w,event,controller);
			}else if (this.buttonId===null && this.isOnButton(w.pageX,w.pageY)){
				this.buttonId=w.id;
				this.onStartButton(w,event,controller);
			}
		}
	},

	move : function(wrappers,event,controller){
		for (var i=0;i<wrappers.length;i++){
			var w=wrappers[i];
			if (this.stickId==w.id){
				var dx=w.moveAmountX;
				var dy=w.moveAmountY;
				if ( dx || dy ){

					var rad=Math.atan2(dy, dx);	
					var r= Math.min( this.maxRadius, Math.sqrt(dx*dx+dy*dy) );
					var x= r*Math.cos(rad);
					var y= r*Math.sin(rad);
					this.moveX=x;
					this.moveY=y;
					this.moveDistance=r;
					this.rotation=rad*this.RAD_TO_DEG;
					
					this.onMoveStick(w,event,controller);
				}			
			}else if (this.buttonId==w.id){
				if (!this.isOnButton(w.pageX,w.pageY)){
					this.buttonId=null;
					this.onEndButton(w,event,controller);
				}else{
					this.onMoveButton(w,event,controller);
				}
			}
		}

	},
	end : function(wrappers,event,controller){
		for (var i=0;i<wrappers.length;i++){
			var w=wrappers[i];
			if (this.stickId==w.id){
				this.stickId=null;
				this.moveX=0;
				this.moveY=0;
				this.moveDistance=0;
				this.rotation=0;
				this.onEndStick(w,event,controller);
			}else if (this.buttonId==w.id){
				this.buttonId=null;
				this.onEndButton(w,event,controller);
			}
		}
	},
	onStartStick : function(wrapper,event,controller){

	},	
	onStartButton : function(wrapper,event,controller){

	},
	onEndStick : function(wrapper,event,controller){

	},
	onEndButton : function(wrapper,event,controller){

	},
	onMoveStick : function(wrapper,event,controller){

	},
	onMoveButton : function(wrapper,event,controller){

	},	

	/* Implement by user */
	onStart : function(wrappers,event,controller){
	
	},

	/* Implement by user */
	onMove : function(wrappers,event,controller){
	
	},
	/* Implement by user */
	onEnd : function(wrappers,event,controller){
		
	}

});


