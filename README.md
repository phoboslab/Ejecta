# EjectaGL

Ejecta is a fast, open source JavaScript, Canvas & Audio implementation for iOS. Think of it as a Browser that can only display a Canvas element.

EjectaGL adds WebGL support to Ejecta.

More info & Documentation on Ejecta: http://impactjs.com/ejecta

Ejecta/EjectaGL is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).


## How to use

1. Create a folder called `App` within this XCode project
2. Copy your canvas application into the `App` folder
3. Ensure you have at least 1 file named `index.js`
4. Build the XCode project

For an example application, 
  cp -r SampleApp/* App/

or copy(recursively) any of the lessons folder ported from http://http://learningwebgl.com/ 

## Note on Typed Arrays and Performance
Typed Arrays are really not available in the current JavascriptCore used by Ejecta/EjectaGL. A very primitive version will be supported in the current version that just supports a constructor that takes in an Array object. After this the Typed array is completely opaque and useful only for binding buffer data to a buffer.

If you are using any libraries with Types arrays you will have to replace them with a version that just use regular arrays.

This is obviously not ideal and can have performance impact but will have to do till real Typed arrays are supported in JavascriptCore. 

At this point there are no performace gaurantees and this project should be considered just as a proof of concept.

## Loading Shader files
Shader sources can be directly loaded from Javascript strings but ot is inconvenient. Shaders can be loaded from separate files using the overloaded ejecta.require().

Ex.
 
   ejecta.require('shader.vp');
   ejecta.require('shader.fp');

The above will interpret shader.vp as vertex shader and shader.fp as fragment shader baded on their extension. They will be available to the Javascript code as psuedo DOM script elements.

The shader 'shader.vp' will be available with DOM id 'shader-vp'. If the path includes directories that will also be included in the DOM id. For example 'shaders/shader.vp' will be available with the DOM is 'shaders-shader-vp'.

The following shows how the script source can be got from the pseduo DOM element. The pseudo DOM element simulates the properties shown below to get the source in a manner similar to actual WebGL code. This will help in maintaining the same Javascript code across WebGL and EjectaGL.
    
    var shaderScript = document.getElementById("shader-vp");
    if (!shaderScript) {
        return null;
    }
    
    var str = "";
    var k = shaderScript.firstChild;
    str += k.textContent;
    
    var shader;
    if (shaderScript.type == "x-shader/x-fragment") {
        shader = gl.createShader(gl.FRAGMENT_SHADER);
    } else if (shaderScript.type == "x-shader/x-vertex") {
        shader = gl.createShader(gl.VERTEX_SHADER);
    } else {
        return null;
    }
    
    gl.shaderSource(shader, str);

(The SampleApp/ folder has a more complete example)

The currently supported file extensions for shaders are

1. .vp or .vert for vertex shaders
2. .fp or .frag for fragment shaders 
