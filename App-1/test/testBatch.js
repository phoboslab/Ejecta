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

}
var Res={}
window.onload=function(){

    Res.testImg1=new Image();
    Res.testImg2=new Image();
    Res.testImg1.src="./res/safari.png";
    Res.testImg1.onload=function(){
        Res.testImg2.src="./res/face.png";
    };
    Res.testImg2.onload=function(){

       start()
    };
}
if (typeof ejecta!="undefined"){
    window.onload();
}
var bc=new Ejecta.BatchContext2D();

function start(){
    
    context.drawImage(Res.testImg1,100,100,100,100,0,0,100,100);
    context.drawImage(Res.testImg2,110,110,100,100,0+10,0+10,100,100);
    
    test1();
    test2();
    test1();
    test2();
    test1();
    test2();
    
}

function test1(){  
    context.clearRect(0,0,Config.width,Config.height);
    
    var s=Date.now();
    for (var i=0;i<2000;i++){
//        var x=(i*8)%Config.width;
//        var y=(i*8)%Config.height;
        context.drawImage(Res.testImg1,100,100,100,100,11,12,100,100);
//        context.drawImage(Res.testImg2,110,110,100,100,11,12,100,100);
    }
    console.log("1---",Date.now()-s);

}

function test2(){
    context.clearRect(0,0,Config.width,Config.height)
    var args=[context];
     
     var idx=1;
    for (var i=0;i<2000;i++){
//        var x=(i*8)%Config.width;
//        var y=(i*8)%Config.height;
       
        args.push(Res.testImg1);
        args.push(100);
        args.push(100);
        args.push(100);
        args.push(100);
        args.push(11);
        args.push(12);
        args.push(100);
        args.push(100);
//
//        args.push(Res.testImg2););
//        args.push(110););
//        args.push(110);
//        args.push(100);
//        args.push(100);
//        args.push(x+10);
//        args.push(y+10);
//        args.push(100);
//        args.push(100);
        
    }
    
    var s=Date.now();
    bc.drawImageBatch.apply(bc,args);
    console.log("2---",Date.now()-s);

}



