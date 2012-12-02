/*
 * Author: Vikram Subramanian (@vikerman)
 * Written for js13k competition - js13kgames.com
 */

// Load lother javascript libraries
ejecta.require('lib/gl-matrix.js');

// Load the shaders
ejecta.require('shader.fp');
ejecta.require('shader.vp');

// Template from http://learningwebgl.com/
var gl;
function initGL(canvas) {
    //canvas.width = window.innerWidth;
    //canvas.height = window.innerHeight;
    try {
        gl = canvas.getContext("webgl") ||
	    canvas.getContext("experimental-webgl");
        if (gl) {
            gl.viewportWidth = canvas.width;
            gl.viewportHeight = canvas.height;
        }
    } catch (e) {
    }
    if (!gl) {
        console.log("Could not initialise WebGL, sorry :-(");
    }
}

var mini;
var MAPSCALE = 4.0;
function initMinimap(canvas) {
    canvas.width = (MAXX - MINX) * 2 / MAPSCALE;
    canvas.height = (MAXZ - MINZ) * 2 / MAPSCALE;
    
    mini = canvas.getContext("2d");
    if (!mini) {
        console.log("Could not initialise Canvas, sorry :-(");
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
        console.log("Sahder compile error: " + gl.getShaderInfoLog(shader));
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
    }
    
    gl.useProgram(shaderProgram);
    
    shaderProgram.vertexPositionAttribute =
	gl.getAttribLocation(shaderProgram, "aVertexPosition");
    gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);
    shaderProgram.vertexColorAttribute =
	gl.getAttribLocation(shaderProgram, "aVertexColor");
    gl.enableVertexAttribArray(shaderProgram.vertexColorAttribute);
    shaderProgram.vertexNormalAttribute =
	gl.getAttribLocation(shaderProgram, "aVertexNormal");
    gl.enableVertexAttribArray(shaderProgram.vertexNormalAttribute);
    shaderProgram.worldPositionAttribute =
	gl.getAttribLocation(shaderProgram, "aWorldPosition");
    gl.enableVertexAttribArray(shaderProgram.worldPositionAttribute);
    shaderProgram.velocityAttribute =
	gl.getAttribLocation(shaderProgram, "aVelocity");
    gl.enableVertexAttribArray(shaderProgram.velocityAttribute);
    shaderProgram.startTimeAttribute =
	gl.getAttribLocation(shaderProgram, "aStartTime");
    gl.enableVertexAttribArray(shaderProgram.startTimeAttribute);
    
    shaderProgram.pMatrixUniform =
	gl.getUniformLocation(shaderProgram, "uPMatrix");
    shaderProgram.rMatrixUniform =
	gl.getUniformLocation(shaderProgram, "uRMatrix");
    shaderProgram.cMatrixUniform =
	gl.getUniformLocation(shaderProgram, "uCMatrix");
    shaderProgram.timeUniform =
	gl.getUniformLocation(shaderProgram, "uTime");
    shaderProgram.useLightingUniform =
	gl.getUniformLocation(shaderProgram, "uUseLighting");
    shaderProgram.useFogUniform =
	gl.getUniformLocation(shaderProgram, "uUseFog");
    shaderProgram.ambientColorUniform =
	gl.getUniformLocation(shaderProgram, "uAmbientColor");
    shaderProgram.lightingDirectionUniform =
	gl.getUniformLocation(shaderProgram, "uLightingDirection");
    shaderProgram.directionalColorUniform =
	gl.getUniformLocation(shaderProgram, "uDirectionalColor");
}

var cMatrix = mat4.create();
var rMatrix = mat4.create();
var pMatrix = mat4.create();

function degToRad(degrees) {
    return degrees * Math.PI / 180;
}

var SIZE = 32;
var R = SIZE / 2;

var vertices;
var groundColors;
var cloudColors;
var waterColors;
var enemyColors;
var bulletColors;
var normals;
var topIndices;
var leftIndices;
var rightIndices;
var frontIndices;
var backIndices;
var bottomIndices;

function initArrays() {
    vertices = [
                // Front face
                -R,-R, R,
                R,-R, R,
                R, R, R,
                -R, R, R,
                
                // Back face
                -R,-R,-R,
                -R, R,-R,
                R, R,-R,
                R,-R,-R,
                
                // Top face
                -R, R,-R,
                -R, R, R,
                R, R, R,
                R, R,-R,
                
                // Right face
                R,-R,-R,
                R, R,-R,
                R, R, R,
                R,-R, R,
                
                // Left face
                -R,-R,-R,
                -R,-R, R,
                -R, R, R,
                -R, R,-R,
                
                // Bottom face
                -R, -R, -R,
                R, -R, -R,
                R, -R,  R,
                -R, -R,  R
                ];
    
    var packedGroundColors = [
                              [0.8, 0.52, 0.24, 1.0],     // Front face
                              [0.8, 0.52, 0.24, 1.0],     // Back face
                              [0.0, 0.8, 0.0, 1.0],       // Top face
                              [0.8, 0.52, 0.24, 1.0],     // Right face
                              [0.8, 0.52, 0.24, 1.0],     // Left face
                              [0.8, 0.52, 0.24, 1.0]      // Bottom face
                              ];
    
    var getPackedColors = function(color) {
        var packedColors = [];
        for (var i = 0; i < 6; i++) {
            // One for each face.
            packedColors.push(color);
        }
        return packedColors;
    }
    var packedCloudColors = getPackedColors([0.9, 0.9, 0.9, 1.0]);
    var packedWaterColors = getPackedColors([0.4, 0.4, 0.9, 1.0]);
    var packedEnemyColors = getPackedColors([1.0, 0.0, 0.0, 1.0]);
    var packedBulletColors = getPackedColors([0.0, 0.0, 1.0, 1.0]);
    
    var getUnpackedColors = function(packedColors) {
        var colors = [];
        for (var i in packedColors) {
            var color = packedColors[i];
            for (var j = 0; j < 4; j++) {
                colors = colors.concat(color);
            }
        }
        return colors;
    }
    groundColors = getUnpackedColors(packedGroundColors);
    cloudColors = getUnpackedColors(packedCloudColors);
    waterColors = getUnpackedColors(packedWaterColors);
    enemyColors = getUnpackedColors(packedEnemyColors);
    bulletColors = getUnpackedColors(packedBulletColors);
    
    normals = [
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
               
               // Right face
               1.0,  0.0,  0.0,
               1.0,  0.0,  0.0,
               1.0,  0.0,  0.0,
               1.0,  0.0,  0.0,
               
               // Left face
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0,
               -1.0,  0.0,  0.0,
               
               // Bottom face
               0.0, -1.0,  0.0,
               0.0, -1.0,  0.0,
               0.0, -1.0,  0.0,
               0.0, -1.0,  0.0
               ];
    
    topIndices = [8, 9, 10,     8, 10, 11];
    leftIndices = [16, 17, 18,   16, 18, 19];
    rightIndices = [12, 13, 14,   12, 14, 15];
    frontIndices = [0, 1, 2,      0, 2, 3];
    backIndices = [4, 5, 6,      4, 6, 7];
    bottomIndices = [20, 21, 22,      20, 22, 23];
}

var GROUND = 0, CLOUD = 1, WATER = 2, ENEMY = 3, BULLET = 4;
function addCube(v, c, n, p, vel, t, x, y, z, scalex, scaley, scalez,
                 vx, vy, vz, startTime, type, material) {
    // Create a list of vertex indices to be added.
    var indices = topIndices;
    var colors = groundColors;
    if (material == CLOUD) {
        colors = cloudColors;
    } else if (material == WATER) {
        colors = waterColors;
    } else if (material == ENEMY) {
        colors = enemyColors;
    } else if (material == BULLET) {
        colors = bulletColors;
    }
    
    if ((type & LEFT) == LEFT) {
        indices = indices.concat(leftIndices);
    }
    if ((type & RIGHT) == RIGHT) {
        indices = indices.concat(rightIndices);
    }
    if ((type & FRONT) == FRONT) {
        indices = indices.concat(frontIndices);
    }
    if ((type & BACK) == BACK) {
        indices = indices.concat(backIndices);
    }
    if ((type & BOTTOM) == BOTTOM) {
        indices = indices.concat(bottomIndices);
    }
    
    for (i = 0; i < indices.length; i++) {
        // Add each of the vertex, color, normal and position
        // to the respective arrays.
        var index = indices[i];
        
        var i2 = index * 2;
        var i3 = index * 3;
        var i4 = index * 4;
        v.push(vertices[i3] * scalex,
               vertices[i3 + 1] * scaley,
               vertices[i3 + 2] * scalez);
        c.push(colors[i4], colors[i4 + 1], colors[i4 + 2], colors[i4 + 3]);
        n.push(normals[i3], normals[i3 + 1], normals[i3 + 2]);
        p.push(x, y, z);
        vel.push(vx, vy, vz);
        t.push(startTime);
    }
}

function createChunk(v, c, n, p, vel, t, colorConfig) {
    chunk = {};
    
    // Create the chunk buffers.
    // Vertex buffer.
    chunk.vbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.vbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(v), gl.STATIC_DRAW);
    chunk.vbuffer.itemSize = 3;
    chunk.vbuffer.numItems = v.length / chunk.vbuffer.itemSize;
    
    // Color buffer.
    chunk.cbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.cbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(c), gl.STATIC_DRAW);
    chunk.cbuffer.itemSize = 4;
    chunk.cbuffer.numItems = c.length / chunk.cbuffer.itemSize;
    
    // Normal buffer.
    chunk.nbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.nbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(n), gl.STATIC_DRAW);
    chunk.nbuffer.itemSize = 3;
    chunk.nbuffer.numItems = n.length / chunk.nbuffer.itemSize;
    
    // World position buffer.
    chunk.pbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.pbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(p), gl.STATIC_DRAW);
    chunk.pbuffer.itemSize = 3;
    chunk.pbuffer.numItems = p.length / chunk.pbuffer.itemSize;
    
    // Velocity buffer.
    chunk.velbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.velbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vel), gl.STATIC_DRAW);
    chunk.pbuffer.itemSize = 3;
    chunk.pbuffer.numItems = vel.length / chunk.velbuffer.itemSize;
    
    // Start time buffer.
    chunk.tbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.tbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(t), gl.STATIC_DRAW);
    chunk.tbuffer.itemSize = 1;
    chunk.tbuffer.numItems = t.length;
    
    // Lighting config for uniforms.
    chunk.lighting = colorConfig.lighting || false;
    chunk.fog = colorConfig.fog || false;
    
    return chunk;
}

function createGroundChunk(minX, maxX, minZ, maxZ) {
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    
    // Create the mega mesh.
    for (var z = minZ; z < maxZ; z++) {
        for (var x = minX; x < maxX; x++) {
            var xi = x - MINX, zi = z - MINZ;
            var i = zi * (MAXX - MINX) + xi;
            var y = terrain[i];
            
            var type = 0;
            var diff = 1;
            if (xi > 0) {
                var left = terrain[i - 1];
                if (left < y) {
                    type |= LEFT;
                    diff = Math.max(diff, y - left);
                }
            } else {
                diff = 6;
                type |= LEFT;
            }
            if (xi < (MAXX - MINX - 1)) {
                var right = terrain[i + 1];
                if (right < y) {
                    type |= RIGHT;
                    diff = Math.max(diff, y - right);
                }
            } else {
                diff = 6;
                type |= RIGHT;
            }
            if (zi > 0) {
                var back = terrain[i - (MAXX - MINX)];
                if (back < y) {
                    type |= BACK;
                    diff = Math.max(diff, y - back);
                }
            } else {
                diff = 6;
                type |= BACK;
            }
            if (zi < (MAXZ - MINZ - 1)) {
                var front = terrain[i + (MAXX - MINX)];
                if (front < y) {
                    type |= FRONT;
                    diff = Math.max(diff, y - front);
                }
            } else {
                diff = 6;
                type |= FRONT;
            }
            
            // Add cube data to the big array of vertex + attributes.
            for (var j = 0; j < diff; j++) {
                addCube(v, c, n, p, vel, t,
                        x * SIZE, (y - j) * SIZE, z * SIZE,
                        1, 1, 1,
                        0, 0, 0, startTime,
                        type, GROUND);
            }
        }
    }
    
    return createChunk(v, c, n, p, vel, t, {lighting:false, fog: false});
}

var ground = [];
function initGroundChunks() {
    var zstep =  50;
    var xstep =  50;
    for (var z = MINZ; z < MAXZ; z += zstep) {
        for (var x = MINX; x < MAXX; x += xstep) {
            ground.push(createGroundChunk(x, Math.min(x + xstep, MAXX),
                                          z, Math.min(z + zstep, MAXZ)));
        }
    }
}

var clouds = [];
var NUMCLOUDS = 40;
function initCloudChunks() {
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    
    // Create a single chunk for all the spread out clouds
    for (var i = 0; i < NUMCLOUDS; i++) {
        // Create an elliptical cloud at a random X,Z location.
        var sx = MINX + Math.floor(Math.random() * (MAXX - MINX));
        var sz = MINZ + Math.floor(Math.random() * (MAXZ - MINZ));
        
        var dh = Math.random() * 10.0 * SIZE - 5 * SIZE;
        
        var allFaces = LEFT | RIGHT | BACK | FRONT | BOTTOM;
        for (var z = 0; z <= 5; z++) {
            for (var x = 0; x <= 5; x++) {
                var y = Math.floor((Math.sin(z / 5 * Math.PI)
                                    + Math.sin(x / 5 * Math.PI) / 1.5));
                
                for (var j = -y; j <= y; j++) {
                    addCube(v, c, n, p, vel, t,
                            sx * SIZE + x * SIZE * 4,
                            (16 + j) * SIZE + dh,
                            sz * SIZE + z * SIZE * 4,
                            4, 1, 4,
                            0, 0, 0, startTime,
                            allFaces, CLOUD);
                }
            }
        }
    }
    clouds.push(createChunk(v, c, n, p, vel, t, {ligting:false, fog:false}));
}

var water = [];
function initWaterChunks() {
    
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    
    var stepz = (MAXZ - MINZ) * SIZE;
    var stepx = (MAXX - MINX) * SIZE;
    
    var sz = -(MAXZ - MINZ) * SIZE;
    for (var i = 0; i < 3; i++) {
        var sx = -(MAXX - MINX) * SIZE;
        for (var j = 0; j < 3; j++) {
            if ((i == 1) && (j == 1)) {
                // Do nothing... This is where the island is.
            }
            else {
                // Add top face of water as 8 big tiles
                // surrounding the island.
                addCube(v, c, n, p, vel, t,
                        sx, 0, sz,
                        (MAXX - MINX), 1, (MAXZ - MINZ),
                        0, 0, 0, startTime,
                        0, WATER);
            }
            sx += stepx;
        }
        sz += stepz;
    }
    water.push(createChunk(v, c, n, p, vel, t, {lighting:false, fog:false}));
}

var enemyChunks = [];
function updateEnemyChunks() {
    enemyChunks = [];
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    var faces = LEFT | RIGHT | FRONT | BACK;
    for (var i = 0; i < enemies.length; i++) {
        var enemy = enemies[i];
        addCube(v, c, n, p, vel, t,
                enemy.x * SIZE, enemy.y * SIZE, enemy.z * SIZE,
                4, 4, 4,
                0, 0, 0, startTime,
                faces, ENEMY);
    }
    enemyChunks.push(createChunk(v, c, n, p, vel, t, {lighting:false, fog:false}));
}

// Player Bullets.
var pBulletChunks = [];
function updatePBulletChunks() {
    pBulletChunks = [];
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    var faces = LEFT | RIGHT | FRONT | BACK | BOTTOM;
    for (var i = 0; i < pbullets.length; i++) {
        var pbullet = pbullets[i];
        addCube(v, c, n, p, vel, t,
                pbullet.x, pbullet.y, pbullet.z,
                0.25, 0.25, 0.25,
                pbullet.dir[0] * 2, pbullet.dir[1] * 2, pbullet.dir[2] * 2,
                pbullet.startTime,
                faces, BULLET);
    }
    pBulletChunks.push(createChunk(v, c, n, p, vel, t, {lighting:false, fog:false}));
}

// Enemy Bullets.
var eBulletChunks = [];
function updateEBulletChunks() {
    eBulletChunks = [];
    var v = [], c = [], n = [], p = [], vel = [], t = [];
    var faces = LEFT | RIGHT | FRONT | BACK | BOTTOM;
    for (var i = 0; i < ebullets.length; i++) {
        var ebullet = ebullets[i];
        addCube(v, c, n, p, vel, t,
                ebullet.x, ebullet.y, ebullet.z,
                0.25, 0.25, 0.25,
                ebullet.dir[0] * 2, ebullet.dir[1] * 2, ebullet.dir[2] * 2,
                startTime,
                faces, ENEMY);
    }
    eBulletChunks.push(createChunk(v, c, n, p, vel, t, {lighting:false, fog:false}));
}

function updateView() {
    camera.view[0] = Math.cos(camera.lrot) * Math.cos(camera.drot);
    camera.view[1] = Math.sin(camera.drot);
    camera.view[2] = Math.sin(camera.lrot) * Math.cos(camera.drot);
    vec3.normalize(camera.view);
    vec3.add(camera.pos, camera.view, camera.lookAt);
}

function initCamera() {
    camera.pos = vec3.create([300, 200, 10]);
    camera.lrot = 0; // Left rotation
    camera.drot = 0; // Down rotation
    camera.roll = 0; // Roll rotation
    camera.view = vec3.create();
    camera.lookAt = vec3.create();
    camera.up = vec3.create([0, 1, 0]);
    updateView();
}

var MINX = -128, MAXX = 128, MINZ = -128, MAXZ = 128;
var terrain;
function initTerrain() {
    terrain = new Array((MAXX - MINX) * (MAXZ - MINZ));
    var i = 0;
    for (var z = MINZ; z < MAXZ; z++) {
        for (var x = MINX; x < MAXX; x++) {
            terrain[i] = Math.floor(
                                    (Math.sin(x / 32 * Math.PI)
                                     + Math.cos(z / 32 * Math.PI)) * 2.9);
            if ((x == MINX) || (x == MAXX - 1) || (z == MINZ)
                || (z == MAXZ -1)) {
                if (terrain[i] < 1) {
                    terrain[i] = 1;
                }
            }
            i++;
        }
    }
}

var enemies = [];
var NUMENEMIES = 26;
function initEnemies() {
    for (var j = 0; j < NUMENEMIES; j++) {
        var enemy = {};
        
        // Randomly choose positions for the enemies.
        enemy.x = MINX + Math.floor(Math.random() * (MAXX - MINX));
        enemy.z = MINZ + Math.floor(Math.random() * (MAXZ - MINZ));
        
        var i = (enemy.z - MINZ) * (MAXX - MINX) + (enemy.x - MINX);
        enemy.y = terrain[i] + 2;
        
        enemies.push(enemy);
    }
}

function setupCommonUniforms() {
    // Lighting.
    gl.uniform3f(shaderProgram.ambientColorUniform,
                 0.2, 0.2, 0.2);
    
    var amp = Math.sqrt(1.5);
    gl.uniform3f(shaderProgram.lightingDirectionUniform,
                 0.5 / amp, 1.0 / amp, 0.5 / amp);
    gl.uniform3f(shaderProgram.directionalColorUniform,
                 0.5, 0.5, 0.5);
    
    // Project and camera matrices.
    gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
    gl.uniformMatrix4fv(shaderProgram.rMatrixUniform, false, rMatrix);
    gl.uniformMatrix4fv(shaderProgram.cMatrixUniform, false, cMatrix);
    
    // Current time
    gl.uniform1f(shaderProgram.timeUniform, startTime * 1.0);
}

function drawChunk(chunk) {
    // Bind the buffers for this chunk.
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.vbuffer);
    gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute,
                           chunk.vbuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.cbuffer);
    gl.vertexAttribPointer(shaderProgram.vertexColorAttribute,
                           chunk.cbuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.nbuffer);
    gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute,
                           chunk.nbuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.pbuffer);
    gl.vertexAttribPointer(shaderProgram.worldPositionAttribute,
                           chunk.pbuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.velbuffer);
    gl.vertexAttribPointer(shaderProgram.velocityAttribute,
                           chunk.pbuffer.itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, chunk.tbuffer);
    gl.vertexAttribPointer(shaderProgram.startTimeAttribute,
                           chunk.tbuffer.itemSize, gl.FLOAT, false, 0, 0);
    
    gl.uniform1i(shaderProgram.useLightingUniform, chunk.lighting);
    gl.uniform1i(shaderProgram.useFogUniform, chunk.fog);
    
    // Draw!!!
    gl.drawArrays(gl.TRIANGLES, 0, chunk.vbuffer.numItems);
}

function drawChunks(chunks) {
    for (var i = 0; i < chunks.length; i++) {
        drawChunk(chunks[i]);
    }
}

var camera = {};
var LEFT = 1, RIGHT = 2, FRONT = 4, BACK = 8, BOTTOM = 16;
function drawScene() {
    gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    
    mat4.identity(rMatrix);
    mat4.rotateZ(rMatrix, camera.roll, rMatrix);
    mat4.lookAt(camera.pos, camera.lookAt, camera.up, cMatrix);
    
    // Setup common uniforms for this frame.
    setupCommonUniforms();
    
    // Draw each of the chunks - Just one draw call per chunk.
    drawChunks(ground);
    drawChunks(enemyChunks);
    drawChunks(clouds);
    drawChunks(water);
    drawChunks(pBulletChunks);
}

var current = 0;
var fps = 60;
var numFrames = 0;
var fpsText = null;
function updateFps(elapsed) {
    current += elapsed;
    numFrames++;
    
    // Aggregate number of frames displayed in the last 1 second.
    if (current > 1000) {
        fps = Math.floor(numFrames * 1000 / current);
        current = 0;
        numFrames = 0;
        fpsText.innerHTML = fps;
    }
}

function drawMinimap() {
    // Clear with transparent color.
    //mini.fillStyle = "rgba(0, 0, 0, 0)";
    mini.clearRect(0, 0, minimap.width, minimap.height);
    
    // Draw border
    mini.strokeStyle = "rgb(0, 0, 0)";
    mini.strokeRect(0, 0, minimap.width, minimap.height);
    
    mini.save();
    var centerx = (MAXX - MINX) / MAPSCALE;
    var centery = (MAXZ - MINZ) / MAPSCALE;
    mini.translate(centerx, centery);
    
    // Draw the island in green.
    mini.strokeStyle = "rgb(0, 256, 0)";
    mini.strokeRect(MINX / MAPSCALE, MINZ / MAPSCALE,
                    (MAXX - MINX) / MAPSCALE, (MAXZ - MINZ) / MAPSCALE);
    
    // Draw player position with blue
    mini.fillStyle = "rgb(0, 0, 256)";
    mini.fillRect(camera.pos[0] / (SIZE * MAPSCALE),
                  camera.pos[2] / (SIZE * MAPSCALE),
                  4, 4);
    
    // Draw all the enemies.
    for (var i = 0; i < enemies.length; i++) {
        var enemy = enemies[i];
        mini.fillStyle = "rgb(256, 0, 0)";
        mini.fillRect(enemy.x / MAPSCALE,
                      enemy.z / MAPSCALE,
                      2, 2);
    }
    
    mini.restore();
}

var lastTime = 0;
var crashed = false;
function updateAndDraw() {
    if (!crashed) {
        var timeNow = new Date().getTime();
        if (lastTime != 0) {
            var elapsed = timeNow - lastTime;
            startTime = timeNow; // Store in global variable.
            if (elapsed < 160) {
                updateCamera(elapsed);
                updateBullets(elapsed);
                //updateFps(elapsed);
                drawScene();
                //drawMinimap();
            }
        }
        lastTime = timeNow;
    } else {
        //var c = document.getElementById("crashed");
        //c.innerHTML = "Crashed!";
        console.log("Crashed!");
    }
}

var view = vec3.create();
var lastShoot = 0;
var Score = 0;
var BASESPEED = 1;
function updateCamera(elapsed) {
    // Update the view based on key press.
    var turning = false;
    var delta = degToRad(30 * elapsed / 1000.0);
    
    if (keys[37] || keys[38] || keys[39] || keys[40]) {
        if (keys[37]) { // Left
            
            camera.lrot -= delta;
            if (camera.lrot < 0) {
                camera.lrot += 2 * Math.PI;
            }
            
            // Bank the camera left when turning left.
            camera.roll -= delta / 4;
            if (camera.roll < -Math.PI / 4) {
                camera.roll = -Math.PI / 4;
            }
            turning = true;
        }
        
        if (keys[39]) { // Right
            camera.lrot += delta;
            if (camera.lrot > 2 * Math.PI) {
                camera.lrot -= 2 * Math.PI;
            }
            
            // Bank the camera right when turning right.
            camera.roll += delta / 4;
            if (camera.roll > Math.PI / 4) {
                camera.roll = Math.PI / 4;
            }
            turning = true;
        }
        
        if (keys[38]) { // Up
            camera.drot += delta;
            if (camera.drot > Math.PI / 4) {
                camera.drot = Math.PI / 4;
            }
        }
        if (keys[40]) { // Down
            camera.drot -= delta;
            if (camera.drot < -Math.PI / 4) {
                camera.drot = -Math.PI / 4;
            }
        }
        updateView();
    }
    
    lastShoot += elapsed;
    if (keys[32]) { // Shoot
        if (lastShoot > 100) {
            lastShoot = 0;
            if (pbullets.length < MAXPBULLETS){
                pbullet = {};
                pbullet.dir = new Array(3);
                pbullet.dir[0] = camera.view[0];
                pbullet.dir[1] = camera.view[1];
                pbullet.dir[2] = camera.view[2];
                pbullet.startTime = startTime * 1.0;
                
                // Give it a headstart.
                pbullet.x = camera.pos[0] + (pbullet.dir[0] * elapsed * 2);
                pbullet.y = camera.pos[1] + (pbullet.dir[1] * elapsed * 2);
                pbullet.z = camera.pos[2] + (pbullet.dir[2] * elapsed * 2);
                
                pbullets.push(pbullet);
                updatePBulletChunks();
            }
        }
    }
    
    if (!turning) {
        // Reset roll if not actively turning.
        if (camera.roll > 0) {
            camera.roll -= delta;
            if (camera.roll < 0) {
                camera.roll = 0;
            }
        } else 	if (camera.roll < 0) {
            camera.roll += delta;
            if (camera.roll > 0) {
                camera.roll = 0;
            }
        }
    }
    
    // Move the camera in the direction of the view.
    var speed = 1 / 2.0;
    if (keys[87]) { // W - for boost.
        speed = 1.0;
    }
    var deltaZ = BASESPEED * elapsed * speed;
    var offset = [camera.view[0] * deltaZ,
                  camera.view[1] * deltaZ,
                  camera.view[2] * deltaZ];
    vec3.add(camera.pos, offset);
    
    // Set upper boundary.
    var ty = camera.pos[1];
    if (camera.pos[1] > 18 * SIZE) {
        camera.pos[1] = 18 * SIZE;
    }
    
    // Wrap around the screen!
    var tx = camera.pos[0];
    var tz = camera.pos[2];
    
    if (camera.pos[0] > (MAXX - MINX) * SIZE) {
        camera.pos[0] = -(MAXX - MINX) * SIZE;
    }
    
    if (camera.pos[0] < -(MAXX - MINX) * SIZE) {
        camera.pos[0] = (MAXX - MINX) * SIZE;
    }
    
    if (camera.pos[2] > (MAXZ - MINZ) * SIZE) {
        camera.pos[2] = -(MAXZ - MINZ) * SIZE;
    }
    
    if (camera.pos[2] < -(MAXZ - MINZ) * SIZE) {
        camera.pos[2] = (MAXZ - MINZ) * SIZE;
    }
    
    vec3.add(camera.lookAt, offset);
    camera.lookAt[0] -= (tx - camera.pos[0]);
    camera.lookAt[1] -= (ty - camera.pos[1]);
    camera.lookAt[2] -= (tz - camera.pos[2]);
    
    // Check for collision with terrain / water
    var xi = camera.pos[0] / SIZE;
    var zi = camera.pos[2] / SIZE;
    if ((xi >= MINX) && (xi < MAXX) && (zi >= MINZ) && (zi < MAXZ)) {
        // Check for collision with terrain.
        var i = Math.floor(zi - MINZ) * (MAXX - MINX) + Math.floor(xi - MINX);
        if (camera.pos[1] < (terrain[i] * SIZE)) {
            // Crash!
            crashed = true;
            //console.log("Crash");
            camera.pos[1] = (terrain[i] + 1) * SIZE;
        }
        // Check crash with each of the enemies
        var found = -1;
        for (var j = 0; j < enemies.length; j++) {
            var enemy = enemies[j];
            var cx = Math.floor(xi);
            var cz = Math.floor(zi);
            if ((cx >= enemy.x - 4) && (cx <= enemy.x + 4) 
                && (cz >= enemy.z - 4) && (cz <= enemy.z + 4)) {
                if (camera.pos[1] < enemy.y * SIZE + 4 * R) {
                    // console.log("Pick!");
                    found = j;
                    break;
                }
            }	    
        }
        // Remove the block from the list
        if (found != -1) {
            enemies.splice(found, 1);
            console.log("Score: " + (++Score));
            //var score = document.getElementById("score");
            //score.innerHTML = "Score: " + (++Score);
            if (enemies.length == 0) {
                // Next Wave.
                BASESPEED += 0.2;
                initEnemies();
            }
            updateEnemyChunks();
        }
    } else {
        if (camera.pos[1] < 0) {
            // Crash!
            crashed = true;
            camera.pos[1] = SIZE;
            //console.log("Crash");
        }
    }
}

var pbullets = [];
var MAXPBULLETS = 30;
function updateBullets(elapsed) {
    var remove = [];
    for (var i = 0; i < pbullets.length; i++) {
        pbullet.elapsed += elapsed;
        if (pbullet.elapsed > 5000) {
            // Add to remove list
            remove.push(i);
        } else {		
            pbullet.x = pbullet.x + (pbullet.dir[0] * elapsed * 2);
            pbullet.y = pbullet.y + (pbullet.dir[1] * elapsed * 2);
            pbullet.z = pbullet.z + (pbullet.dir[2] * elapsed * 2);
            
            // Check for collision with enemies.
        }		
    }
    
    if (remove.length > 0) {
        for (var i = 0; i < remove.length; i++) {
            console.log("Removing bullet");
            var index = remove[i] - i;
            pbullets.splice(index, 1);
        }
        updatePBulletChunks();
    }
}

var startTime = 0;
function tick() {
    requestAnimFrame(tick);
    updateAndDraw();
}

var canvas;
var minimap;
function webGLStart() {
    canvas = document.getElementById("canvas");
    initGL(canvas);

    // Disable minimap till offscreen 2D canvas work.
    //minimap = document.getElementById("minimap")
    //initMinimap(minimap);
    
    initShaders();
    
    initArrays();
    
    initTerrain();
    initEnemies();
    
    initGroundChunks();
    initCloudChunks();
    initWaterChunks();
    updateEnemyChunks();
    
    initCamera();
    
    gl.clearColor(0.8, 0.8, 1.0, 1.0);
    gl.enable(gl.DEPTH_TEST);
    gl.cullFace(gl.BACK);
    gl.enable(gl.CULL_FACE);
    
    // Doesn't change per frame.
    setPerspective();
    
    // FPS display.
    //fpsText = document.getElementById("fps");
    tick();
}

function setPerspective() {
    mat4.perspective(60, gl.viewportWidth / gl.viewportHeight, 0.1, 4096.0, 
                     pMatrix);
}

var keys = {};
function handleKeyDown(event) {
    keys[event.keyCode] = true;
    //console.log(event.keyCode);
}
function handleKeyUp(event) {
    delete keys[event.keyCode];
}

document.onkeydown = handleKeyDown;
document.onkeyup = handleKeyUp;

window.onresize = function() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewportWidth = canvas.width;
    gl.viewportHeight = canvas.height;
    setPerspective();
}

window.requestAnimFrame = (function() {
                           return window.requestAnimationFrame ||
                           window.webkitRequestAnimationFrame ||
                           window.mozRequestAnimationFrame ||
                           window.oRequestAnimationFrame ||
                           window.msRequestAnimationFrame ||
                           function(/* function FrameRequestCallback */ callback, /* DOMElement Element */ element) {
                           window.setTimeout(callback, 1000/60);
                           };
                           })();


// Start the program.
webGLStart();
