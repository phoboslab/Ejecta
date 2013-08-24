
"use strict";


	var MediaLoader=function(cfg){
			for (var key in cfg){
				this[key]=cfg[key]
			}	
		};
	ProcessQ.types["media"]=AudioLoader;


	document.addEventListener("deviceready", function(){
		window.isCordova=true&&!!window.cordova;
		
		ProcessQ.types["media"]=MediaLoader;

		Media.prototype._play=Media.prototype.play;
		Media.prototype.play = function(options) {
			var loop=this.loop;
			if (loop){
				options=options||{};
				options.numberOfLoops=loop===true?Number.MAX_VALUE:loop;
			}
			this._play(options);
		};

		MediaLoader.prototype={
			async : false ,
			loop : false ,
			constructor : MediaLoader,
			id : null ,
			start : function(queue){
				var media = this.media= new Media(this.src, this.onSuccess, this.onError);
				media.loop=this.loop;
				//
				this.finished=true;
				// console.log(["media",this.src]);
			},
			onSuccess : function(event){
			},
			onError : function(event){

			},
			getResult : function(){
				return this.media;
			},

			onFinish : function(queue){

			},

			isFinished : function(queue){
				return this.finished;
			},

			isError : function(queue){
				return this.errorEvent;
			}

		}

		

	}, false);


