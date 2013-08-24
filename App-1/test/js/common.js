

var Classes={};

var SceneConfig={

};


function registerScene(index,cfg){
	SceneConfig[index]=cfg;
}

function createScene(index){
	var cfg=SceneConfig[index];
	if (cfg){
		cfg=cloneSimple(cfg);
		var scene=newInstance(cfg,Scene);
		return scene;
	}
	return null;
}

function registerClass( classId, classDef ){
	Classes[classId]=classDef;
}

function newInstance(cfg,defaultClass){
	var classId=cfg.classId;
	var _class=Classes[classId]||defaultClass;
	return new _class(cfg);
}


function checkBoxCollide( box1, box2){
	return  box1.x1<box2.x2
			&& box1.x2>box2.x1
			&& box1.y1<box2.y2 
			&& box1.y2>box2.y1 ;
}

function createRect(w,h,color,borderColor){
	var canvas=document.createElement("canvas");
	canvas.width=w;
	canvas.height=h;
	var ctx=canvas.getContext("2d");
	ctx.fillStyle=color||"#eeeeee";
	ctx.strokeStyle=borderColor||"#333333";
	ctx.fillRect(0,0,w,h);
	ctx.strokeRect(0,0,w,h);
	return canvas;
}


	ResourcePool.add("cloud1", createRect(100,100,"#000"));
	ResourcePool.add("cloud2", createRect(100,100,"#000"));
	ResourcePool.add("cloud3", createRect(100,100,"#000"));
	ResourcePool.add("cloud4", createRect(100,100,"#000"));
	ResourcePool.add("cloud5", createRect(100,100,"#000"));
	ResourcePool.add("cloud6", createRect(100,100,"#000"));
