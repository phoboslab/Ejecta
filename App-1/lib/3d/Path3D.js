
var Path3D=function(options){
	for (var key in options){
		this[key]=options[key];
	}
}

Path3D.prototype={ 

    setPoints : function(points){
        this.points=[];
        var len=points.length;
        var point=points[0];
        point.index=0;

        console.log(point)

        
        this.points.push(point);
        for (var i=1;i<len;i++){
            point.hasNext=true;
            var next=points[i];
            next.index=i;
            var dx=next.x-point.x ,
                dy=next.y-point.y ,
                dz=next.z-point.z ;
            dx=dx;
            dy=dy;
            dz=dz;
            var length=Math.sqrt(dx*dx+dy*dy+dz*dz);
            point.nx=dx/length;
            point.ny=dy/length;
            point.nz=dz/length;

            // var radX=Math.atan2( dz , dy );
            // var radY=Math.atan2( dx , dz );
            // var radZ=Math.atan2( dy , dx );

var productValueZ = (dx * 0) + (dy * 1);  // 向量的乘积
var lengthZ = Math.sqrt(dx*dx+dy*dy);  // 向量a的模
var cosZ = productValueZ / lengthZ;

var productValueY = (dz * 0) + (dx * 1);  // 向量的乘积
var lengthY = Math.sqrt(dz*dz+dx*dx);  // 向量a的模
var cosY = productValueY / lengthY;

var productValueX = (dy * 0) + (dz * (-1));  // 向量的乘积
var lengthX = Math.sqrt(dy*dy+dz*dz);  // 向量a的模
var cosX = productValueX / lengthX;



var radX=Math.acos( cosX )||0
var radY=Math.acos( cosY )||0
var radZ=-Math.acos( cosZ )||0

            point.radX=radX;
            point.degX=radX*RAD_TO_DEG;
            point.cosX=Math.cos(radX);
            point.sinX=Math.sin(radX);

            point.radY=radY;
            point.degY=radY*RAD_TO_DEG;
            point.cosY=Math.cos(radY);
            point.sinY=Math.sin(radY);

            point.radZ=radZ;
            point.degZ=radZ*RAD_TO_DEG;
            point.cosZ=Math.cos(radZ);
            point.sinZ=Math.sin(radZ);

            this.points.push(next);

            point=next;
        }
        console.log(this.points);
        point.hasNext=false;
        console.log("===============")
    },

    update : function(entity){

        var currentPoint=this.points[entity.targetIndex];

        if (!currentPoint){
            return false;
        }

        var dx=currentPoint.x-entity.x,
            dy=currentPoint.y-entity.y,
            dz=currentPoint.z-entity.z ;
        
        if (dx*entity.dx >=0){
            if (Math.abs(entity.dx)>=Math.abs(dx) ){
                entity.dx=0;//dx;
                entity.vx=0;
                entity.x=currentPoint.x;
            }
        }
        //
        if (dy*entity.dy >=0){
            if (Math.abs(entity.dy)>=Math.abs(dy) ){
                entity.dy=0;//dy;
                entity.vy=0;
                entity.y=currentPoint.y;
            }
        }
        // console.log(dz,entity.dz)
        if (dz*entity.dz >=0){
            if (Math.abs(entity.dz)>=Math.abs(dz) ){
                entity.dz=0;//dz;
                entity.vz=0;
                entity.z=currentPoint.z;
            }
        }
        if (!entity.vx && !entity.vy && !entity.vz){
            this.gotoNext(entity);
        }else{

        }
        return true;
    },
    gotoNext : function(entity){
        var currentPoint=this.points[entity.targetIndex];
        if (currentPoint.hasNext){
            entity.targetIndex++;
            entity.nx=currentPoint.nx;
            entity.ny=currentPoint.ny;
            entity.nz=currentPoint.nz;

            entity.vx=entity.velocity*currentPoint.nx;
            entity.vy=entity.velocity*currentPoint.ny;
            entity.vz=entity.velocity*currentPoint.nz;
            entity.radX=currentPoint.radX;
            entity.radY=currentPoint.radY;
            entity.radZ=currentPoint.radZ;
            return true;
        }else{
            entity.targetIndex=null;
            entity.vx=0;
            entity.vy=0;
            entity.vz=0;
            return false;
        }
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

