"use strict";
Toucher.Scale=Toucher.Listener.extend({

	scale : 1 ,
	minScale : 0.5,
	maxScale : 2,

	filterWrappers : function(type,wrappers,event,controller){
		return controller.touchedCount==2;
	},

	start : function(wrappers,event,controller){

	},

	move : function(wrappers,event,controller){
		var t=[];
		for (var key in controller.touched){
			t.push(controller.touched[key]);
		}
		var t0=t[0], t1=t[1];
		if (!t1){
			return;
		}
		var disX= (t1.startPageX-t0.startPageX);
		var disY= (t1.startPageY-t0.startPageY);

		var cx=t0.startPageX+(disX>>1), 
			cy=t0.startPageY+(disY>>1);

		var dis=Math.sqrt(disX*disX+disY*disY);

		disX= (t1.pageX-t0.pageX);
		disY= (t1.pageY-t0.pageY);
		var newDis=Math.sqrt(disX*disX+disY*disY);

		var scale=newDis/dis;
		this.trigger(scale,cx,cy,wrappers,event,controller);
	},

	end : function(wrappers,event,controller){

	},

	/* Implement by user */
	trigger : function(scale,cx,cy,wrappers,event,controller){
	
	}


});