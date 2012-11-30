
ejecta.require('lib/glMatrix.js');

// Load the shaders
ejecta.require('shader.fp');
ejecta.require('shader.vp');

var gl;
function initGL(canvas) {
    try {
        gl = canvas.getContext("experimental-webgl");
        gl.viewportWidth = canvas.width;
        gl.viewportHeight = canvas.height;
    } catch (e) {
        console.log(e.message);
    }
    if (!gl) {
        console.log("Could not initialise WebGL, sorry :-(");
    }
}


function getShader(gl, id) {
    var shaderScript = document.getElementById(id);
    if (!shaderScript) {
        return null;
    }
    
    var str = "";
    var k = shaderScript.firstChild;
    while (k) {
        if (k.nodeType == 3) {
            str += k.textContent;
        }
        k = k.nextSibling;
    }
    
    console.log("Got Shader source: " + str);
    
    var shader;
    if (shaderScript.type == "x-shader/x-fragment") {
        shader = gl.createShader(gl.FRAGMENT_SHADER);
    } else if (shaderScript.type == "x-shader/x-vertex") {
        shader = gl.createShader(gl.VERTEX_SHADER);
    } else {
        return null;
    }
    
    gl.shaderSource(shader, str);
    gl.compileShader(shader);
    
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.log(type + " Shader error: " + gl.getShaderInfoLog(shader));
        return null;
    }
    
    return shader;
}

var shaderProgram;

function initShaders() {
    var fragmentShader = getShader(gl, "shader-fp");
    var vertexShader = getShader(gl, "shader-vp");
    
    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);
    
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        console.log("Program link error: " + gl.getProgramInfoLog(shaderProgram));
        return null;
    }
    
    gl.useProgram(shaderProgram);
    
    shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
    gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);
    
    shaderProgram.vertexNormalAttribute = gl.getAttribLocation(shaderProgram, "aVertexNormal");
    gl.enableVertexAttribArray(shaderProgram.vertexNormalAttribute);
    
    shaderProgram.textureCoordAttribute = gl.getAttribLocation(shaderProgram, "aTextureCoord");
    gl.enableVertexAttribArray(shaderProgram.textureCoordAttribute);
    
    shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix");
    shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix");
    shaderProgram.nMatrixUniform = gl.getUniformLocation(shaderProgram, "uNMatrix");
    shaderProgram.samplerUniform = gl.getUniformLocation(shaderProgram, "uSampler");
    shaderProgram.useLightingUniform = gl.getUniformLocation(shaderProgram, "uUseLighting");
    shaderProgram.ambientColorUniform = gl.getUniformLocation(shaderProgram, "uAmbientColor");
    shaderProgram.lightingDirectionUniform = gl.getUniformLocation(shaderProgram, "uLightingDirection");
    shaderProgram.directionalColorUniform = gl.getUniformLocation(shaderProgram, "uDirectionalColor");
}

function handleLoadedTexture(texture) {
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
    gl.generateMipmap(gl.TEXTURE_2D);
    
    gl.bindTexture(gl.TEXTURE_2D, null);
}

var glassTexture;

function initTexture() {
    glassTexture = gl.createTexture();
    glassTexture.image = new Image();
    glassTexture.image.onload = function () {
        handleLoadedTexture(glassTexture)
    }
    
    glassTexture.image.src = "crate.gif";
}

var mvMatrix = mat4.create();
var mvMatrixStack = [];
var pMatrix = mat4.create();

function mvPushMatrix() {
    var copy = mat4.create();
    mat4.set(mvMatrix, copy);
    mvMatrixStack.push(copy);
}

function mvPopMatrix() {
    if (mvMatrixStack.length == 0) {
        throw "Invalid popMatrix!";
    }
    mvMatrix = mvMatrixStack.pop();
}


function setMatrixUniforms() {
    gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
    gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
    
    var normalMatrix = mat3.create();
    mat4.toInverseMat3(mvMatrix, normalMatrix);
    mat3.transpose(normalMatrix);
    gl.uniformMatrix3fv(shaderProgram.nMatrixUniform, false, normalMatrix);
}

function degToRad(degrees) {
    return degrees * Math.PI / 180;
}

var xRot = 0;
var xSpeed = 20;

var yRot = 0;
var ySpeed = 20;

var z = -5.0;

var lighting = true;
console.log('Lighting: ' + lighting);

var dist = 0; // Pinch Zoom distance
function getSqrDist(ev) {
    var t1 = ev.touches[0];
    var t2 = ev.touches[1];
    var dx = (t2.pageX - t1.pageX);
    var dy = (t2.pageY - t1.pageY);
    
    return dx * dx + dy * dy;
}

// Pinch Zoom to zoom in/out. Single touch to toggle lighting.
document.addEventListener( 'touchstart', function( ev ) {
    if (ev.touches.length == 2) {
        dist = getSqrDist(ev);
    } else {
        lighting = !lighting;
        console.log('Lighting: ' + lighting);
    }
}, false );

document.addEventListener( 'touchmove', function( ev ) {
    if (ev.touches.length == 2) {
        var newDist = getSqrDist(ev);
        z += (newDist - dist) / 30000.0;
        dist = newDist;
    }
}, false );

var cubeVertexPositionBuffer;
var cubeVertexNormalBuffer;
var cubeVertexTextureCoordBuffer;
var cubeVertexIndexBuffer;
function initBuffers() {
    cubeVertexPositionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
    vertices = [
                // Front face
                -1.0, -1.0,  1.0,
                1.0, -1.0,  1.0,
                1.0,  1.0,  1.0,
                -1.0,  1.0,  1.0,
                
                // Back face
                -1.0, -1.0, -1.0,
                -1.0,  1.0, -1.0,
                1.0,  1.0, -1.0,
                1.0, -1.0, -1.0,
                
                // Top face
                -1.0,  1.0, -1.0,
                -1.0,  1.0,  1.0,
                1.0,  1.0,  1.0,
                1.0,  1.0, -1.0,
                
                // Bottom face
                -1.0, -1.0, -1.0,
                1.0, -1.0, -1.0,
                1.0, -1.0,  1.0,
                -1.0, -1.0,  1.0,
                
                // Right face
                1.0, -1.0, -1.0,
                1.0,  1.0, -1.0,
                1.0,  1.0,  1.0,
                1.0, -1.0,  1.0,
                
                // Left face
                -1.0, -1.0, -1.0,
                -1.0, -1.0,  1.0,
                -1.0,  1.0,  1.0,
                -1.0,  1.0, -1.0
                ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
    cubeVertexPositionBuffer.itemSize = 3;
    cubeVertexPositionBuffer.numItems = 24;
    
    cubeVertexNormalBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexNormalBuffer);
    var vertexNormals = [
                         // Front face
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         0.0,  0.0,  1.0,
                         
                         // Back face
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         0.0,  0.0, -1.0,
                         
                         // Top face
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         0.0,  1.0,  0.0,
                         
                         // Bottom face
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         0.0, -1.0,  0.0,
                         
                         // Right face
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         1.0,  0.0,  0.0,
                         
                         // Left face
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0,
                         -1.0,  0.0,  0.0
                         ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertexNormals), gl.STATIC_DRAW);
    cubeVertexNormalBuffer.itemSize = 3;
    cubeVertexNormalBuffer.numItems = 24;
    
    cubeVertexTextureCoordBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
    var textureCoords = [
                         // Front face
                         0.0, 0.0,
                         1.0, 0.0,
                         1.0, 1.0,
                         0.0, 1.0,
                         
                         // Back face
                         1.0, 0.0,
                         1.0, 1.0,
                         0.0, 1.0,
                         0.0, 0.0,
                         
                         // Top face
                         0.0, 1.0,
                         0.0, 0.0,
                         1.0, 0.0,
                         1.0, 1.0,
                         
                         // Bottom face
                         1.0, 1.0,
                         0.0, 1.0,
                         0.0, 0.0,
                         1.0, 0.0,
                         
                         // Right face
                         1.0, 0.0,
                         1.0, 1.0,
                         0.0, 1.0,
                         0.0, 0.0,
                         
                         // Left face
                         0.0, 0.0,
                         1.0, 0.0,
                         1.0, 1.0,
                         0.0, 1.0,
                         ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW);
    cubeVertexTextureCoordBuffer.itemSize = 2;
    cubeVertexTextureCoordBuffer.numItems = 24;
    
    cubeVertexIndexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
    var cubeVertexIndices = [
                             0, 1, 2,      0, 2, 3,    // Front face
                             4, 5, 6,      4, 6, 7,    // Back face
                             8, 9, 10,     8, 10, 11,  // Top face
                             12, 13, 14,   12, 14, 15, // Bottom face
                             16, 17, 18,   16, 18, 19, // Right face
                             20, 21, 22,   20, 22, 23  // Left face
                             ];
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW);
    cubeVertexIndexBuffer.itemSize = 1;
    cubeVertexIndexBuffer.numItems = 36;
}


function drawScene() {
    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    
    mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);
    
    mat4.identity(mvMatrix);
    
    mat4.translate(mvMatrix, [0.0, 0.0, z]);
    
    mat4.rotate(mvMatrix, degToRad(xRot), [1, 0, 0]);
    mat4.rotate(mvMatrix, degToRad(yRot), [0, 1, 0]);
    
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexNormalBuffer);
    gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute, cubeVertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);
    
    gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
    gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, cubeVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);
    
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, glassTexture);
    gl.uniform1i(shaderProgram.samplerUniform, 0);
    
    gl.uniform1i(shaderProgram.useLightingUniform, lighting);
    if (lighting) {
        gl.uniform3f(shaderProgram.ambientColorUniform,
                     0.2, 0.2, 0.2);
        
        var lightingDirection = [-0.25, -0.25, -1.0];
        var adjustedLD = vec3.create();
        vec3.normalize(lightingDirection, adjustedLD);
        vec3.scale(adjustedLD, -1);
        gl.uniform3fv(shaderProgram.lightingDirectionUniform, adjustedLD);
        
        gl.uniform3f(shaderProgram.directionalColorUniform,
                     0.8, 0.8, 0.8);
    }
    
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
    setMatrixUniforms();
    gl.drawElements(gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
}

var fpsTime = 0;
var numFrames = 0;
var lastTime = 0;
function animate() {
    var timeNow = new Date().getTime();
    if (lastTime != 0) {
        var elapsed = timeNow - lastTime;
        
        if (elapsed < 160) {
            xRot += (xSpeed * elapsed) / 1000.0;
            yRot += (ySpeed * elapsed) / 1000.0;
        }
        numFrames++;
        if (fpsTime != 0) {
            if (timeNow - fpsTime > 1000) {
                console.log("FPS = " + (numFrames * 1000) / (timeNow - fpsTime));
                numFrames = 0;
                fpsTime = timeNow;
            }
        } else {
            fpsTime = timeNow;
        }
    }
    lastTime = timeNow;
}

function tick() {
    drawScene();
    animate();
}

function webGLStart() {
    var canvas = document.getElementById("canvas");
    initGL(canvas);
    initShaders();
    initBuffers();
    initTexture();
    
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.enable(gl.DEPTH_TEST);
    
    setInterval(tick, 16);
}

webGLStart();