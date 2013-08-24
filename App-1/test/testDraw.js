
var Config={
	width : window.innerWidth*window.devicePixelRatio,
	height : window.innerHeight*window.devicePixelRatio,
  FPS : 60
}
console.log(Config.width,Config.height)

if (typeof ejecta!="undefined"){
  var canvas = document.getElementById("canvas");
  canvas.width = Config.width;
  canvas.height = Config.height;

  var context = canvas.getContext("2d");
  ejecta.include("./lib/Utils.js")
  ejecta.include("./lib/Event.js")
}





var game={
    FPS : Config.FPS,
    init : function(){},
    start : function(){

        this.context.strokeStyle="#ffffff";

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
        // for (var key in this.spriteMap){
        //     var s=this.spriteMap[key];
        //     s.update(dt);
        // }
        this.sprites.forEach(function(s){
            s.update(dt);
        });
//        console.log(dt)
    },

    render : function(dt){
        var ctx=this.context;
        ctx.clearRect(0,0,Config.width,Config.height);

        this.sprites.sort(function(a,b){
            return Math.random()-0.5;
        })
        this.sprites.forEach(function(s){
            s.render(ctx);
        });
    }
}

var Res={}
window.onload=function(){
    initCanvas();
    Res.testImg1=new Image();
    Res.testImg2=new Image();
    Res.testImg1.src="./res/safari.png";
    Res.testImg1.onload=function(){
        Res.testImg2.src="./res/face.png";
    };
    Res.testImg2.onload=function(){
        createSprites(game);
        game.init();
        game.start();
    };
}

function Sprite(options){
    for (var p in options){
        this[p]=options[p];
    }
}

Sprite.prototype={
    img : null,
    x : 0,
    y : 0,
    w : 0,
    h : 0,
    ix : 0,
    iy : 0,
    iw : 0,
    ih : 0,

    update : function(tiemStep){
        var dx=randomInt(1,5)/10;
        var dy=randomInt(1,5)/10;
        var x=(this.x+dx)%Config.width;
        var y=(this.y+dy)%Config.height;
        this.x=x;
        this.y=y;

    },

    render : function(context){
        
        context.drawImage(this.img, this.ix,this.iy,this.iw,this.ih,
                 this.x,this.y,this.w,this.h)
    }
}

function createSprites(game){
    var list=game.sprites=[];
    var map=game.spriteMap={};
    for (var i=0;i<800;i++){
        var img=Math.random()<0.5?Res.testImg1:Res.testImg2;
        var iw=img.width, ih=img.height;
        var o=randomInt(-10,10)
        var w=100+o, h=100+o;
        var ix=(iw-w)>>1, iy=(ih-h)>>1;
        var s=new Sprite({
            img : img,
            x : randomInt(-w,Config.width),
            y : randomInt(-h,Config.height),
            ix : ix,
            iy : iy,
            iw : w, 
            ih : h, 
            w : w,
            h : h
        })
        list[i]=s
        map[i]=s
    }

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
