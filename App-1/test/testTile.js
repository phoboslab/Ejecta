var Config = {
    width: window.innerWidth * window.devicePixelRatio,
    height: window.innerHeight * window.devicePixelRatio,
    FPS: 60
}
console.log(Config.width, Config.height)

if (typeof ejecta != "undefined") {
    var canvas = document.getElementById("canvas");
    canvas.width = Config.width;
    canvas.height = Config.height;

    var context = canvas.getContext("2d");
    ejecta.include("./lib/Utils.js")
    ejecta.include("./lib/Event.js")
}



var game = {
    FPS: Config.FPS,
    init: function() {},
    start: function() {

        this.context.strokeStyle = "#ffffff";

        this.timeStep = 1000 / this.FPS;
        this.last = 9E20;
        var Me = this;
        this.callRun = function() {
            Me.run();
        };
        this.callRun();
    },

    run: function() {
        setTimeout(this.callRun, this.timeStep);
        var now = Date.now();
        var dt = now - this.last;
        this.last = now;
        if (dt < 2) {
            return;
        }
        this.input(dt);
        this.update(dt);
        this.render(dt);
    },
    input: function(dt) {

    },


    update: function(dt) {


    },

    render: function(dt) {
        var ctx = this.context;
        // ctx.clearRect(0, 0, Config.width, Config.height);
        ctx.fillStyle="#ff0000";
        ctx.fillRect(0, 0, Config.width, Config.height);
        renderOuter(ctx);

        this.render=function(){}
    }
}

function renderOuter(context) {
    var vx=200;
    var vy=0;
    
    var bgWidth = 3312;
    var bgHeight = 2744;
    
    var bgWidth = 3200;
    var bgHeight = 2560;
    

    var scale=3;

    var x = 0;
    var y = 0;
    var w = bgWidth / 2;
    var h = bgHeight / 2;

    var w=640,
        h=512;

    var bx = vx - w,
        by = vy - 0;

    // w *= scale;
    // h *= scale;
    // bx *= scale;
    // by *= scale;

    // 
    // bx = Math.floor(bx);
    // by = Math.floor(by);
    // w = Math.floor(w);
    // h = Math.floor(h);

    var fw=Math.ceil(w),
        fh=Math.ceil(h);

    context.save();
    context.scale(scale,scale);
    x = bx;
    y = by;
    context.drawImage(Res.testImg1,0,0,640-0.5,512, Math.floor(x), y, fw,fh);

    x = bx + w;
    y = by;
    context.drawImage(Res.testImg2, 0,0,640-0.5,512, Math.floor(x), y, fw,fh);

    x = bx;
    y = by + h;
    context.drawImage(Res.testImg3, 0,0,640-0.5,512, Math.floor(x), y, fw,fh);

    x = bx + w;
    y = by + h;
    context.drawImage(Res.testImg4, 0,0,640-0.5,512, Math.floor(x), y, fw,fh);

    context.restore();
}

var Res = {}
window.onload = function() {
    initCanvas();
    Res.testImg1 = new Image();
    Res.testImg2 = new Image();
    Res.testImg3 = new Image();
    Res.testImg4 = new Image();

    Res.testImg1.src = "./res/bg_outer_0_0.png";
    Res.testImg1.onload = function() {
        Res.testImg2.src = "./res/bg_outer_1_0.png";
    };
    Res.testImg2.onload = function() {
        Res.testImg3.src = "./res/bg_outer_0_1.png";
    };
    Res.testImg3.onload = function() {
        Res.testImg4.src = "./res/bg_outer_1_1.png";
    };
    Res.testImg4.onload = function() {
        game.init();
        game.start();
    };
}


function initCanvas() {
    var c = game.canvas = $id("canvas");
    c.width = Config.width;
    c.height = Config.height;
    var ctx = game.context = c.getContext("2d");
//    ctx.imageSmoothingEnabled=false;
}

if (typeof ejecta != "undefined") {
    window.onload();
}

