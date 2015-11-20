"use strict";

var width = window.innerWidth * window.devicePixelRatio;
var height = window.innerHeight * window.devicePixelRatio;
var canvas = document.getElementById('canvas');
canvas.width = width;
canvas.height = height;
canvas.style.width = window.innerWidth + "px";
canvas.style.height = window.innerHeight + "px";

var gl = canvas.getContext("webgl");

//gl.clearColor(0.2, 0, 0.8, 1);
//gl.clear(gl.COLOR_BUFFER_BIT);


function renderSomething() {
    var v = [
        "attribute vec2 aVertexPosition;",
        "void main() {",
        "gl_Position = vec4(aVertexPosition, 0.0, 1.0);",
        "}",
    ].join("\n");

    var f = [
        "#ifdef GL_ES",
        "precision highp float;",
        "#endif",
        "uniform vec4 uColor;",
        "void main() {",
        "gl_FragColor = uColor;",
        "}",
    ].join("\n");

    var vs = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vs, v);
    gl.compileShader(vs);

    var fs = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fs, f);
    gl.compileShader(fs);

    var program = gl.createProgram();
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);


    // Setup Geometry
    var vertices = new Float32Array([-0.5, -0.5, 0.5, -0.5, 0.0, 0.5 // Triangle-Coordinates
    ]);

    var vbuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vbuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    var itemSize = 2; // we have 2 coordinates (x,y)
    var numItems = vertices.length / itemSize; // number of triangles

    // Viewport
    gl.viewport(0, 0, width, height);
    gl.clearColor(0, 0, 0.8, 1);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // Setup Geometry:
    gl.useProgram(program);

    program.uColor = gl.getUniformLocation(program, "uColor");
    gl.uniform4fv(program.uColor, [0.8, 0.0, 0.0, 1.0]);

    program.aVertexPosition = gl.getAttribLocation(program, "aVertexPosition");
    gl.enableVertexAttribArray(program.aVertexPosition);
    gl.vertexAttribPointer(program.aVertexPosition, itemSize, gl.FLOAT, false, 0, 0);

    // Draw:
    gl.drawArrays(gl.TRIANGLES, 0, numItems);
    //context.drawImage(canvas,10,20);

}

renderSomething();
