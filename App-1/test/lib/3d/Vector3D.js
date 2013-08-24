


var Vertex3D=function(options){
	for (var key in options){
		this[key]=options[key];
	}
}

Vertex3D.prototype={ 

	x : 0,
	y : 0,
	z : 0,

	set : function(x,y,z){
		this.x=x;
		this.y=y;
		this.z=z;
	},
	equals : function(x,y,z){
		 return (x == this.x && y == this.y && z == this.z);
	},
    toString:function(){
        return '['+this.x+','+this.y+','+this.z+']';
    },

    add : function(x,y,z){
		this.x+=x;
        this.y+=y;
        this.z+=z;
    },

    subtract : function(x,y,z){
		this.x-=x;
        this.y-=y;
        this.z-=z;
    },

    multiply : function(s){
		this.x*=s;
        this.y*=s;
        this.z*=s;
    },
    divide : function(s){
		this.x/=s;
        this.y/=s;
        this.z/=s;
    },
 	length : function() {
        return Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
    },

    normalize : function(){
    	this.divide(this.length());
    },

    dotProduct : function(vector) {
        return this.x*vector.x + this.y*vector.y + this.z*vector.z;
    },

	crossProduct: function ( vector ) {

		var x = this.x, y = this.y, z = this.z;

		this.x = y * vector.z - z * vector.y;
		this.y = z * vector.x - x * vector.z;
		this.z = x * vector.y - y * vector.x;

		return this;

	},
    
    angleTo: function ( v ) {

        return Math.acos( this.dotProduct( v ) / this.length() / v.length() );

    }

}

