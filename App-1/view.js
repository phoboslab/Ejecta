	calcWindowSize();

	var logBar;
	function $id(id){
		return document.getElementById(id);

	}
	function log(msg){
		logBar.innerHTML=msg;
	}


    window.onload=function(){
 
    	ViewBridge.initInWeb();

        // initAllUI();

    	window.addEventListener("touchmove",function(){
			event.preventDefault();
		},true);
		document.addEventListener("touchmove",function(){
			event.preventDefault();
		},true);
		document.body.addEventListener("touchmove",function(){
			event.preventDefault();
		},true);
        
        
		var logBar=$id("log");
		var container=$id("container");
        var canvas=$id("canvas");
		var splash=$id("splash");
		  
        var w=window.innerWidth+"px",
            h=window.innerHeight+"px";
        container.style.width=w;
        container.style.height=h;
        splash.style.width=w;
		splash.style.height=h;

		canvas.style.display="block";

    }
