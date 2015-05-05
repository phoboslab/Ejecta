var width = window.innerWidth;
var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;

ejecta.include('vendor/pixi.js');
var renderer = new PIXI.CanvasRenderer(width, height, {
  view: canvas
});

// document.body.appendChild(renderer.view);

var stage = new PIXI.Container();

var bunnyTexture = PIXI.Texture.fromImage("pixidemo1/bunny.png");
var bunny = new PIXI.Sprite(bunnyTexture);

bunny.position.x = 400;
bunny.position.y = 300;

bunny.scale.x = 2;
bunny.scale.y = 2;

stage.addChild(bunny);

requestAnimationFrame(animate);

function animate() {
    bunny.rotation += 0.01;

    renderer.render(stage);

    requestAnimationFrame(animate);
}
