// This file is always executed before the App's index.js. It sets up most
// of Ejecta's functionality and emulates some DOM objects.

// Feel free to add more HTML/DOM stuff if you need it.


// Make 'window' the global scope
self = window = this;

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
	userAgent: ej.userAgent,
	appVersion: ej.appVersion,
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


// Timers
window.setTimeout = function(cb, t){ return ej.setTimeout(cb, t); };
window.setInterval = function(cb, t){ return ej.setInterval(cb, t); };
window.clearTimeout = function(id){ return ej.clearTimeout(id); };
window.clearInterval = function(id){ return ej.clearInterval(id); };
window.requestAnimationFrame = function(cb, element){ return ej.setTimeout(cb, 16); };


// The native Image, Audio, HttpRequest and LocalStorage class mimic the real elements
window.Image = Ejecta.Image;
window.Audio = Ejecta.Audio;
window.XMLHttpRequest = Ejecta.HttpRequest;
window.localStorage = new Ejecta.LocalStorage();


// Set up a "fake" HTMLElement
HTMLElement = function( tagName ){ 
	this.tagName = tagName;
	this.children = [];
};

HTMLElement.prototype.appendChild = function( element ) {
	this.children.push( element );
	
	// If the child is a script element, begin to load it
	if( element.tagName == 'script' ) {
		ej.setTimeout( function(){
			ej.require( element.src );
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
		else if( name === 'img' ) {
			return new window.Image();
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
	_publishEvent: function( type, event ) {
		var listeners = this.events[ type ];
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



// Touch events

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

var publishTouchEvent = function( type, all, changed ) {
	touchEvent.touches = all;
	touchEvent.targetTouches = all;
	touchEvent.changedTouches = changed;
	touchEvent.type = type;
	
	document._publishEvent( type, touchEvent );
};
window.document._eventInitializers.touchstart =
	window.document._eventInitializers.touchend =
	window.document._eventInitializers.touchmove = function() {
	if( !touchInput ) {
		touchInput = new Ejecta.TouchInput();
		touchInput.ontouchstart = function( all, changed ){ publishTouchEvent( 'touchstart', all, changed ); };
		touchInput.ontouchend = function( all, changed ){ publishTouchEvent( 'touchend', all, changed ); };
		touchInput.ontouchmove = function( all, changed ){ publishTouchEvent( 'touchmove', all, changed ); };
	}
};



// Devicemotion events

var accelerometer = null;
var deviceMotionEvent = {
	type: 'devicemotion', 
	target: canvas,
	acceleration: {x: 0, y: 0, z: 0},
	accelerationIncludingGravity: {x: 0, y: 0, z: 0},
	preventDefault: function(){},
	stopPropagation: function(){}
};

window.document._eventInitializers.devicemotion = function() {
	if( !accelerometer ) {
		accelerometer = new Ejecta.Accelerometer();
		accelerometer.ondevicemotion = function( x, y, z ){
			deviceMotionEvent.accelerationIncludingGravity.x = x;
			deviceMotionEvent.accelerationIncludingGravity.y = y;
			deviceMotionEvent.accelerationIncludingGravity.z = z;
			document._publishEvent( 'devicemotion', deviceMotionEvent );
		};
	}
};


})(this);
