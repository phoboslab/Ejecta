"use strict";
Toucher.Any=Toucher.Listener.extend({

	enabled : false ,

	filterWrappers : function(type,wrappers,event,controller){
       return true;
	},

	start : function(wrappers,event,controller){

	},

	move : function(wrappers,event,controller){

	},

	end : function(wrappers,event,controller){

	},

	cancel : function(wrappers,event,controller){

	},

	/* Implement by user */
	trigger : function(dx,dy,sx,sy,x,y,wrappers,event,controller){

	}

});

