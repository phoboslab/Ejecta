# Ejecta

Ejecta is a fast, open source JavaScript, Canvas & Audio implementation for iOS. Think of it as a Browser that can only display a Canvas element.

More info & Documentation: http://impactjs.com/ejecta

Ejecta is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).


## Recent Breaking Changes

### 2015-11-08 - Removed automatic pixel doubling for retina devices

The Canvas' backing store is now exactly the same size as the `canvas.width` and `canvas.height`. Ejecta *does not* automatically double the internal resolution on retina devices anymore. The `ctx.backingStorePixelRatio` and `canvas.retinaResolutionEnabled` properties as well as the `HD` variants for the `ctx.getImageData`, `ctx.putImageData` and `ctx.createImageData` functions have been removed.

You can of course still render in retina resolution, by setting the `width` and `height` to the retina resolution while forcing the `style` to scale the canvas to the logical display resolution.

 ```javascript
canvas.width = window.innerWidth * window.devicePixelRatio;
canvas.height = window.innerHeight * window.devicePixelRatio;
canvas.style.width = window.innerWidth + 'px';
canvas.style.height = window.innerHeight + 'px';

// For 2D contexts you may want to zoom in afterwards
ctx.scale( window.devicePixelRatio, window.devicePixelRatio );
```


## WebGL Support

Recently WebGL support has been merged into the main branch. A huge thanks goes to @vikerman - he did most of the grunt work of the WebGL implementation. To have the WebGL alongside Canvas2D, I modified the old 2D implementation to use OpenGL ES2 instead of ES1, just like WebGL itself. 



## Three.js on iOS with Ejecta 

Ejecta always creates the screen Canvas element for you. You have to hand this Canvas element over to Three.js instead of letting it create its own.

```javascript
renderer = new THREE.WebGLRenderer( {canvas: document.getElementById('canvas')} );
```


## How to use

1. Create a folder called `App` within this XCode project
2. Copy your canvas application into the `App` folder
3. Ensure you have at least 1 file named `index.js`
4. Build the XCode project

For an example application, copy `./index.js` into the `App` folder. An example App folder with the Three.js [Walt CubeMap demo](http://mrdoob.github.com/three.js/examples/webgl_materials_cubemap.html) can be found here:

http://phoboslab.org/files/Ejecta-ThreeJS-CubeMap.zip
