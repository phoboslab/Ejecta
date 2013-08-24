
var Config={
	width : window.innerWidth,
	height : window.innerHeight,
  FPS : 60
}

function randomInt(lower, higher) {
    return ((higher - lower + 1) * Math.random() + lower)>>0;
}

var canvas,context;
window.onload=function(){
  canvas = document.getElementById("canvas");
  canvas.width = Config.width;
  canvas.height = Config.height;
  context = canvas.getContext("2d");
  context.strokeStyle="red";
  start();
}


var lines=[];
var lineImg;
function start(){
    lineImg=document.createElement("canvas");
    lineImg.width=2;
    lineImg.height=2;
    var ctx=lineImg.getContext("2d");
    ctx.fillStyle="red";
    ctx.fillRect(0,0,lineImg.width,lineImg.height);

    for (var i=0;i<2000;i++){
        var x1=randomInt(5,Config.width-5);
            y1=randomInt(5,Config.height-5);
        var x2=randomInt(5,Config.width-5);
            y2=randomInt(5,Config.height-5);
        var dx=x2-x1,
            dy=y2-y1;
        var angle=Math.atan2(dy,dx);
        var length=Math.sqrt(dx*dx+dy*dy);
        lines.push([x1,y1,x2,y2,length,angle]);
    }
    drawLineImage();
    context.clearRect(canvas.width, canvas.height);
    drawLine();
}

function drawLine(){
    var s=Date.now();
    for (var i=lines.length-1;i>=0;i--){
    context.beginPath();
        var line=lines[i];
        context.moveTo(line[0],line[1])
        context.lineTo(line[2],line[3])
    context.stroke();
    context.closePath();
    }
    console.log(Date.now()-s);
}

function drawLineImage(){
    var s=Date.now();
    for (var i=lines.length-1;i>=0;i--){
        var line=lines[i];
        context.save();
        context.translate(line[0],line[1]);
        context.rotate(line[5]);
        context.drawImage(lineImg,0,0,1,1,
                0,0,line[4],1
            );
        context.restore();
    }
    console.log(Date.now()-s);
}


if (typeof ejecta!="undefined"){
    window.onload();
    
}else{
    
}