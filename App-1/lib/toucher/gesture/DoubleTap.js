"use strict";
Toucher.DoubleTap=Toucher.Tap.extend({

	maxTimeLag : 600 ,
	maxDistance : 10,
	enabled : false ,
	prevTap : null ,

	end : function(wrappers, event, controller){
		if (this.enabled){
			var t0=wrappers[0];
			if ( this.checkMoveDistance(t0) && this.checkTimeLag(t0) ){
				var startTime=t0.startTime;
				var x=t0.pageX;
				var y=t0.pageY;
				if (this.prevTap!==null){
					if (startTime-this.prevTap.endTime<=this.maxTimeLag
						&& Math.abs(x-this.prevTap.pageX)<=this.maxDistance
						&& Math.abs(y-this.prevTap.pageY)<=this.maxDistance ){
						this.trigger(x, y, wrappers,event,controller);
						this.prevTap=null;
						this.enabled=false;
						return;
					}else{
						this.prevTap.endTime=t0.endTime;
						this.prevTap.startTime=startTime;
						this.prevTap.pageX=x;
						this.prevTap.pageY=y;
					}
				}else{
					this.prevTap={
						endTime : t0.endTime ,
						pageX : x ,
						pageY : y 
					}
				}
			}else{
				this.prevTap=null;
			}	
		}else{
			this.prevTap=null;
		}
		this.enabled=false;
	},

	/* Implement by user */
	trigger : function(x,y, wrappers,event,controller){

	}


});


