# Ejecta

Ejecta is a fast, open source JavaScript, Canvas & Audio implementation for iOS. Think of it as a Browser that can only display a Canvas element.

More info & Documentation: http://impactjs.com/ejecta

Ejecta is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).

## Ejecta Next

The _next_ branch of Ejecta features experimental WebGL support. It's quite buggy at the moment, but we intend to fix it. Don't expect your WebGL App to run. At all.

A huge thanks goes to @vikerman - he did most of the grunt work of the WebGL implementation.

To have the WebGL alongside Canvas2D, I modified the old 2D implementation to use OpenGL ES2 instead of ES1, just like WebGL itself. This means that this branch may also break a lot of Canvas2D stuff that was previously working.

I also built a modified version of the JavaScriptCore library, to have support for TypedArrays - this may be broken in some aspects as well.


## Three.js in Ejecta 

Ejecta always creates the screen Canvas element for you. You have to hand this Canvas element over to Three.js instead of letting it create its own.

```javascript
renderer = new THREE.WebGLRenderer( {canvas: document.getElementById('canvas')} );
```

Currently the WebGL context honor's the Canvas element's `retinaResolutionEnabled` property. Creating a 320x480 Canvas will create 640x960 backing store, if Ejecta is running on a retina device. This will probably be changed in the future, so that you have to set the Canvas size yourself to 2x if you want to have retina support.

## How to use

1. Create a folder called `App` within this XCode project
2. Copy your canvas application into the `App` folder
3. Ensure you have at least 1 file named `index.js`
4. Build the XCode project

An example App folder with the Three.js [Walt CubeMap demo](http://mrdoob.github.com/three.js/examples/webgl_materials_cubemap.html) can be found here:

http://phoboslab.org/files/Ejecta-ThreeJS-CubeMap.zip
