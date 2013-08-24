;(function(scope, undefined) {
	'use strict';

	var Animation = scope.Animation = function(cfg) {
		scope.merger(this, cfg);
		this.init();
	}

	Animation.prototype = {

		constructor: Animation,

		frames: null,
		frameCount: -1,
		frameDuration : Infinity,
		currentFrame: null,
		currentFrameIndex: -1,
		currentDuration: -1,
		currentPlayed: -1,

		startFrameIndex: 0,

		originX: 0,
		originY: 0,

		loop: false,
		paused: false,

		img: null,
		x: 0,
		y: 0,
		width: 0,
		height: 0,

		init: function() {
			this.img = this.getImage(this.img);
			this.frames = this.frames || this.getFramesConfig();
			this.frameCount = this.frames.length;
			if (this.frameCount > 0) {
				var Me = this;
				this.frames.forEach(function(frame) {
					Me.initFrame(frame);
				});
				this.setFrame(0);
			}
		},
		
		// reset : function(){
		// 	this.setFrame(0);
		// },

		initFrame : function(frame){
			frame.img = this.getImage(frame.img) || this.img;
			if (frame.sub && !frame.sub.inited && this.frameList){
				frame.subConut=frame.sub.length;
				for (var i=0;i<frame.subConut;i++){
					frame.sub[i]=this.frameList[frame.sub[i]];
					frame.sub[i].img=this.getImage(frame.sub[i].img)||frame.img;
				}				
				frame.sub.inited=true;
			}
			frame.x = frame.x || 0;
			frame.y = frame.y || 0;
			frame.w = frame.w || this.width || frame.img.width;
			frame.h = frame.h || this.height || frame.img.height;
			frame.ox = frame.ox || 0;
			frame.oy = frame.oy || 0;
			frame.dw = frame.dw || this.dw || frame.w;
			frame.dh = frame.dh || this.dh || frame.h;
			frame.d = frame.d || frame.d === 0 ? frame.d:this.frameDuration;
			// frame.d*=8;
			return frame;
		},

		setData: function(data) {
			for (var key in data) {
				this[key] = data[key];
			}
			this.frameCount = this.frames.length;
			this.img = this.getImage(this.img);
			this.setFrame(0);
		},

		getImage: function(img) {
			if (typeof img == "string") {
				return ResourcePool.get(img);
			}
			return img;
		},
		getFramesConfig: function() {
			return [];
		},

		setFrame: function(index) {
			this.currentFrameIndex = index;
			this.currentPlayed = 0;
			this.currentFrame = this.frames[index];
			if (!this.currentFrame){
				// console.log("Animation Index",index,this.frameCount);
			}
			this.currentDuration = this.currentFrame.d;
		},
		nextFrame:function(){
			this.currentFrameIndex++;
			this.setFrame(this.currentFrameIndex);
		},

		update: function(timeStep) {
			if (this.paused) {
				return false;
			}
			var last = this.currentFrameIndex;
			if (this.currentPlayed >= this.currentDuration) {
				if (this.currentFrameIndex === this.frameCount - 1) {
					if (this.loop) {
						this.currentFrameIndex = this.startFrameIndex;
					}
					this.onEnd && this.onEnd(timeStep);
				} else {
					this.currentFrameIndex++;
				}
				this.setFrame(this.currentFrameIndex);

			} else {
				this.currentPlayed += timeStep;
			}
			return last !== this.currentFrameIndex;
		},

		onEnd: null,

		render: function(context) {
			
			var frame = this.currentFrame;
			var x = this.x+this.originX,
				y = this.y+this.originY;

			var img = frame.img || this.img;

			var flip=1;
			if (this.flip||frame.flip){
				context.scale(-1,1);
				flip=-1;
			}
			if (frame.sub){
				for (var i=0,len=frame.subConut;i<len;i++){
					var _frame=frame.sub[i];
					if (_frame.flip){
						context.scale(-1,1);
						flip=-1;
					}
					context.drawImage(_frame.img, _frame.x, _frame.y, _frame.w, _frame.h, 
						x*flip-_frame.ox, y-_frame.oy, _frame.w, _frame.h); 
					if (_frame.flip){
						context.scale(-1,1);
						flip=1;
					} 
				}		

			}else{
				context.drawImage(img, frame.x, frame.y, frame.w, frame.h, 
					x*flip-frame.ox, y-frame.oy, frame.w, frame.h); 
				// context.strokeStyle="red"
				// context.fillText(this.currentFrameIndex,x*flip-frame.ox, y-frame.oy)
				// context.strokeRect(x*flip-frame.ox, y-frame.oy, frame.w, frame.h)
				// context.strokeRect(x*flip, y, 4,4)
			}


			if (this.flip||frame.flip){
				context.scale(-1,1);
			}
		}
	};


}(this));