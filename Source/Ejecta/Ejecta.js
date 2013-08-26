// This file is always executed before the App's index.js. It sets up most
// of Ejecta's functionality and emulates some DOM objects.

// Feel free to add more HTML/DOM stuff if you need it.


// Make 'window' the global scope
self = window = this;
window.top = window.parent = window;

(function(window) {

// The 'ej' object provides some basic info and utility functions
var ej = window.ejecta = new Ejecta.EjectaCore();

// Set up the screen properties and useragent
window.devicePixelRatio = ej.devicePixelRatio;
window.innerWidth = ej.screenWidth;
window.innerHeight = ej.screenHeight;

window.screen = {
	availWidth: window.innerWidth,
	availHeight: window.innerHeight
};

window.navigator = {
	language: ej.language,
	userAgent: ej.userAgent,
	appVersion: ej.appVersion,
	platform: ej.platform,
	get onLine() { return ej.onLine; } // re-evaluate on each get
};

// Create the default screen canvas
window.canvas = new Ejecta.Canvas();
window.canvas.type = 'canvas';
window.canvas.style = {};

// The console object
window.console = {
	log: function() {
		var args = Array.prototype.join.call(arguments, ', ');
		ej.log( args );
	},
	
	assert: function() {
		var args = Array.prototype.slice.call(arguments);
		var assertion = args.shift();
		if( !assertion ) {
			ej.log( 'Assertion failed: ' + args.join(', ') );
		}
	}
};
window.console.debug =
	window.console.info =
	window.console.warn =
	window.console.error =
	window.console.log;

// CommonJS style require()
var loadedModules = {};
window.require = function( name ) {
	var id = name.replace(/\.js$/,'');
	if( !loadedModules[id] ) {
		var exports = {};
		var module = { id: id, uri: id + '.js', exports: exports };
		ejecta.requireModule( id, module, exports );
		// Some modules override module.exports, so use the module.exports reference only after loading the module
		loadedModules[id] = module.exports;
	}
	
	return loadedModules[id];
};

// Timers
window.performance = {now: function() {return ej.performanceNow();} };
window.setTimeout = function(cb, t){ return ej.setTimeout(cb, t); };
window.setInterval = function(cb, t){ return ej.setInterval(cb, t); };
window.clearTimeout = function(id){ return ej.clearTimeout(id); };
window.clearInterval = function(id){ return ej.clearInterval(id); };
window.requestAnimationFrame = function(cb, element){
	return ej.setTimeout(function(){ cb(ej.performanceNow()); }, 16);
};



// The native Image, Audio, HttpRequest and LocalStorage class mimic the real elements
window.Image = Ejecta.Image;
window.Audio = Ejecta.Audio;
window.Video = Ejecta.Video;
window.XMLHttpRequest = Ejecta.HttpRequest;
window.localStorage = new Ejecta.LocalStorage();
window.WebSocket = Ejecta.WebSocket;


// Set up a "fake" HTMLElement
HTMLElement = function( tagName ){ 
	this.tagName = tagName;
	this.children = [];
	this.style = {};
};

HTMLElement.prototype.appendChild = function( element ) {
	this.children.push( element );
	
	// If the child is a script element, begin to load it
	if( element.tagName == 'script' ) {
		ej.setTimeout( function(){
			ej.include( element.src );
			if( element.onload ) {
				element.onload();
			}
		}, 1);
	}
};


// The document object
window.document = {
	location: { href: 'index' },
	
	head: new HTMLElement( 'head' ),
	body: new HTMLElement( 'body' ),
	
	events: {},
	
	createElement: function( name ) {
		if( name === 'canvas' ) {
			var canvas = new Ejecta.Canvas();
			canvas.type = 'canvas';
			canvas.style = {};
			return canvas;
		}
		else if( name == 'audio' ) {
			return new Ejecta.Audio();
		}
		else if( name == 'video' ) {
			return new Ejecta.Video();
		}
		else if( name === 'img' ) {
			return new window.Image();
		}
		else if (name === 'input' || name === 'textarea') {
  			return new Ejecta.KeyInput();
 		}
		return new HTMLElement( name );
	},
	
	getElementById: function( id ){
		if( id === 'canvas' ) {
			return window.canvas;
		}
		return null;
	},
	
	getElementsByTagName: function( tagName ) {
		if( tagName === 'head' ) {
			return [document.head];
		}
		else if( tagName === 'body' ) {
			return [document.body];
		}
		return [];
	},
	
	addEventListener: function( type, callback, useCapture ){
		if( type == 'DOMContentLoaded' ) {
			ej.setTimeout( callback, 1 );
			return;
		}
		if( !this.events[type] ) {
			this.events[type] = [];
			
			// call the event initializer, if this is the first time we
			// bind to this event.
			if( typeof(this._eventInitializers[type]) == 'function' ) {
				this._eventInitializers[type]();
			}
		}
		this.events[type].push( callback );
	},
	
	removeEventListener: function( type, callback ) {
		var listeners = this.events[ type ];
		if( !listeners ) { return; }
		
		for( var i = listeners.length; i--; ) {
			if( listeners[i] === callback ) {
				listeners.splice(i, 1);
			}
		}
	},
	
	_eventInitializers: {},
	dispatchEvent: function( event ) {
		var listeners = this.events[ event.type ];
		if( !listeners ) { return; }
		
		for( var i = 0; i < listeners.length; i++ ) {
			listeners[i]( event );
		}
	}
};
window.canvas.addEventListener = window.addEventListener = function( type, callback ) { 
	window.document.addEventListener(type,callback); 
};
window.canvas.removeEventListener = window.removeEventListener = function( type, callback ) { 
	window.document.removeEventListener(type,callback); 
};

var eventInit = document._eventInitializers;



// Touch events

// Set touch event properties for feature detection
window.ontouchstart = window.ontouchend = window.ontouchmove = null;

// Setting up the 'event' object for touch events in native code is quite
// a bit of work, so instead we do it here in JavaScript and have the native
// touch class just call a simple callback.
var touchInput = null;
var touchEvent = {
	type: 'touchstart', 
	target: canvas,
	touches: null,
	targetTouches: null,
	changedTouches: null,
	preventDefault: function(){},
	stopPropagation: function(){}
};

var dispatchTouchEvent = function( type, all, changed ) {
	touchEvent.touches = all;
	touchEvent.targetTouches = all;
	touchEvent.changedTouches = changed;
	touchEvent.type = type;
	
	document.dispatchEvent( touchEvent );
};
eventInit.touchstart = eventInit.touchend = eventInit.touchmove = function() {
	if( touchInput ) { return; }

	touchInput = new Ejecta.TouchInput();
	touchInput.ontouchstart = function( all, changed ){ dispatchTouchEvent( 'touchstart', all, changed ); };
	touchInput.ontouchend = function( all, changed ){ dispatchTouchEvent( 'touchend', all, changed ); };
	touchInput.ontouchmove = function( all, changed ){ dispatchTouchEvent( 'touchmove', all, changed ); };
};



// DeviceMotion and DeviceOrientation events

var deviceMotion = null;
var deviceMotionEvent = {
	type: 'devicemotion', 
	target: canvas,
	interval: 16,
	acceleration: {x: 0, y: 0, z: 0},
	accelerationIncludingGravity: {x: 0, y: 0, z: 0},
	rotationRate: {alpha: 0, beta: 0, gamma: 0},
	preventDefault: function(){},
	stopPropagation: function(){}
};

var deviceOrientationEvent = {
	type: 'deviceorientation', 
	target: canvas,
	alpha: null,
	beta: null,
	gamma: null,
	absolute: true,
	preventDefault: function(){},
	stopPropagation: function(){}
};

eventInit.deviceorientation = eventInit.devicemotion = function() {
	if( deviceMotion ) { return; }
	
	deviceMotion = new Ejecta.DeviceMotion();
	deviceMotionEvent.interval = deviceMotion.interval;
	
	// Callback for Devices that have a Gyro
	deviceMotion.ondevicemotion = function( agx, agy, agz, ax, ay, az, rx, ry, rz, ox, oy, oz ) {
		deviceMotionEvent.accelerationIncludingGravity.x = agx;
		deviceMotionEvent.accelerationIncludingGravity.y = agy;
		deviceMotionEvent.accelerationIncludingGravity.z = agz;
	
		deviceMotionEvent.acceleration.x = ax;
		deviceMotionEvent.acceleration.y = ay;
		deviceMotionEvent.acceleration.z = az;

		deviceMotionEvent.rotationRate.alpha = rx;
		deviceMotionEvent.rotationRate.beta = ry;
		deviceMotionEvent.rotationRate.gamma = rz;

		document.dispatchEvent( deviceMotionEvent );


		deviceOrientationEvent.alpha = ox;
		deviceOrientationEvent.beta = oy;
		deviceOrientationEvent.gamma = oz;

		document.dispatchEvent( deviceOrientationEvent );
	};
	
	// Callback for Devices that only have an accelerometer
	deviceMotion.onacceleration = function( agx, agy, agz ) {
		deviceMotionEvent.accelerationIncludingGravity.x = agx;
		deviceMotionEvent.accelerationIncludingGravity.y = agy;
		deviceMotionEvent.accelerationIncludingGravity.z = agz;
	
		deviceMotionEvent.acceleration = null;
		deviceMotionEvent.rotationRate = null;
	
		document.dispatchEvent( deviceMotionEvent );
	}
};



// Window events (resize/pagehide/pageshow)

var windowEvents = null;

var lifecycleEvent = {
	type: 'pagehide',
	target: window.document,
	preventDefault: function(){},
	stopPropagation: function(){}
};

var resizeEvent = {
	type: 'resize',
	target: window,
	preventDefault: function(){},
	stopPropagation: function(){}
};

eventInit.pagehide = eventInit.pageshow = eventInit.resize = function() {
	if( windowEvents ) { return; }
	
	windowEvents = new Ejecta.WindowEvents();
	
	windowEvents.onpagehide = function() {
		lifecycleEvent.type = 'pagehide';
		document.dispatchEvent( lifecycleEvent );
	};
	windowEvents.onpageshow = function() {
		lifecycleEvent.type = 'pageshow';
		document.dispatchEvent( lifecycleEvent );
	};

	windowEvents.onresize = function() {
		window.innerWidth = ej.screenWidth;
		window.innerHeight = ej.screenHeight;
		document.dispatchEvent(resizeEvent);
	};
};

})(this);
