"use strict";
Toucher.Pan=Toucher.Listener.extend({

	enabled : false ,

	filterWrappers : function(type,wrappers,event,controller){
       return wrappers.length==1;
	},

	start : function(wrappers,event,controller){
		this.enabled=true;
	},

	move : function(wrappers,event,controller){
		if (this.enabled){
			var t0=wrappers[0];
			var dx=t0.deltaX;
			var dy=t0.deltaY;
			var sx=t0.startPageX;
			var sy=t0.startPageY;
			var x=t0.pageX;
			var y=t0.pageY;
			this.trigger(dx,dy,sx,sy,x,y,wrappers,event,controller);
		}
	},

	end : function(wrappers,event,controller){
		this.enabled=false;
	},

	/* Implement by user */
	trigger : function(dx,dy,sx,sy,x,y,wrappers,event,controller){

	}

});

