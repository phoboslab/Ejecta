"use strict";
Toucher.Tap=Toucher.Listener.extend({

	maxTimeLag : 800 ,
	maxDistance : 15,
	enabled : false ,

	filterWrappers : function(type,wrappers,event,controller){
       return wrappers.length==1;
	},

	start : function(wrappers, event, controller){
		this.enabled=true;
	},
	move : function(wrappers, event, controller){
		
	},
	end : function(wrappers, event, controller){
		if (this.enabled){
			var t0=wrappers[0];
			var x=t0.pageX;
			var y=t0.pageY;
			if ( this.checkMoveDistance(t0) && this.checkTimeLag(t0) ){
				this.trigger(x, y, wrappers, event, controller);
			}else if (this.onTouchEnd!==null){
				this.onTouchEnd(x, y, wrappers, event, controller);
			}
		}
		this.enabled=false;
	},
	onTouchEnd : null,

	checkMoveDistance : function(wrapper){
		var dx=Math.abs(wrapper.moveAmountX);
		var dy=Math.abs(wrapper.moveAmountY);

		return dx<=this.maxDistance && dy<=this.maxDistance;
	},
	
	checkTimeLag : function(wrapper){
		return wrapper.endTime - wrapper.startTime < this.maxTimeLag;
	},

	/* Implement by user */
	trigger : function(x, y, wrappers,event, controller){

	}

});


