var width = window.innerWidth;
var height = window.innerHeight;
var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;

ejecta.include('vendor/three.js');
ejecta.include('threedemo/BinaryLoader.js');
ejecta.include('threedemo/Detector.js');
// ejecta.include('threedemo/stats.js');
var renderer = new THREE.WebGLRenderer({
  canvas: canvas
});
renderer.setSize(width, height);

if ( ! Detector.webgl ) Detector.addGetWebGLMessage();

var container, stats;

var camera, scene, renderer;
var cameraCube, sceneCube;

var mesh, geometry;

var loader;

var pointLight;

var mouseX = 0;
var mouseY = 0;

var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

document.addEventListener('mousemove', onDocumentMouseMove, false);

init();
animate();

function init() {

  // container = document.createElement( 'div' );
  // document.body.appendChild( container );

  camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 5000 );
  camera.position.z = 2000;

  cameraCube = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 100 );

  scene = new THREE.Scene();
  sceneCube = new THREE.Scene();

  // LIGHTS

  var ambient = new THREE.AmbientLight( 0xffffff );
  scene.add( ambient );

  pointLight = new THREE.PointLight( 0xffffff, 2 );
  scene.add( pointLight );

  // light representation

  var sphere = new THREE.SphereGeometry( 100, 16, 8 );

  var mesh = new THREE.Mesh( sphere, new THREE.MeshBasicMaterial( { color: 0xffaa00 } ) );
  mesh.scale.set( 0.05, 0.05, 0.05 );
  pointLight.add( mesh );

  var path = "threedemo/";
  var format = '.jpg';
  var urls = [
      path + 'px' + format, path + 'nx' + format,
      path + 'py' + format, path + 'ny' + format,
      path + 'pz' + format, path + 'nz' + format
    ];

  var reflectionCube = THREE.ImageUtils.loadTextureCube( urls );
  reflectionCube.format = THREE.RGBFormat;

  var refractionCube = new THREE.CubeTexture( reflectionCube.image, THREE.CubeRefractionMapping );
  refractionCube.format = THREE.RGBFormat;

  //var cubeMaterial3 = new THREE.MeshPhongMaterial( { color: 0x000000, specular:0xaa0000, envMap: reflectionCube, combine: THREE.MixOperation, reflectivity: 0.25 } );
  var cubeMaterial3 = new THREE.MeshLambertMaterial( { color: 0xff6600, envMap: reflectionCube, combine: THREE.MixOperation, reflectivity: 0.3 } );
  var cubeMaterial2 = new THREE.MeshLambertMaterial( { color: 0xffee00, envMap: refractionCube, refractionRatio: 0.95 } );
  var cubeMaterial1 = new THREE.MeshLambertMaterial( { color: 0xffffff, envMap: reflectionCube } )

  // Skybox

  var shader = THREE.ShaderLib[ "cube" ];
  shader.uniforms[ "tCube" ].value = reflectionCube;

  var material = new THREE.ShaderMaterial( {

    fragmentShader: shader.fragmentShader,
    vertexShader: shader.vertexShader,
    uniforms: shader.uniforms,
    depthWrite: false,
    side: THREE.BackSide

  } ),

  mesh = new THREE.Mesh( new THREE.BoxGeometry( 100, 100, 100 ), material );
  sceneCube.add( mesh );

  //

  // renderer = new THREE.WebGLRenderer();
  renderer.setPixelRatio( window.devicePixelRatio );
  renderer.setSize( window.innerWidth, window.innerHeight );
  renderer.autoClear = false;
  // container.appendChild( renderer.domElement );

  //

  // stats = new Stats();
  // stats.domElement.style.position = 'absolute';
  // stats.domElement.style.top = '0px';
  // stats.domElement.style.zIndex = 100;
  // container.appendChild( stats.domElement );

  //

  loader = new THREE.BinaryLoader( true );
  document.body.appendChild( loader.statusDomElement );

  loader.load( "threedemo/WaltHead_bin.js", function( geometry ) { createScene( geometry, cubeMaterial1, cubeMaterial2, cubeMaterial3 ) } );

  //

  window.addEventListener( 'resize', onWindowResize, false );

}

function onWindowResize() {

  windowHalfX = window.innerWidth / 2;
  windowHalfY = window.innerHeight / 2;

  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  cameraCube.aspect = window.innerWidth / window.innerHeight;
  cameraCube.updateProjectionMatrix();

  renderer.setSize( window.innerWidth, window.innerHeight );

}

function createScene( geometry, m1, m2, m3 ) {

  var s = 15;

  var mesh = new THREE.Mesh( geometry, m1 );
  mesh.position.z = - 100;
  mesh.scale.x = mesh.scale.y = mesh.scale.z = s;
  scene.add( mesh );

  var mesh = new THREE.Mesh( geometry, m2 );
  mesh.position.x = - 900;
  mesh.position.z = - 100;
  mesh.scale.x = mesh.scale.y = mesh.scale.z = s;
  scene.add( mesh );

  var mesh = new THREE.Mesh( geometry, m3 );
  mesh.position.x = 900;
  mesh.position.z = - 100;
  mesh.scale.x = mesh.scale.y = mesh.scale.z = s;
  scene.add( mesh );

  loader.statusDomElement.style.display = "none";

}

function onDocumentMouseMove(event) {

  mouseX = ( event.clientX - windowHalfX ) * 4;
  mouseY = ( event.clientY - windowHalfY ) * 4;

}

//

function animate() {

  requestAnimationFrame( animate );

  render();
  // stats.update();

}

function render() {

  var timer = -0.0002 * Date.now();

  pointLight.position.x = 1500 * Math.cos( timer );
  pointLight.position.z = 1500 * Math.sin( timer );

  camera.position.x += ( mouseX - camera.position.x ) * .05;
  camera.position.y += ( - mouseY - camera.position.y ) * .05;

  camera.lookAt( scene.position );
  cameraCube.rotation.copy( camera.rotation );

  renderer.render( sceneCube, cameraCube );
  renderer.render( scene, camera );

}
