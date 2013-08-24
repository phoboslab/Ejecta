
;(function(scope, undefined) {

'use strict';

var brushes=[]
function createBrushes(){
	var colors = [];

	for (var i=0;i<1;i++){
		var r=randomInt(0,255),
			g=randomInt(0,255),
			b=randomInt(0,255);
		colors.push("rgba("+r+","+g+","+b+",1)");
	}
	colors=["#ffffff"]
	var brushesImg=ResourcePool.get("brushes");
	var w=brushesImg.width,
		h=brushesImg.height;
	for (var i=0;i<colors.length;i++){
		var c=createRect(w,h,colors[i]);
		c.color=colors[i];
		var ctx=c.getContext("2d");
		ctx.globalCompositeOperation="destination-in";
		ctx.drawImage(brushesImg,0,0);
		brushes[i]=c;
	}
}

	var Scene = scope.Scene = function(cfg) {
		scope.merger(this, cfg);
	}

	Scene.prototype = {

		init : function(game) {

		},

		buildBladePath : function(x,y){
			console.log(x,y)
		},

		beforeRun : function(game) {
			console.log("beforeRun");
			createBrushes();
			this.brushesImg=ResourcePool.get("brushes");
			this.pImg=ResourcePool.get("p");

			this.brushes=[];
			this.brushes2=[];

			// for (var color in brushes){

			// }

			for (var r=0;r<4;r+=1){
				for (var c=0;c<4;c+=1){
					var brush=brushes[ randomInt(0,brushes.length-1) ];
					var vr=(randomInt(-1,1)||1)/200 * 3;
					// console.log(brush,brush.color)
					this.brushes.push([brush,c*64,r*64,64,64,vr,0]);

					var brush=brushes[ randomInt(0,brushes.length-1) ];
					this.brushes2.push([brush,c*64,r*64,64,64,vr,0]);
				}
			}

			// console.log(this.brushes)

			this.px=0
		},

		update : function(timeStep) {


		},


		render : function(context, timeStep) {

			context.clearRect(0,0,context.canvas.width, context.canvas.height);

			var cloud1=ResourcePool.get("cloud1");
			var cloud2=ResourcePool.get("cloud2");
			var cloud3=ResourcePool.get("cloud3");
			var cloud4=ResourcePool.get("cloud4");
			var cloud5=ResourcePool.get("cloud5");
			var cloud6=ResourcePool.get("cloud6");


			context.globalCompositeOperation="source-over";

			var len=this.brushes.length;
			len=3;
			var offset=16;
			var rrr=null;
			var x=50,y=50;

			for (var r=0;r<10;r+=1){
				for (var c=0;c<14;c+=1){
					var x=100+c*64, y=100+r*64;
					var i=0;
					// for (var i=0;i<len;i+=1){
						for (var j=0;j<len;j+=1){
							var b=this.brushes[j];
							if (rrr===null){
								b[6]+=b[5]
								rrr=b[6];
							}
							context.translate(x+j*offset,y+i*offset)
							context.rotate(rrr);
							context.drawImage(b[0],b[1],b[2],b[3],b[4],-32, -32,b[3],b[4])
							context.rotate(-rrr);
							context.translate(-x-j*offset,-y-i*offset)
						}
					// }
	
				}
			}

			var bakComposite=context.globalCompositeOperation||"source-over";
			context.globalCompositeOperation="source-in";
			// context.globalCompositeOperation="xor";
			// context.drawImage(ResourcePool.get("stars"),10,10)
			// console.log(ResourcePool.get("stars"))
			context.drawImage(ResourcePool.get("p1"),this.px,0,1024,768)

			// context.drawImage(ResourcePool.get("p2"),0,this.px,16*8,256*8)
// this.px--

			context.globalCompositeOperation=bakComposite;

		},


		handleInput : function(game) {

		},


		destructor : function(game) {

		}

	}

}(this));

