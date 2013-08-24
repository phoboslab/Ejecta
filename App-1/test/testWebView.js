
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

var img=new Image();
img.src="./res/jpeg2000.jpf";
img.onload=function(){
    context.drawImage(img,0,0)
}

var webView = new Ejecta.WebView();
webView.src = "testWebView.html";

ejecta.include("./lib/ViewBridge.js");

ViewBridge.initInNative(webView);

function checkWebViewLoad(cb){
  if (webView.isLoaded()){
    return cb();
  }
  setTimeout(function(){
    checkWebViewLoad(cb)
  },50);
}

checkWebViewLoad(function(){
  console.log("webView loaded");
  setTimeout(start,1000);
});


function start(){
  var a=["a",1,["b",2], {c:3 , d:4}];
      ViewBridge.evalRemote("setTimeout(function(){alert("+JSON.stringify(a)+")},20);");
      
      
  ViewBridge.callRemote("testCallBack","hello from native",function(receive){
          console.log(receive)
      })
}

function testCallBack(msg,cb){
    console.log(msg);
    setTimeout(function(){
      if (cb){
        cb(msg+" from native")
      }
    },1000);
}



