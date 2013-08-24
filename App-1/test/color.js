
function $id(id){
	return document.getElementById(id);
}

function randomInt(lower, higher) {
	return ((higher - lower + 1) * Math.random() + lower)>>0;
}

function loadImage(srcList,callback){
	var imgs={};
	var totalCount=srcList.length;
	var loadedCount=0;
	for (var i=0;i<totalCount;i++){
		var img=srcList[i];
		var image=imgs[img.id]=new Image();		
		image.src=img.src||img.url;
		image.onload=function(event){
			loadedCount++;
		}		
	}
	if (typeof callback=="function"){
		var Me=this;
		function check(){
			if (loadedCount>=totalCount){
				callback.apply(Me,arguments);
			}else{		
				setTimeout(check,100);
			}	
		}
		check();
	}
	return imgs;
}

var canvas, context;
var ImgPool;

window.onload=function(event){

	ImgPool=loadImage([
			{id : "bg" , src : "./color-img/bg.png"},
			{id : "1" , src : "./color-img/test-1.png"},
		],function(){
			init();
		});


}

var Config={
	width : 600,
	height : 400,
}

function init(){
	canvas=$id("canvas");
	canvas.width=Config.width;
	canvas.height=Config.height;
	context=canvas.getContext("2d");
	start();
}


function start(){

	context.drawImage(ImgPool["bg"],0,0,Config.width,Config.height);
	
	// 生成随机的"目标颜色"
	var r=randomInt(0,255), g=randomInt(0,255), b=randomInt(0,255);
	var colorAlpha=1;
	var color="rgba("+r+", "+g+", "+b+", "+colorAlpha+")";
	// color="#000000";

	// 此处的imgAlpha 和 前面的colorAlpha会影响到最后的变色效果, 根据需要自行调节 // 
	var imgAlpha=0.5;

	// 绘制变色的图片
	drawColorImage(ImgPool["1"],150,20, color, imgAlpha);

	setTimeout(start,500);
}


// 绘制变色的图片的功能函数
function drawColorImage(img, x, y, color, alpha){
	var w=img.width, h=img.height;
	alpha=alpha||0.5;

	// context.save();
	var bakAlpha=context.globalAlpha||0;
	var bakComposite=context.globalCompositeOperation||"source-over";

	// 1 利用destination-out 在canvas上"挖一个和原图相同形状的洞"
	context.globalCompositeOperation="destination-out";
	context.drawImage(img,x,y);
	
	if (color){
		// 2 用目标颜色填充挖出的这个洞
		context.globalCompositeOperation="destination-over";
		context.fillStyle=color;
		context.fillRect(x-4,y-4,w+8,h+8);		
	}

	// 3 再在相同位置画一个半透明的原图
	context.globalAlpha=alpha;
	context.globalCompositeOperation="source-over";
	context.drawImage(img,x,y);

	context.globalAlpha=bakAlpha;
	context.globalCompositeOperation=bakComposite;
	// context.restore();
}

window.onload();
