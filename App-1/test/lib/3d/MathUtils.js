
var MathUtils={

	addVectors: function ( a, b, out ) {

		out.x = a.x + b.x;
		out.y = a.y + b.y;
		out.z = a.z + b.z;

		return out;

	},

	subVectors: function ( a, b, out ) {

		out.x = a.x - b.x;
		out.y = a.y - b.y;
		out.z = a.z - b.z;

		return out;

	},

	dotVectors: function ( a, b ) {

		return a.x*b.x+a.y*b.y+a.z*b.z;

	},
	crossVectors: function ( a, b, out ) {

		out.x = a.y * b.z - a.z * b.y;
		out.y = a.z * b.x - a.x * b.z;
		out.z = a.x * b.y - a.y * b.x;

		return out;

	},
	normalizeVector : function(v){
		this.vectorLength(v)
		v.x/=v.length;
		v.y/=v.length;
		v.z/=v.length;
	},
	vectorLength: function (v) {

		return v.length=Math.sqrt( v.x * v.x + v.y * v.y + v.z * v.z );

	},

}