var Star = function(cfg){	
	for (var property in cfg ){
		this[property]=cfg[property];
	}
};

Star.prototype= {

	constructor : Star ,

	x : 0,
	y : 0,
	z : 0,
	scale : 1,
	viewX : 0,
	viewY : 0,
	viewZ : 0,
	w : 0,
	h : 0,

	iX : 0,
	iY : 0,
	iW : 0,
	iH : 0,
	img : "star",
	targetIndex : 0,
	velocity : 0,
	scaleZ : 1,
	init : function(parent){
		this.parent=parent;
 		this.img=Res[this.img];
		this.iX=0;
        this.iY=0;
        this.iW=this.img.width;
        this.iH=this.img.height;
        this.w=this.iW;
        this.h=this.iH;
        // this.w=this.w*this.scaleZ;
        // this.h=this.h*this.scaleZ;
 	},
	render : function(context, timeStep){

		if (!this.visible){
			return
		}

		var vw=this.w*this.scale*2, vh=this.h*this.scale*2;
		if (this.index===1){

		}
		context.drawImage(this.img,this.iX,this.iY,this.iW,this.iH,
			this.viewX-vw/2,this.viewY-vh/2,vw,vh);
		context.fillStyle="#ff0000"
        context.fillText(this.index,this.viewX,this.viewY)


	}

}