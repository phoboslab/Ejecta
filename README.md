# Ejecta

Ejecta is a fast, open source JavaScript, Canvas & Audio implementation for iOS. Think of it as a Browser that can only display a Canvas element.

More info & Documentation: http://impactjs.com/ejecta

Ejecta is published under the [MIT Open Source License](http://opensource.org/licenses/mit-license.php).


## Recent Breaking Changes

### 2015-12-12 - Use OS provided JavaScriptCore library 

Since https://github.com/phoboslab/Ejecta/commit/08741b4489ff945b117ebee0333c7eb7a6177c2e Ejecta uses the JSC lib provided by iOS and tvOS instead of bundling a custom fork it. This mainly means two things: The resulting binary will be much smaller and Typed Arrays are much slower.

This only affects WebGL and the `get/setImageData()` functions for Canvas2D. Some tests indicate that the performance is still good enough for most WebGL games. On 64bit systems it's highly optimized to take about 7ms/Megabyte for reading and about 20ms/Megabyte for writing. It's much slower on 32bit systems, though.

More info about this change can be found [in my blog](http://phoboslab.org/log/2015/11/the-absolute-worst-way-to-read-typed-array-data-with-javascriptcore). Please comment on [this Webkit bug](https://bugs.webkit.org/show_bug.cgi?id=120112) if you want to have fast Typed Array support again.

### 2015-11-27 – Allowed orientation change

Allowed interface orientations should now be set using the "Device Orientation" checkboxes in the Project's General settings. Ejecta now rotates to all allowed orientations automatically. If the window size changes due to a rotation (i.e. when rotating from landscape to portrait or vice versa), the window's `resize` event is fired.

```javascript
window.addEventListener('resize', function() {
	// Resize your screen canvas here if needed.
	console.log('new window size:', window.innerWidth, window.innerHeight);
});
```

### 2015-11-09 - Moved Antialias (MSAA) settings to getContext options

The `canvas.MSAAEnabled` and `canvas.MSAASamples` properties have been removed. Instead, you can now specify antialias settings in a separate options object when calling `getContext()`, similar to how it works in a browser. Antialias now works on 2D and WebGL contexts.

Note that for 2D contexts antialias will have no effect when drawing images, other than slowing down performance. It only makes sense to enable antialias if you draw shapes and paths.

```javascript
var gl = canvas.getContext('webgl', {antialias: true, antialiasSamples: 4});

// Or for 2d contexts

var ctx = canvas.getContext('2d', {antialias: true, antialiasSamples: 4});
```

### 2015-11-08 - Removed automatic pixel doubling for retina devices

The Canvas' backing store is now exactly the same size as the `canvas.width` and `canvas.height`. Ejecta *does not* automatically double the internal resolution on retina devices anymore. The `ctx.backingStorePixelRatio` and `canvas.retinaResolutionEnabled` properties as well as the `HD` variants for the `ctx.getImageData`, `ctx.putImageData` and `ctx.createImageData` functions have been removed.

You can of course still render in retina resolution, by setting the `width` and `height` to the retina resolution while forcing the `style` to scale the canvas to the logical display resolution. This is in line with current browsers.

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
