// "use strict";
var width, height;
var canvas;

if (window.ejecta) {

    // relative to index.js .
    var relativePath = "example/bunnymark/";

    width = window.innerWidth // * window.devicePixelRatio;
    height = window.innerHeight // * window.devicePixelRatio;
    canvas = document.getElementById('canvas');
    canvas.width = width;
    canvas.height = height;
    canvas.style.width = window.innerWidth + "px";
    canvas.style.height = window.innerHeight + "px";

    console.log("screen canvas : ", width, height);

    window.resImagePath = relativePath + "";
    ejecta.include(relativePath + "pixi.min.js");

    setTimeout(function() {
        onReady();
    }, 100);
}



var useWebGL = true;
var multiTexture = false;

var maxBunnyCount = 1000 * 200;
// var startBunnyCount = 10;
var startBunnyCount = 1000 * 20;


var particleMaxSize = 2500 * 1;
var particleBatchSize = 2500 * 1;

var bunnies = [];
var bunnyTextures;
var bunnyTextureIndex;
var currentTexture;

var gravity = 0.75 //1.5 ;

var isAdding = 0;
var addingGap = 35;
var amount = 100;

var bunnyCount = 0;
var container;
var stats, counter;
var renderer;


width = width || 640;
height = height || 960;
var aspectRatio = width / height;
var minX, maxX;
var minY, maxY;
var screenWidth, screenHeight;

function onReady() {
    console.log("ready");

    doResize();

    canvas = canvas || document.getElementById("canvas");
    canvas.style.transform = "translatez(0)";
    canvas.style.position = "absolute";


    if (typeof Stats != "undefined") {
        stats = new Stats();
        stats.domElement.style.position = "absolute";
        stats.domElement.style.top = "0px";
        document.body.appendChild(stats.domElement);

        counter = document.createElement("div");
        counter.className = "counter";
        document.body.appendChild(counter);
    }

    doReLocation();


    if ("ontouchstart" in window) {
        window.addEventListener("touchstart", onTouchStart, true);
        window.addEventListener("touchend", onTouchEnd, true);
    } else {
        window.addEventListener("mousedown", onTouchStart, true);
        window.addEventListener("mouseup", onTouchEnd, true);
    }


    // return;
    var options = { view: canvas, backgroundColor: 0xFFFFFF };

    if (useWebGL) {
        renderer = new PIXI.WebGLRenderer(width, height, options);
    } else if (useWebGL === false) {
        renderer = new PIXI.CanvasRenderer(width, height, options);
    } else {
        renderer = new PIXI.autoDetectRenderer(width, height, options);
    }

    createContainer();

    initBunnyTextures();

    bunnyTextureIndex = -1;

    nextTexture();

    addMoreBunnies(startBunnyCount);

    requestAnimationFrame(update);

}

function initBunnyTextures() {

    bunnyTextures = [];

    var textures = [
        new PIXI.Texture.fromImage(window.resImagePath + "bunnies-1.png"),
        new PIXI.Texture.fromImage(window.resImagePath + "bunnies-2.png"),
        new PIXI.Texture.fromImage(window.resImagePath + "bunnies-3.png"),
    ];

    var textureCount = 1;
    if (multiTexture) {
        textureCount = textures.length;
    }

    var rects = [];
    for (var i = 0; i < textureCount; i++) {
        var baseTexture = textures[i].baseTexture;
        // console.log(baseTexture.imageUrl);
        rects.push(new PIXI.Texture(baseTexture, new PIXI.Rectangle(0, 0, 30, 46)));
        rects.push(new PIXI.Texture(baseTexture, new PIXI.Rectangle(0, 46 + 39 * 0, 30, 39)));
        rects.push(new PIXI.Texture(baseTexture, new PIXI.Rectangle(0, 46 + 39 * 1, 30, 39)));
        rects.push(new PIXI.Texture(baseTexture, new PIXI.Rectangle(0, 46 + 39 * 2, 30, 39)));
        rects.push(new PIXI.Texture(baseTexture, new PIXI.Rectangle(0, 46 + 39 * 3, 30, 39)));
    }

    var count = rects.length * 3;
    for (var i = 0; i < count; i++) {
        bunnyTextures.push(rects[i % rects.length]);
    }

}

var pressed = false;

function onTouchStart(event) {
    isAdding = 0;
    pressed = true;
}

function onTouchEnd(event) {

    if (isAdding !== -1) {
        // nextTexture();
        addMoreBunnies(amount);
    }
    pressed = false;
}

function resize() {
    setTimeout(function() {
        doResize();
        doReLocation();

        renderer.resize(width, height);
    }, 10);
}

function doResize() {

    screenWidth = window.innerWidth;
    screenHeight = window.innerHeight;

    if (screenWidth / screenHeight >= aspectRatio) {
        height = screenHeight;
        width = height * aspectRatio;
    } else if (screenWidth / screenHeight < aspectRatio) {
        width = screenWidth;
        height = width / aspectRatio;
    }

    maxX = width;
    minX = 0;
    maxY = height - 10;
    minY = 0;

}

function doReLocation() {

    var w = screenWidth / 2 - width / 2;
    var h = screenHeight / 2 - height / 2;

    canvas.style.left = w + "px"
    canvas.style.top = h + "px"

    if (stats) {
        stats.domElement.style.left = w + "px";
        stats.domElement.style.top = h + "px";

        counter.style.left = w + "px";
        counter.style.top = h + 40 + "px";
    }

}


function nextTexture() {
    bunnyTextureIndex = (bunnyTextureIndex + 1) % bunnyTextures.length;
    currentTexture = bunnyTextures[bunnyTextureIndex];
}

function update() {
    stats && stats.begin();

    if (pressed) {
        isAdding++;
    }
    if (isAdding >= addingGap) {
        addMoreBunnies(amount);
        isAdding = -1;
    }

    for (var i = 0, len = bunnies.length; i < len; i++) {
        var bunny = bunnies[i];
        bunny.rotation += bunny.speedR;
        var x = bunny.position.x += bunny.speedX;
        var y = bunny.position.y += bunny.speedY;
        bunny.speedY += gravity;

        if (x > maxX) {
            bunny.speedX *= -1;
            bunny.position.x = maxX;
        } else if (x < minX) {
            bunny.speedX *= -1;
            bunny.position.x = minX;
        }

        if (y > maxY) {
            bunny.speedY *= -0.85;
            bunny.position.y = maxY;
            bunny.spin = (Math.random() - 0.5) * 0.2
            if (Math.random() > 0.5) {
                bunny.speedY -= Math.random() * 6;
            }
        } else if (y < minY) {
            bunny.speedY = 0;
            bunny.position.y = minY;
        }

    }

    renderer.render(container);
    requestAnimationFrame(update);

    stats && stats.end();
}


function addMoreBunnies(count) {
    var i = 0;
    while (bunnyCount < maxBunnyCount && i < count) {
        var bunny = createBunny(currentTexture);

        bunnies.push(bunny);
        //bunny.rotation = Math.random() - 0.5;
        container.addChild(bunny);
        // var random = randomInt(0, container.children.length - 2);
        // container.addChildAt(bunny, random);

        nextTexture();

        i++;
        bunnyCount++;
    }
    if (counter) {
        counter.innerHTML = bunnyCount + " BUNNIES";
    }
}


function createBunny(currentTexture) {
    var bunny = new PIXI.Sprite(currentTexture);

    bunny.anchor.x = 0.5;
    bunny.anchor.y = 1;
    bunny.scale.set(0.5 + Math.random() * 0.5);
    bunny.rotation = (Math.random() - 0.5);
    //bunny.alpha = 0.3 + Math.random() * 0.7;
    bunny.speedX = Math.random() * 5;
    bunny.speedY = (Math.random() * 6) - 4;
    bunny.speedR = ((1 + Math.random() * 10) >> 0) / 50;

    return bunny;
}


function createContainer() {

    var options = {
        position: true,
        rotation: true,
        scale: true,

        alpha: true,
        uvs: true,
    };

    container = new PIXI.particles.ParticleContainer(particleMaxSize, options, particleBatchSize);
    // container = new PIXI.Container();

    if (!useWebGL) {
        container = new PIXI.Container();
    }

}



/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////


function randomInt(from, to) {
    return Math.floor(Math.random() * (to - from + 1) + from);
}

window.resImagePath = window.resImagePath || "";
window.onload = function() {
    onReady();
};
window.onresize = function() {
    resize();
};
window.onorientationchange = function() {
    resize();
};
