# Ejecta

Ejecta is a fast, open source JavaScript, Canvas & Audio implementation for iOS. Think of it as a Browser that can only display a Canvas element.

More info & Documentation: http://impactjs.com/ejecta

Ejecta is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).


## Recent Breaking Changes

 - 2013-04-15 - The GameCenter's `softAuthenticate` now calls the callback function with an error if the auth was skipped, instead of doing nothing. Also, `softAuthenticate` will now always try to auth when called for the very first time after installation.

 - 2013-03-15 - `canvas.scaleMode` was removed in favor of the `canvas.style` property. To scale and position your canvas independently from its internal resolution, use the style's `width`, `height`, `top` and `left` properties. I.e. to always scale to fullscreen: `canvas.style.width = window.innerWidth; `canvas.style.height = window.innerHeight`. Appending `px` suffixes is ok.

## WebGL Support

Recently WebGL support has been merged into the main branch. It's quite buggy at the moment, but we intend to fix it. Don't expect your WebGL App to run. At all.

A huge thanks goes to @vikerman - he did most of the grunt work of the WebGL implementation.

To have the WebGL alongside Canvas2D, I modified the old 2D implementation to use OpenGL ES2 instead of ES1, just like WebGL itself. This means that some of the previously working Canvas2D stuff may currently be broken, although everything is implemented. 

I also built a modified version of the JavaScriptCore library, to have support for TypedArrays - this may be broken in some aspects as well.

Please report any bugs you find, especially regressions.


## Three.js in Ejecta 

Ejecta always creates the screen Canvas element for you. You have to hand this Canvas element over to Three.js instead of letting it create its own.

```javascript
renderer = new THREE.WebGLRenderer( {canvas: document.getElementById('canvas')} );
```

Currently the WebGL context honors the Canvas element's `retinaResolutionEnabled` property. Creating a 320x480 Canvas will create 640x960 backing store, if Ejecta is running on a retina device. This will probably be changed in the future, so that you have to set the Canvas size yourself to 2x if you want to have retina support.

## How to use

1. Create a folder called `App` within this XCode project
2. Copy your canvas application into the `App` folder
3. Ensure you have at least 1 file named `index.js`
4. Build the XCode project

For an example application, copy `./index.js` into the `App` folder. An example App folder with the Three.js [Walt CubeMap demo](http://mrdoob.github.com/three.js/examples/webgl_materials_cubemap.html) can be found here:

http://phoboslab.org/files/Ejecta-ThreeJS-CubeMap.zip
