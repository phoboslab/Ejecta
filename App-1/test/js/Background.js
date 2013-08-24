
function Background(cfg){
	EntityTemplate.collidable(this);
	merger(this, cfg);
}


Background.prototype={
	
	constructor : Background ,


	init : function(scene){

		this.scene=scene;
		this.img=ResourcePool.get(this.img)||this.img;

	},

	update : function(timeStep){

	},

	render : function(context,timeStep){


	}

}
