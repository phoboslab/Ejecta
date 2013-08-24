
;(function(scope,undefined){
'use strict';
	
	var Sound=scope.Sound=function(cfg){
		for (var key in cfg){
			this[key]=cfg[key]
		}
		this.init();
	};

	Sound.prototype={
		audio : null,
		loop : false,
		volume : 1,
		size : 1,
		init : function(){
			if (this.audio){
				this.audio.loop=this.loop;
				this.audio.volume=this.volume;	

				if (this.size>1){
					this.pool=[];
					this.pool.push(this.audio);
					for (var i=1;i<this.size;i++){
						this.pool.push(this.audio.cloneNode());
					}
					this.index=0;
					this.play=this.playMulti;
				}else{
					this.play=this.playSingle;
				}	
			}

		},
		play : null,
		playSingle : function(){
			this.audio.play();
		},
		playMulti : function(){
			var a=this.audio=this.pool[this.index];
			if (a.currentTime){
				a.currentTime=0;
			}else if (a.seekTo){
				a.seekTo(0);
			}
			a.play();
			this.index=(++this.index)%this.size;
			
		},

		setCurrentTime : function(time){
			if (this.audio.seekTo){
				this.audio.seekTo(time);
			}else if (this.audio.currentTime!=time){
				this.audio.currentTime=time;
			}
		},
		setVolume : function(volume){
			this.audio.volume=volume;
		},
		pause : function(){
			this.audio.pause();
		},
		stop : function(){
			if (this.audio.stop){
				this.audio.stop();
			}else{
				this.audio.pause();
				this.audio.currentTime=0;
			}
		}

	}

	var SoundBatch=scope.SoundBatch=function(cfg){
		for (var key in cfg){
			this[key]=cfg[key]
		}
		this.init();
	};

	SoundBatch.prototype={
		audio : null,
		volume : 1,
		size : 0,
		init :function(){


		},

	}


}(this));

