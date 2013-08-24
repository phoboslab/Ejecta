
var World3D=function(options){
	for (var key in options){
		this[key]=options[key];
	}
}

World3D.prototype={ 

	origin : null, 

	camera : null,
	entities : null,

	init : function(){
		this.origin={
					x:0,
					y:0,
					z:0
				};
		this.offset=this.offset||{
								x:0,
								y:0,
								z:0
							};

		this.camera=this.camera||new Camera({
								x : 0,
								y : 0,
								z : 0,
								perspective : 600
							});

		this.entities=this.entities||[];
		this.vertexs=this.vertexs||[];

	},

	reset : function(){
		this.camera.reset();
		this.entities.length=0;
		this.vertexs.length=0;
	},

	addEntity : function(entity){
		this.entities.push(entity)
	},

	addVertexs : function(vertexs){
		var Me=this;
		if (Array.isArray(vertexs)){
			vertexs.forEach(function(v){
				Me.vertexs.push(v);
			})
		}else{
			Me.vertexs.push(vertexs);	
		}
	},

	rotateVertexX : function(v, angle){
    	var cos=Math.cos(angle);
    	var sin=Math.sin(angle);
		var y=v.y, z=v.z;
        v.y = y*cos - z*sin;
        v.z = y*sin + z*cos;
	},
	rotateVertexY : function(v, angle){
    	var cos=Math.cos(angle);
    	var sin=Math.sin(angle);
   		var z=v.z, x=v.x;
        v.z = z*cos - x*sin;
        v.x = z*sin + x*cos;
	},
	rotateVertexZ : function(v, angle){
    	var cos=Math.cos(angle);
    	var sin=Math.sin(angle);
    	var x=v.x, y=v.y;
        v.x = x*cos - y*sin;
        v.y = x*sin + y*cos;
	},

	update : function(timeStep){
		var camera=this.camera;

		this.entities.forEach(function(entity){
			entity.update(timeStep);
		});

		camera.transform(this.vertexs);

		this.entities.forEach(function(entity){
			entity.afterUpdate(timeStep);
		});

		camera.afterUpdate(timeStep);
	},

	render : function(context){

		this.camera.sortByZIndex(this.vertexs);

		context.save();
		context.translate(this.offset.x,this.offset.y);
		this.entities.forEach(function(entity){
			entity.render(context);
		});
		this.renderVertexs(context);
		context.restore();

	},
	renderVertexs : function(context){
		this.vertexs.forEach(function(vertex){
			var entity=vertex.parent;
			entity.renderVertex(vertex,context);
		})
	}


}

	