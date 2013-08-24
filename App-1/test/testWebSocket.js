
var Config={
	width : window.innerWidth,
	height : window.innerHeight
}

var canvas = document.getElementById("canvas");
canvas.width = Config.width;
canvas.height = Config.height;

var context = canvas.getContext("2d");
console.log("context.canvas==canvas : "+ (context.canvas==canvas) );
context.fillStyle="red";
context.fillRect(2,2,100,100);


var _server="192.168.5.101:3000";

var ws=new WebSocket("ws://"+_server,"");

ws.onopen=function(event){
    console.log("onopen",event.data,event.target==this);
    // console.log(JSON.stringify(event));
    
    ws.send(1);
};

ws.onmessage=function(event){
    console.log("onmessage", event.data,event.target==this);
    // console.log(JSON.stringify(event));
    var i=parseInt(event.data)+1;
    setTimeout(function(){
        ws.send(i);
    },1000);
};

ws.onclose=function(event){
    console.log("onclose",event.data,event.target==this);
    // console.log(JSON.stringify(event));
};

ws.onerror=function(event){
    console.log("onerror", event.message);
    // console.log(JSON.stringify(event));
};


