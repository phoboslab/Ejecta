
;(function(scope, undefined){
'use strict';


var Timer = scope.Timer =function(cfg){	
	for (var property in cfg ){
		this[property]=cfg[property];
	}
};

Timer.prototype= {

	constructor : Timer ,

	staticTimeStep : 0 ,
	minStep : 0,
	maxStep : 2000,
	ratio : 1,
	start : function(){
		this.reset();
		this.startTime=this.lastCurrent;

		return this;		
	},
	removeTask : function(idx){
		this.queue.splice(idx, 1);
	},
	addTask : function(fn,timeout){
		var now=this.current;
		this.queue.push({
			time : now,
			runTime : now+timeout,
			fn : fn
		});
		return this.queue.length-1;
	},

	runTasks : function(){
		var now=this.current;
		for (var i=0,len=this.queue.length;i<len;i++){
			var q=this.queue[i];
			if (now>=q.runTime){
				var fn=q.fn;
				fn();
				this.removeTask(i);
				i--;
				len--;
				//fn();
			}
		}
	},

	reset : function(){
		this.duration=0;
		this.queue=[];
		this.lastTime=this.currentTime = this.now();	
	},

	getTimeStep : function() {
		return this.timeStep;
	},
	current : function(){
		return this.currentTime;
	},
	now : function(){
		return Date.now()*this.ratio;
	},
	tick : function() {
		this.lastTime = this.currentTime;
		this.currentTime=this.now();
		this.realTimeStep = this.currentTime - this.lastTime;
		this.duration+=this.realTimeStep;
		this.timeStep = Math.max(this.minStep, Math.min(this.maxStep,this.realTimeStep));
		return this.currentTime;
	}
};

}(this));

