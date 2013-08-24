"use strict";
Toucher.Hold=Toucher.Tap.extend({

	startTime : 0,

	start : function(wrappers, event, controller){
		this.startTime=wrappers[0].startTime;
	},
	move : function(wrappers, event, controller){
		if (this.startTime){
			var t0=wrappers[0];
			if (!this.checkMoveDistance(t0)){
				this.startTime=Date.now();
			}
		}
	},
	end : function(wrappers, event, controller){
		this.startTime=0;
	}
	
});


