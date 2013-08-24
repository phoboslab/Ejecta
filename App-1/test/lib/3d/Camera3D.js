var Camera3D=function(options){
    for (var key in options){
        this[key]=options[key];
    }
}

;(function(scope,undefined){


var PT = {

    perspective:600,
    width : 400,
    height : 400,

    velocity : 0,

    invertRotate : true,

    init : function(world){

        this.world=world;

        this.perspectiveSq=this.perspective*this.perspective;

        this.up=this.up||{x:0,y:1,z:0};
        this.target=this.target||{x:0,y:0,z:0};
        this.original={
            x : this.x,
            y : this.y,
            z : this.z,
            angleX : this.angleX,
            angleY : this.angleY,
            angleZ : this.angleZ,
            up : {
                x : this.up.x,
                y : this.up.y,
                z : this.up.z
            },
            target : {
                x : this.target.x,
                y : this.target.y,
                z : this.target.z
            }
        };
        this.matrix=new Matrix4();
        this.reset();

        if (this.onInit){
            this.onInit();
        }
    },

    reset : function(){

        this.x=this.original.x;
        this.y=this.original.y;
        this.z=this.original.z;
        this.angleX=this.original.angleX;
        this.angleY=this.original.angleY;
        this.angleZ=this.original.angleZ;
        this.up.x=this.original.up.x;
        this.up.y=this.original.up.y;
        this.up.z=this.original.up.z;
        this.target.x=this.original.target.x;
        this.target.y=this.original.target.y;
        this.target.z=this.original.target.z;

        this.matrix.reset();
        this.setRotation(this.angleX,this.angleY,this.angleZ);
        this.setPosition(this.x,this.y,this.z);
    },

    lookAt : function(vector){
        this.matrix.lookAt( this, vector, this.up );
        this.changed=true;
        this.rotated=true;
    },

    transform : function(vertexs){

        this.checkRotated();

        var Me=this;
        vertexs.forEach(function(vertex){
            var entity=vertex.parent;
            if (Me.changed || entity.changed){
                Me.projectVertex(vertex);
            }
        });
    },

    projectVertex: function ( vertex ) {

        var x = vertex.x-this.x, 
            y = vertex.y-this.y, 
            z = vertex.z-this.z;

        if (this.rotated){
            var te = this.matrix.elements;
            vertex.mx = te[0] * x + te[1] * y + te[2]  * z //+ te[3] ;
            vertex.my = te[4] * x + te[5] * y + te[6]  * z //+ te[7] ;
            vertex.mz = te[8] * x + te[9] * y + te[10] * z //+ te[11] ;                 
        }else{
            vertex.mx=x;
            vertex.my=y;
            vertex.mz=z;
        }

        var dis = vertex.mz;
        vertex.visible=dis < 0;
        if(vertex.visible||vertex.force){
            var scale = -this.perspective / dis;    
            vertex.scale = scale
            vertex.viewX = vertex.mx * scale;
            vertex.viewY = vertex.my * scale;
            vertex.viewZ = vertex.mz;
        }

        return vertex;
    },

    sortByZIndex : function(vertexs){
        vertexs.sort(function(a, b){
            return a.viewZ - b.viewZ || a.index-b.index;
        });
    },

    update : function(timeStep){

    }

};

    for (var key in Entity3D.prototype){
        Camera3D.prototype[key]=Entity3D.prototype[key];
    }
    for (var key in PT){
        Camera3D.prototype[key]=PT[key];
    }

}(this));


