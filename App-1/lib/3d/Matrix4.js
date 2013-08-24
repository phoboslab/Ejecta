
var Matrix4=function(options){
	for (var key in options){
		this[key]=options[key];
	}

	this.elements=[];

	// var buffer=new ArrayBuffer(4*16);
	// this.elements=new Float32Array(buffer);;
}

Matrix4.prototype={ 

	reset : function(){

		// [
		// 	1, 0, 0, 0,
		// 	0, 1, 0, 0,
		// 	0, 0, 1, 0,
		// 	0, 0, 0, 1
		// ]

		var te=this.elements;
		te[0]=1; te[1]=0; te[2]=0; te[3]=0;
		te[4]=0; te[5]=1; te[6]=0; te[7]=0;
		te[8]=0; te[9]=0; te[10]=1; te[11]=0;
		te[12]=0; te[13]=0; te[14]=0; te[15]=1;

	},

	lookAt: function() {

		var x = {x : 0,y:0, z:0};
		var y = {x : 0,y:0, z:0};
		var z = {x : 0,y:0, z:0};

		return function ( camera, target, up ) {

			var te = this.elements;

			MathUtils.subVectors( camera, target, z );
			MathUtils.normalizeVector(z);
			if ( z.length === 0 ) {
				z.z = 1;
			}
			MathUtils.crossVectors( up, z, x );
			// MathUtils.normalizeVector(x);
			// if ( x.length === 0 ) {
			// 	z.x += 0.0001;
			// 	MathUtils.crossVectors( up, z, x );
			// 	MathUtils.normalizeVector(x);
			// }
			MathUtils.crossVectors( z, x, y );

			te[0] = x.x; te[1] = x.y; te[2] = x.z;
			te[4] = y.x; te[5] = y.y; te[6] = y.z;
			te[8] = z.x; te[9] = z.y; te[10] = z.z;

			return this;

		};

	}(),
	
	setPosition : function ( x,y,z ) {
		var te = this.elements;
		te[3] = x;
		te[7] = y;
		te[11] = z;
	},
	translate : function ( x,y,z ) {
		var te = this.elements;
		te[3] += x;
		te[7] += y;
		te[11] += z;
	},
	setRotation : function ( rx,ry,rz ) {
		var te = this.elements;
		te[0]=1; te[1]=0; te[2]=0; // te[3]=0;
		te[4]=0; te[5]=1; te[6]=0; // te[7]=0;
		te[8]=0; te[9]=0; te[10]=1; // te[11]=0;
		// te[12]=0; te[13]=0; te[14]=0; te[15]=1;
		this.rotateX(rx);
		this.rotateY(ry);
		this.rotateZ(rz);
	},
	rotateX: function ( angle ) {

		var c = Math.cos( angle );
		var s = Math.sin( angle );
		var te = this.elements;
		var m12 = te[1];
		var m22 = te[5];
		var m32 = te[9];
		// var m42 = te[13];

		var m13 = te[2];
		var m23 = te[6];
		var m33 = te[10];
		// var m43 = te[14];

		te[1] = c * m12 + s * m13;
		te[5] = c * m22 + s * m23;
		te[9] = c * m32 + s * m33;
		// te[13] = c * m42 + s * m43;

		te[2] = c * m13 - s * m12;
		te[6] = c * m23 - s * m22;
		te[10] = c * m33 - s * m32;
		// te[14] = c * m43 - s * m42;

		return this;

	},

	rotateY: function ( angle ) {

		var c = Math.cos( angle );
		var s = Math.sin( angle );
		var te = this.elements;
		var m11 = te[0];
		var m21 = te[4]; 
		var m31 = te[8];
		// var m41 = te[12];

		var m13 = te[2];
		var m23 = te[6];
		var m33 = te[10];
		// var m43 = te[14];

		te[0] = c * m11 - s * m13;
		te[4] = c * m21 - s * m23;
		te[8] = c * m31 - s * m33;
		// te[12] = c * m41 - s * m43;

		te[2] = c * m13 + s * m11;
		te[6] = c * m23 + s * m21;
		te[10] = c * m33 + s * m31;
		// te[14] = c * m43 + s * m41;

		return this;

	},

	rotateZ: function ( angle ) {

		var c = Math.cos( angle );
		var s = Math.sin( angle );
		var te = this.elements;
		var m11 = te[0];
		var m21 = te[4];
		var m31 = te[8];
		// var m41 = te[12];
		var m12 = te[1];
		var m22 = te[5];
		var m32 = te[9];
		// var m42 = te[13];

		te[0] = c * m11 + s * m12;
		te[4] = c * m21 + s * m22;
		te[8] = c * m31 + s * m32;
		// te[12] = c * m41 + s * m42;

		te[1] = c * m12 - s * m11;
		te[5] = c * m22 - s * m21;
		te[9] = c * m32 - s * m31;
		// te[13] = c * m42 - s * m41;

		return this;

	},
}