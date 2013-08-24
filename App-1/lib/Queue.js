
;(function(exports, undefined){
'use strict';

	var Queue = exports.Queue = function(size){
		this.list=[];
		this.size=size||0;
	};

	var proto={

		length : 0,

		clear : function(){
			this.list.length=0;
			this.length=0;
		},


		add: function(node){
			this.list.push(node);
			if ( this.length===this.size ){
				return this.list.shift();
			}else{
				this.length++;
			}
		},

		isFull : function(){
			return this.length===this.size;
		},
		
		getLast : function(num){
			return this.list.slice(-num);
		}
	};

	for (var p in proto){
		Queue.prototype[p]=proto[p];
	}

}( typeof exports=="undefined" ? this : exports ) );





