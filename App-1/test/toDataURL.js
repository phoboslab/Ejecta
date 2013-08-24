window.Config = {
    width: window.innerWidth,
    height: window.innerHeight
}

var canvas = document.getElementById("canvas");
canvas.retinaResolutionEnabled = true; //false;
canvas.width = Config.width;
canvas.height = Config.height;
if (canvas.style) {
    canvas.style.width = window.innerWidth + "px";
    canvas.style.height = window.innerHeight + "px";
}

var context = canvas.getContext("2d");

var bufferCanvas=document.createElement("canvas");
var bufferContext=bufferCanvas.getContext("2d");
bufferContext.fillStyle="red";


var img=new Image();
img.src="./res/safari.png";
img.onload=function(){
    bufferCanvas.width=64;
    bufferCanvas.height=64;
    bufferContext.drawImage(img,0,0, img.width, img.height,
                        0,0,bufferCanvas.width,bufferCanvas.height);
    var t=Date.now();
    var url=bufferCanvas.toDataURL();
    t=Date.now()-t;
    console.log(url)

    console.log("time : ",t)
    context.drawImage(bufferCanvas,0,0)

}


