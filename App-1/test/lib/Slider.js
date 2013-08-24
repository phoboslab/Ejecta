
"use strict";

var Slider=function(options) {
	for (var p in options){
		this[p] = options[p];
	}
}

Slider.prototype={

    velX : 0,
    velY : 0,
    accX : 0,
    accY : 0,
    accV : 0.0075,
    dx : 0,
    dy : 0,
    entity : null,

    init : function(entity){
    	this.entity=entity||this.entity;
    },

    reset : function(){
        this.started=false;
        this.sliding=false;

    	var entity=this.entity;
        this.velX=this.velY=this.accX=this.accY=0;
    },

    start : function(vx,vy){
        if (this.sliding){
            // vx*=0.75;
            // vy*=0.75;

        	var entity=this.entity;
            this.velX=vx||0;
            this.velY=vy||0;
            this.accX=this.velX>0?-this.accV:(this.velX<0?this.accV:0);
            this.accY=this.velY>0?-this.accV:(this.velY<0?this.accV:0);

	        this.sliding=false;
            this.started=true;
        }else{
	        this.started=false;
        }
    },

    stop : function(){
        this.reset();
    },

    update : function(timeStep){
        if (!this.started){
            return false;
        }
    	var entity=this.entity;

        var newVelX=this.velX+this.accX * timeStep;
        var newVelY=this.velY+this.accY * timeStep; 

        var dx=(this.velX + newVelX)/2 * timeStep;
        var dy=(this.velY + newVelY)/2 * timeStep;

        if (newVelX*this.velX<=0||Math.abs(dx)<0.004){
            dx=0;
            this.velX=0;
            this.accX=0;
        }else{
            this.velX=newVelX;
        }
        if (newVelY*this.velY<=0||Math.abs(dy)<0.004){
            dy=0;
            this.velY=0;
            this.accY=0;
        }else{
            this.velY=newVelY;
        }

        if (dx || dy){
            this.dx=dx;
            this.dy=dy;

            return true;

        }else{
            this.dx=0;
            this.dy=0;

            this.sliding=false;
            this.started=false;

            return false;
        }
    }

};
