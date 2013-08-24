
var Config={
	width : window.innerWidth,
	height : window.innerHeight,
  FPS : 60
}


if (typeof ejecta!="undefined"){
  var canvas = document.getElementById("canvas");
  canvas.width = Config.width;
  canvas.height = Config.height;

  var context = canvas.getContext("2d");
  ejecta.include("./lib/Utils.js")
  ejecta.include("./lib/Event.js")
  ejecta.include("./lib/3d/MathUtils.js")
  ejecta.include("./lib/3d/Matrix4.js")
  ejecta.include("./lib/3d/Entity3D.js")
  ejecta.include("./lib/3d/Camera3D.js")
  ejecta.include("./lib/3d/World3D.js")
  ejecta.include("./lib/3d/Path3D.js")

  ejecta.include("./test3d/Star.js")
  ejecta.include("./test3d/CubeQ.js")
}




var camera=new Camera3D({
    x : 0,
    y : 0,
    z : 800,
    dx : 0,
    dy : 0,
    dz : 0,
    vx : 0,
    vy : 0,
    vz : 0,
    perspective:800,
    velocity : 0.03,
    targetIndex : 0,
    update : function(timeStep){
        // this.rotateX(0.005);
        // this.rotateY(0.005);
        // this.rotateZ(0.005);
        // this.target.x+=1;
        // this.lookAt(this.target);
        if (!window.rrr){
            window.rrr=1
            // this.rotateX(Math.PI/2);
            // this.rotateY(Math.PI/2);
        }
        // this.rotateZ(0.005);
        // this.translate(0,0,1);
    }
});
var path=new Path3D();

var world=new World3D({
    offset : {
        x : Config.width/2,
        y : Config.height/2,
        z : 0
    },
    camera : camera,
    cleanArray : function(){
        var list=this.vertexs;
        var last=list.length-1;
        for (var i = last ; i >=0; i--) {
            if (list[i].disabled) {
                list[i]=list[last];
                last--;
            }
        }
        list.length=last+1;
        return list;
    },
    renderVertexs : function(context){
        game.cubeQs.forEach(function(c){
            c.renderLine(context);
        });
        if (this.vertexs.length>0){
            // this.vertexs.forEach(function(vertex){
                // vertex.render(context);
                // context.strokeRect(vertex.viewX,vertex.viewY,12*vertex.scale,12*vertex.scale);
            // });
        }
    }
});

camera.init(world);
world.init();


var game={
    FPS : Config.FPS,
    init : function(){},
    start : function(){

        this.context.strokeStyle="#ffffff";

        this.cubeQs=createCubeQs();

        this.timeStep=1000/this.FPS;
        this.last=9E20;
        var Me=this;
        this.callRun=function(){
            Me.run();
        };
        this.callRun();
    },

    run : function(){
        setTimeout(this.callRun,this.timeStep);
        var now=Date.now();
        var dt=now-this.last;
        this.last=now;
        if (dt<2){return;}
        this.input(dt);
        this.update(dt);
        this.render(dt);
    },
    input : function(dt){

    },


    update : function(dt){
        camera.update(dt);
        this.cubeQs.forEach(function(c){
            c.update(dt);
        })
        world.update(dt);
    },
    render : function(dt){
        var ctx=this.context;
        ctx.clearRect(0,0,Config.width,Config.height);
        world.render(ctx);
    }
}

var Res={}
window.onload=function(){
    initCanvas();
    Res.line=new Image();
    Res.line.src="./test3d/res/line.png";
    Res.line.onload=function(){
        Res.star.src="./test3d/res/star.png";
    }
    Res.star=new Image();
    Res.star.onload=function(){
        game.init();
        game.start();
    };
}

function createCubeQs(){
    var cubeQs=[];
    var num=20;
    var side=50;
    var xs=Math.floor( Config.width/side );

    for (var i=0;i<num;i++){
        var side=randomInt(5,10)*10;
        var cubeQ=new CubeQ({
            index : i,
            x : randomInt(-Config.width/2,Config.width/2),
            y : randomInt(-Config.height,0),
            z : 0,
            preD : side*1.5,
            vy : randomInt(5,15)/100,
            length : 2,
            // angleX : 1,
            // x : randomInt(-3,3)*110||50,
            // y : randomInt(-3,3)*110||50,
            // z : randomInt(-10,2)*110||50,
            w : side,
            h : side,
            d : side,
        });
        cubeQ.init(world);
        cubeQs.push(cubeQ)
    }
    return cubeQs;
}


function initCanvas(){
    var c=game.canvas=$id("canvas");
    c.width=Config.width;
    c.height=Config.height;
    var ctx=game.context=c.getContext("2d");
}

if (typeof ejecta!="undefined"){
  window.onload();
}
