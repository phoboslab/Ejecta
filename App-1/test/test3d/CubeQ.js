


var CubeQ =function(cfg){
    for (var key in cfg) {
        this[key] = cfg[key];
    }
    this.vertexs=[];
};


(function(scope,undefined){


var PT = {

    x : 0,
    y : 0,
    z : 0,
    w : 100,
    h : 100,
    d : 100,
    length : 1,

    initVertexs : function(){
        this.line=Res.line;
        this.iX=0;
        this.iY=0;
        this.iW=this.line.width;
        this.iH=this.line.height;

        this.preD=this.preD||this.d;
        this.length=this.length||1;
        this.d=this.preD*this.length;
        var d=this.preD;
        var halfW=this.w/2,
            halfH=this.h/2,
            halfD=this.d/2;
        this.vertexs=[]
        var x,y,z=halfD;
        for (var i=0;i<=this.length;i++){
            x=-halfW; y=-halfH;
            this.vertexs.push({x:x,y:y,z:z});
            x=halfW; y=-halfH;
            this.vertexs.push({x:x,y:y,z:z});
            x=halfW; y=halfH;
            this.vertexs.push({x:x,y:y,z:z});
            x=-halfW; y=halfH;
            this.vertexs.push({x:x,y:y,z:z});
            z-=this.preD;
        }
        this.maxZ=this.z+halfD;

        for (var i=0;i<this.vertexs.length;i++){
            var v=this.vertexs[i];
            v.ox=v.x;
            v.oy=v.y;
            v.oz=v.z;
            v.index=i+1;
            v.visible=true;
            v.force=true;
            v.parent=this;
            var star=new Star(v);
            star.init(this);
            this.vertexs[i]=star;
        }
        this.changed=true;
    },

    update : function(timeStep){
        // this.translate(1,0,0)
        var dy=this.vy*timeStep;
        
        if (this.y+dy<Config.height){
            this.translate(0,dy,0);
        }else{
            this.setPosition(this.x,-Config.height,this.z);
        }

        var dr=0.001*timeStep
        this.rotateX(dr);
        this.rotateY(dr);
        this.rotateZ(dr);

        this.transform();
    },
    
    renderVertex : function(vertex,context){
       

    },
    drawLine : function(context,x1,y1,z1,x2,y2,z2){
        if (z1>=0 || z2>=0){
            return false;
        }
        var dx=x2-x1,
            dy=y2-y1;
        var angle=Math.atan2(dy,dx);

        var h=this.iH>>2;
        var ww=6;
        var length=Math.sqrt(dx*dx+dy*dy)+ww;
        var a=-((z1+z2)/2);
            // console.log(a)
            // console.log(-(z1+z2)/2)
        if (a-camera.perspective<0){
            a=1
        }else{
            a=camera.perspective/a;
            a*=a;
        }
        a=1;
        // console.log(a)
        context.save();
        context.globalAlpha=a;
        context.translate(x1,y1);
        context.rotate(angle);
        context.drawImage(this.line,this.iX,this.iY,this.iW,this.iH,
                -ww>>1, -h>>1,length,h
            );
        context.restore();

    },

    renderLine : function(context){
        var v, s=0;

        for (var i=0;i<=this.length;i++){
            v=this.vertexs[s];
            for (var j=0;j<3;j++){
                var nextV=this.vertexs[++s];
                this.drawLine(context,v.viewX,v.viewY,v.viewZ,nextV.viewX,nextV.viewY,nextV.viewZ);
                v=nextV;
            }
            nextV=this.vertexs[s-3];
            this.drawLine(context,v.viewX,v.viewY,v.viewZ,nextV.viewX,nextV.viewY,nextV.viewZ);            
            s++;
        }

        var vlen=this.vertexs.length;
        for (var i=0;i<4;i++){
            var v=this.vertexs[i];
            var s=i;
            while (v.viewZ>=0){
                s+=4;
                v=this.vertexs[s];
            }
            var nextV=this.vertexs[vlen-4+i];
            this.drawLine(context,v.viewX,v.viewY,v.viewZ,nextV.viewX,nextV.viewY,nextV.viewZ);
        }

        // this.renderLine=noop;
    },
    render : function(context){

    }
}

    for (var key in Entity3D.prototype){
        CubeQ.prototype[key]=Entity3D.prototype[key];
    }
    for (var key in PT){
        CubeQ.prototype[key]=PT[key];
    }

}(this));