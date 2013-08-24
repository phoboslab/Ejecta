
function randomInt(lower, higher) {
	return ((higher - lower + 1) * Math.random() + lower)>>0;
}
function noop(){

}
function reload(){
	window.location.reload();
}

function $id(id){
	return document.getElementById(id);
}


function merger(receiver, supplier, override) {
	for (var key in supplier) {
		if (override !== false || !(key in receiver)) {
			receiver[key] =supplier[key];
		}
	}
	return receiver;
}

function clone(obj){
    return merger({},obj);
}
function cloneJson(obj){
	var str=JSON.stringify(obj);
    return JSON.parse(str);
}

function randomPick(list){
	return list[ Math.random()*list.length|0 ];
}


function checkBoxCollide( box1, box2){
	return  box1.x1<box2.x2
		&& box1.x2>box2.x1
		&& box1.y1<box2.y2 
		&& box1.y2>box2.y1 ;
}

function calPolyAABB (poly){
    var minX=Infinity, minY=Infinity;
    var maxX=-minX, maxY=-minY;
    var len=poly.length;
    for(var i = 0; i < len; i++){
        var p=poly[i];
        if (p[0]<minX){
            minX=p[0];
        }
        if (p[0]>maxX){
            maxX=p[0];
        }
        if (p[1]<minY){
            minY=p[1];
        }
        if (p[1]>maxY){
            maxY=p[1];
        }
    }
    var width=maxX-minX, height=maxY-minY;
    return [minX,minY, maxX,maxY, width, height ];
}

var RAD_TO_DEG=180/Math.PI;
var DEG_TO_RAD=Math.PI/180;

window.devicePixelRatio=window.devicePixelRatio||1;


function getBrowserInfo(){
		var browser={};

		if (!window.navigator || !window.navigator.userAgent){
			return browser;
		}
		var ua=window.navigator.userAgent.toLowerCase();
		var match =
				/(chrome)[ \/]([\w.]+)/.exec( ua ) ||
	            /(chromium)[ \/]([\w.]+)/.exec( ua ) ||
				/(opera)(?:.*version)?[ \/]([\w.]+)/.exec( ua ) ||
				/(msie) ([\w.]+)/.exec( ua ) ||
				/(safari)[ \/]([\w.]+)/.exec( ua ) ||
				/(webkit)[ \/]([\w.]+)/.exec( ua ) ||
				!/compatible/.test( ua ) && /(mozilla)(?:.*? rv:([\w.]+))?/.exec( ua ) ||
				[];	

		browser[ match[1] ]=true;
		
		browser.mobile=ua.indexOf("mobile")>0 || "ontouchstart" in window; 

		browser.iPhone=/iphone/.test(ua);
		browser.iPad=/ipad/.test(ua);
		browser.iPod=/ipod/.test(ua);
		browser.iOS = browser.iPhone || browser.iPad || browser.iPod ;
		browser.iOS4=browser.iOS && ua.indexOf("os 4")>0;
		browser.iOS5=browser.iOS && ua.indexOf("os 5")>0;
		browser.iOS6=browser.iOS && ua.indexOf("os 6")>0;

		browser.android=/android/.test(ua);
		browser.android2=/android 2/.test(ua);
		browser.android4=/android 4/.test(ua);
		
		browser.retain=window.devicePixelRatio>1.5;

		browser.viewport={
			width:window.innerWidth,
			height:window.innerHeight
		};
		browser.screen={
			width:window.screen.availWidth*window.devicePixelRatio, 
			height:window.screen.availHeight*window.devicePixelRatio
		};
			
		return browser;
	}

function hideAddressBar(once){ 
	if (!window.scrollTo){
		return;
	}
	setTimeout(function(){ 
		window.scrollTo(0, 1);
		if (once===false){
			hideAddressBar(once);
		}
	}, 1);			
}



function setViewportScale(scale,scalable){
	scale=scale||1; // ?  1/window.devicePixelRatio ;

	var meta=document.createElement("meta");
	if (!meta || !meta.setAttribute){return};
	meta.setAttribute("name","viewport");
	var content=[
		"width=device-width", 
		"height=device-height",
		"user-scalable="+(scalable?"yes":"no"),
		"minimum-scale="+scale/(scalable?2:1), 
		"maximum-scale="+scale*(scalable?2:1),
		"initial-scale="+scale,
		"target-densitydpi=device-dpi"
	];
	meta.setAttribute("content", content.join(", "));
	document.head.appendChild(meta);
}

function calcWindowSize(){
	var size={};
	var browser=getBrowserInfo();

	if( window.devicePixelRatio==1) {
			setViewportScale(1);
			size.width = window.innerWidth;
			size.height = window.innerHeight;
	} else {
		if (!browser.chrome&&browser.android){
			setViewportScale(1);
			size.width = window.innerWidth;
			size.height = window.innerHeight;
		}else{
			setViewportScale(0.5);
			// setViewportScale(1/window.devicePixelRatio)
			size.width = window.innerWidth;
			size.height = window.innerHeight;
		}
	}
	return size;
}

function showWindowSize(){
	var bodyBounding=!document.body?null:document.body.getBoundingClientRect();
	var size=[
		["inner",window.innerWidth, window.innerHeight],
		["screen",window.screen.width, window.screen.height],
		["avail",window.screen.availWidth, window.screen.availHeight],
		!document.body?null:["client",document.body.clientWidth, document.body.clientHeight],
		!document.body?null:["offset",document.body.offsetWidth, document.body.offsetHeight],
		!document.body?null:["scroll",document.body.scrollWidth, document.body.scrollHeight],
		!document.body?null:["Bounding",bodyBounding.width, bodyBounding.height]
	]
	console.log(size.join("--"))
	alert(size.join("--"))
	return size;
};

function ajaxCall(url,options){
	options=options||{};
		var method=options.method,
			params=options.params,
			onSuccess=options.onSuccess,
			onError=options.onError;
	    var xhr = new XMLHttpRequest(); 
        xhr.open( method||"GET", url, false); 
        xhr.onreadystatechange = function() { 
            if (xhr.readyState == 4) {
            	if (xhr.status==200){
	            	if (onSuccess){
	            		onSuccess(xhr.responseText,xhr);
	            	}
            	}else if (onError){
            		onError(xhr.responseText,xhr);
            	}
            }else{

            }
        } 
        xhr.send(params); 
        return xhr;
}


function getImageDataURI(image,options){
	options=options||{};
	var canvas=getImageDataURI.canvas;
	var iX=options.iX||0,
		iY=options.iY||0;
	var iW=options.iW||image.width,
		iH=options.iH||image.height;
	var w=options.w||iW;
	var h=options.h||iH;
	type=options.type||"image/jpeg";
	quality=options.quality||0.6;
	canvas.width=w;
	canvas.height=h;
	var ctx=getImageDataURI.context;
	ctx.drawImage(image,iX,iY,iW,iH,0,0,w,h );
	var dataURI=canvas.toDataURL(type,quality);
	var data=dataURI.substring(dataURI.indexOf(",")+1);

	return data;
}
getImageDataURI.canvas=document.createElement("canvas");
getImageDataURI.context=getImageDataURI.canvas.getContext("2d");

function resizeImage(image,w,h){
	var iW=image.width, iH=image.height;
	w=w||iW;
	h=h||iH;
	if (w===iW && h===iH){
		return image;
	}
	var canvas=document.createElement("canvas");
	canvas.width=w;
	canvas.height=h;
	var ctx=canvas.getContext("2d");
	ctx.drawImage(image,0,0,iW,iH,0,0,w,h );
	return canvas;
}

function autoResize(w,h){
	var nw=w, nh=h;
	s=w/h;
	if (w>Config.maxImageWidth){
		nw=Config.maxImageWidth;
		nh=nw/s;
	}else if (h>Config.maxImageHeight){
		nh=Config.maxImageHeight;
		nw=nh*s;
	}
	return {
		w : nw,
		h : nh
	}
}
;






