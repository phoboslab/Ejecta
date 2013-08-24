
var Entity3D=function(options){
	for (var key in options){
		this[key]=options[key];
	}
}

Entity3D.prototype={ 

	x : 0,
	y : 0,
	z : 0,

	angleX : 0,
	angleY : 0,
	angleZ : 0,

	rotated : false,
	changed : false,
	
	useMatrix : true ,
	invertRotate : false,
	
	world : null,

	init : function(world){
		this.fixR=this.invertRotate?-1:1;
		this.world=world;
		this.original={
			x : this.x,
			y : this.y,
			z : this.z,
			angleX : this.angleX,
			angleY : this.angleY,
			angleZ : this.angleZ
		};

		this.initVertexs();
		
		if (this.useMatrix){
			this.matrix=new Matrix4();
		}
        this.reset();

		if (this.onInit){
			this.onInit();
		}

		world.addEntity(this);
		world.addVertexs(this.vertexs);
	},
    reset : function(){

        this.x=this.original.x;
        this.y=this.original.y;
        this.z=this.original.z;
        this.angleX=this.original.angleX;
        this.angleY=this.original.angleY;
        this.angleZ=this.original.angleZ;
		if (this.useMatrix){
	        this.matrix.reset();
		}
        this.setRotation(this.angleX,this.angleY,this.angleZ);
        this.setPosition(this.x,this.y,this.z);
    },

	initVertexs : function(){
		this.vertexs=this.vertexs||[];
		this.vertexCount=this.vertexs.length;
		var Me=this;
		this.vertexs.forEach(function(v,index){
			v.parent=Me;
			v.scale=1;
			v.ox=v.x;
			v.oy=v.y;
			v.oz=v.z;
			v.viewX=v.x;
			v.viewY=v.y;
			v.viewZ=v.z;
			v.index=index;
			v.visible=true;
		});
		this.changed=true;
	},

	onInit : null,


    setPosition : function(x,y,z){
        this.x=x;
        this.y=y;
        this.z=z;
        this.changed=true;
        this.matrix.setPosition(x,y,z);
    },
    translate : function(x,y,z){
        this.x+=x;
        this.y+=y;
        this.z+=z;
        this.changed=true;
        this.matrix.translate(x,y,z);
    },

    checkRotated : function(){
        var rx=this.angleX%Math.PI;
        var ry=this.angleY%Math.PI;
        var rz=this.angleZ%Math.PI;
        return this.rotated=rx!=0||ry!=0||rz!=0;
    },

    setRotation : function(rx,ry,rz){
        this.angleX=rx;
        this.angleY=ry;
        this.angleZ=rz;
        if (this.invertRotate){
	        this.matrix.setRotation(-rx,-ry,-rz);
        }else{
	        this.matrix.setRotation(rx,ry,rz);
        }
        this.changed=true;
    },
    
    rotate : function(rx,ry,rz){
        this.angleX+=rx;
        this.angleY+=ry;
        this.angleZ+=rz;
        if (this.invertRotate){
	        this.matrix.rotateX(-rx);
	        this.matrix.rotateY(-ry);
	        this.matrix.rotateZ(-rz);
        }else{
	        this.matrix.rotateX(rx);
	        this.matrix.rotateY(ry);
	        this.matrix.rotateZ(rz);
        }

        this.changed=true;
    },

    rotateX : function(angle) {
        if (!angle){
            return;
        }
        this.angleX+=angle;
	    if (this.invertRotate){
	        this.matrix.rotateX(-angle);
	    }else{
	        this.matrix.rotateX(angle);
	    }
        this.changed=true;
    },

    rotateY : function(angle) {
        if (!angle){
            return;
        }
        this.angleX+=angle;
	    if (this.invertRotate){
	        this.matrix.rotateY(-angle);
	    }else{
	        this.matrix.rotateY(angle);
	    }
        this.changed=true;
    },

    rotateZ : function(angle) {
        if (!angle){
            return;
        }
        this.angleX+=angle;
	    if (this.invertRotate){
	        this.matrix.rotateZ(-angle);
	    }else{
	        this.matrix.rotateZ(angle);
	    }
        this.changed=true;
    },

    transform : function(vertexs){

    	this.checkRotated();

    	vertexs=vertexs||this.vertexs;

    	var len=vertexs.length;

    	if (this.useMatrix && this.rotated){
	        var te = this.matrix.elements;
			for (var i=0;i<len;i++){
	    		var vertex=vertexs[i];
	    		var x = vertex.ox, y = vertex.oy, z = vertex.oz;
	            vertex.x = te[0] * x + te[1] * y + te[2]  * z + te[3] ;
	            vertex.y = te[4] * x + te[5] * y + te[6]  * z + te[7] ;
	            vertex.z = te[8] * x + te[9] * y + te[10] * z + te[11] ;                 
	    	}
	    }else if(this.changed){
			for (var i=0;i<len;i++){
	    		var vertex=vertexs[i];
	    		var x = vertex.ox, y = vertex.oy, z = vertex.oz;
	            vertex.x=x+this.x;
	            vertex.y=y+this.y;
	            vertex.z=z+this.z;
	    	}
	    }
    },

    afterUpdate : function(timeStep){
        this.rotated=false;
        this.changed=false;
    },

    update : function(timeStep){

    },
	renderVertex : function(vertex,context){

	},
	render : function(context){

	}

}