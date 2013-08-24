
;(function(scope,undefined){
'use strict';

	var SoundPool=scope.SoundPool=function(cfg){
		for (var key in cfg){
			this[key]=cfg[key]
		}
	};

	SoundPool.prototype={
		size : 0,
		index : 0,
		pool : null,
		volume : 1,
		init : function(sound,size){
			this.size=size;
			this.pool=this.pool||[];
			while(size>0){
				var _sound;
				if (sound.cloneNode){
					_sound=sound.cloneNode(true);
				}else if(typeof Media!=="undefined"){
					_sound=new Media(sound.src,sound.successCallback,
    				sound.errorCallback,sound.statusCallback);
    				_sound.loop=sound.loop;
				}
				this.pool.push(_sound);
				size--;
			}
		},
		play : function(){
			this.sound=this.pool[this.index];
			if (this.sound){
				if (this.sound.currentTime!=0){
					this.sound.currentTime=0;
				}
				if (this.sound.setVolume){
    				this.sound.setVolume(this.volume)
				}else{
					this.sound.volume=this.volume;
				}
				this.sound.play();
			}
			this.index=(++this.index)%this.size;
		},
		pause : function(){
			if (this.sound){
				this.sound.pause();
			}
		},
		stop : function(){
			if (this.sound){
				if (this.sound.stop){
					this.sound.stop();
				}else{
					this.sound.pause();
					this.sound.currentTime=0;
				}
			}
		}

	}

}(this));

