


;(function(scope,undefined){
"use strict";

var Camera=scope.Camera=function(cfg){
	scope.merger(this,cfg);
	this.init();
}


Camera.prototype={
	constructor : Camera,
	x : 0,
	y : 0,
	width : 0,
	height : 0,
	minX : -Infinity,
	minY : -Infinity,
	maxX : Infinity,
	maxY : Infinity,
	top : 0 ,
	right : 0 ,
	bottom : 0 ,
	left : 0 ,
	target : null,

	init : function(){
		this.target=this.target||{
			x:this.x,
			y:this.y
		};
	},

	setPadding : function(top,right,bottom,left){
		this.top=top;
		this.right=right;
		this.bottom=bottom;
		this.left=left;
	},

	lastY : 0,
	focus : function(entity){

		var x=this.x, y=this.y;

		var l = entity.x - x;
		// var r = x + this.width - entity.x;
		var r = this.width - l;
		if (l < this.left) {
			x = entity.x - this.left;
		}else if (r < this.right) {
			x = entity.x + this.right - this.width;
		}

		var t = entity.y - y;
		// var b = y + this.height - entity.y;
		var b = this.height - t;
		if (t < this.top) {
			y = entity.y - this.top;
		}else if (b < this.bottom) {
			y = this.bottom - this.height+entity.y;
		}

		this.setPos(x,y);
	
	},

	setPos : function(x,y){
		// this.x=Math.round(x);
		// this.y=Math.round(y);
		this.x=x<this.minX?this.minX:x>this.maxX?this.maxX:x;
		this.y=y<this.minY?this.minY:y>this.maxY?this.maxY:y;

		// this.x=Math.min( this.maxX ,Math.max( this.minX ,this.x ) );
		// this.y=Math.min( this.maxY ,Math.max( this.minY ,this.y ) );
	},

	render : function(context){
			if (Game.debug){
		context.strokeRect(this.x+10,this.y+10,this.width-20,this.height-20);
			}

	},


	move : function(){
		var x=this.target.x,
			y=this.target.y;
		var vx=this.vx,
			vy=this.vy;

		if (this.x<x){
			this.x+=vx;
			if (this.x>x){
				this.x=x;
			}
		}else if (this.x>x){
			this.x+=vx;
			if (this.x<x){
				this.x=x;
			}
		}

		if (this.y<y){
			this.y+=vy;
			if (this.y>y){
				this.y=y;
			}
		}else if (this.y>y){
			this.y+=vy;
			if (this.y<y){
				this.y=y;
			}
		}
		return this.x==x && this.y==y;
	},

	moveTo : function(x,y,speed){
		var dx=x-this.x,
			dy=y-this.y;
		var rad=Math.atan2( dy , dx );
		this.target.x=x;
		this.target.y=y;
		this.vx= speed * Math.cos(rad);
		this.vy= speed * Math.sin(rad); 

	}

}



}(this));



