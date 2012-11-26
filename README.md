# EjectaGL

EjectaGL is a fast, open source JavaScript, WebGL (& Audio implementation) for iOS. Think of it as a Browser that can only display a WebGL Canvas element.

EjectaGL is forked from Ejecta project which replaces the 2D Canvas with a WebGL Canvas.

EjectaGL is far from being on parity with the current WebGL with only samll part of the API spec implemented but mostly it's just a matter of writing the bindings. 

More info & Documentation on Ejecta: http://impactjs.com/ejecta
(till EjectaGL get it's own documentation)

EjectaGL is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).


## How to use

1. Create a folder called `App` within this XCode project
2. Copy your canvas application into the `App` folder
3. Ensure you have at least 1 file named `index.js`
4. Build the XCode project

For an example application, 
  cp -r examples/SampleApp/* App/

or copy(recursively) any of the lessons in the examples folder ported from http://learningwebgl.com/ 

## Creating a WebGL context

Currently the WebGL context can be created by passing in the 'experimental-webgl' parameter to getContext.

    gl = canvas.getContext('experimental-webgl');

## Note on Typed Arrays and Performance
Typed Arrays are really not available in the current JavascriptCore used by Ejecta/EjectaGL. A very primitive version will be supported in the current version that just supports a constructor that takes in an Array object. After this the Typed array is completely opaque and useful only for binding buffer data to a buffer.

If you are using any libraries with Types arrays you will have to replace them with a version that just use regular arrays.

This is obviously not ideal and can have performance impact but will have to do till real Typed arrays are supported in JavascriptCore. 

At this point there are no performace gaurantees and this project should be considered just as a proof of concept.

The other approach we can take till this is resolved is to have native implementations of the part that require Typed Arrays. For example the glMatrix library could be ported into Obejctive C and provide a fast implementation while it's interface itself does not require typed arrays.

Similarly we can think of porting parts of three.js that require typed arrays to Objective-C so that we can have a fast implementation without typed arrays. The interface to three.js doesn't require typed arrays (If I'm not totally wrong).

## Loading Shader files
Shader sources can be directly loaded from Javascript strings but it is inconvenient. EjectaGL allows shaders to be loaded from separate files using an overloaded ejecta.require().

Ex.
 
     ejecta.require('shader.vp');
     ejecta.require('shader.fp');

The above will load shader.vp as a vertex shader and shader.fp as a fragment shader baded on their extensions. They will be available to the Javascript code as psuedo DOM script elements with type set to 'x-shader/x-vertex' for vertex shaders amd 'x-shader/x-fragment' for fragment shaders.

The shader 'shader.vp' will be available with DOM id 'shader-vp'. The translation basically replaces '.' and '/' in the path by '-'. For example 'shaders/shader.vp' will be available with the DOM id 'shaders-shader-vp'.

The following snippet shows how the shader script text can be got from the pseduo DOM element. The pseudo DOM element simulates the properties shown below to get the source in a manner similar to actual WebGL code. This is intended to help maintain the same Javascript code across WebGL and EjectaGL.
  
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
            console.log(type + " Shader error: " + gl.getShaderInfoLog(shader));
            return null;
        }
    
        return shader;
    }

(The examples/SampleApp/ folder has a more complete example)

The currently supported file extensions for shaders are

1. .vp or .vert for vertex shaders
2. .fp or .frag for fragment shaders 
