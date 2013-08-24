
"use strict";


var ViewBridge={

	ID : 1 ,
	_init : function(){
		this.callId=1;
		this.awatingCallbacks = {};
	},
	initInWeb : function(nativeView){
		this._init();
		this.inWeb=true;
		this.remoteName="evalNative";
		this.nativeView=nativeView||this.nativeView;

		this.evalNative=function(script){
			evalIframes[iframeIndex].src="eval://script/?"+script;
			iframeIndex=iframeIndex<3?iframeIndex+1:0;
		}

		var evalIframes=[];
		var iframeIndex=0;
        for (var i=0;i<=3;i++){
            var iframe=document.createElement("iframe");
            evalIframes.push(iframe);
            iframe.width=iframe.height=0;
            iframe.style.display = 'none';
        }

	    function initExecIframes(){
	    	if (document.body&&document.body.appendChild){
	    		evalIframes.forEach(function(iframe){
				     document.body.appendChild(iframe);
	    		})	    		
	    	}else{
	    		setTimeout(initExecIframes,10);
	    	}
	    }
	    initExecIframes();

	},

	initInNative : function(webView){
		this._init();
		this.inNative=true;
		this.remoteName="evalWeb";
		this.webView=webView||this.webView;

		this.evalWeb=function(script){
			this.webView.eval(script);
		}
	
	},

	evalRemote : function(script){
		this[this.remoteName](script);
	},

	evalRemoteWithArgs : function(func,args){
		args=Array.prototype.slice.call(args,0);
		var str=JSON.stringify(args);
		this[this.remoteName](func+"("+str.substring(1,str.length-1)+")");
	},


	callRemote : function(cmd, args, callback){
		var args = Array.prototype.slice.call(arguments,1);
		var callId = this.callId ++;
		if(callId >= 1024) callId = this.callId = 1;
		this.awatingCallbacks[callId] = args.pop(); //callback
		var _cb="function _cb(){ViewBridge.callbackRemote("+callId+",arguments);}";
		var a;
		if (args.length>0){
			a=JSON.stringify(args);
			a=a.substring(1,a.length-1)+",";
		}else{
			a="";
		}
		this[this.remoteName]( cmd+"("+a+_cb+")");
	},

	callbackRemote : function(callId, args){
        args=Array.prototype.slice.call(args,0);
		this.evalRemote("ViewBridge.callback("+callId+","+JSON.stringify(args)+")");
	},

	callback : function(callId,args){
		var cb=this.awatingCallbacks[callId];
		delete this.awatingCallbacks[callId];
		if (cb){
			return cb.apply(null,args);
		}
	}

}