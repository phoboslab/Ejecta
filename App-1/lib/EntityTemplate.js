

;(function(scope, undefined){
"use strict";

	var EntityTemplate=scope.EntityTemplate={};

	EntityTemplate._movable={

		x : 0,
		y : 0 ,

		velX : 0,
		velY : 0,
		accX : 0,
		accY : 0,

		minX : -Infinity,
		minY : -Infinity,

		maxX : Infinity,
		maxY : Infinity,

		minVelX : -Infinity,
		minVelY : -Infinity,

		maxVelX : Infinity,
		maxVelY : Infinity,

		defaultVelX : 0,
		defaultVelY : 0,

		computeVelX : function(distance, time){
			var vx=distance/time;
			this.defaultVelX=vx;
		},
		
		computeVelY : function(height, time){
			var vy=2*height/time
			var accY=-vy/time;
			this.defaultVelY=vy;
			this.accY=accY;
		},

		computeVel : function(distance, height, time){
			var vx=distance/time;
			time=time/2;
			var vy=2*height/time
			var accY= vy/time;
			this.defaultVelX=vx;
			this.defaultVelY=-vy;
			this.accY=accY;
		},

		updateMovement : function(timeStep){

			this.lastVelX=this.velX;
			this.lastVelY=this.velY;

			var newVelX=this.velX+this.accX * timeStep;		
			var newVelY=this.velY+this.accY * timeStep;	

			newVelX=Math.min(this.maxVelX, Math.max(this.minVelX,newVelX) );	
			newVelY=Math.min(this.maxVelY, Math.max(this.minVelY,newVelY) );	
			
			var dx=(this.velX + newVelX)/2 * timeStep;
			var dy=(this.velY + newVelY)/2 * timeStep;

			this.velX=newVelX;
			this.velY=newVelY;

			this.deltaX=dx;
			this.deltaY=dy;			

		},

		updatePosition : function(){
			this.x=Math.max(this.minX,Math.min(this.x + this.deltaX,this.maxX));
			this.y=Math.max(this.minY,Math.min(this.y + this.deltaY,this.maxY));
		}
		
	};

	EntityTemplate._collidable={
		collidable : true,
		hitBox : null,

		initHitBox : function(){
			var box=this.hitBox||{
				left : 0,
				top : 0,
				width : this.width,
				height : this.height
			};
			this.hitBox={};
			for (var key in box){
				this.hitBox[key]=box[key];
			}
			this.updateHitBox();
		},

		updateHitBox : function(){
			var box=this.hitBox;
			box.x1=this.x+box.left;
			box.y1=this.y+box.top;
			box.x2=box.x1+box.width;
			box.y2=box.y1+box.height;
			return box;
		},		

		getHitBox : function(){
			return this.hitBox;
		},
		
		isCollidedWith : function(other){
			return false;
		},
		onCollided : function(other){

		}

	};

	scope.merger( EntityTemplate ,{

		collidable : function(obj){
			obj=obj||{};
			scope.merger(obj, EntityTemplate._collidable, false);
			return obj;

		},

		movable : function(obj){
			obj=obj||{};
			scope.merger(obj, EntityTemplate._movable, false);
			return obj;
		}
	});

}(this));




