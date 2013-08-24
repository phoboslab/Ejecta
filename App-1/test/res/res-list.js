
"use strict";

Config.resList = [];

(function() {
	var list = [
	{ id : "stars" , src : "res/stars.png" },
	{ id : "brushes" , src : "res/Brushes256.png" },
	{ id : "p1" , src : "res/pallete5.png" },
	{ id : "p2" , src : "res/pallete5b.png" },
		
	// { id : "bg" , src : "res/image/bg2.png" },
	// { id : "player-up" , src : "res/image/1.png" },
	// { id : "player-down" , src : "res/image/2.png" },
	// { id : "enemy-0" , src : "res/image/enemy-0.png" },
	// { id : "enemy-1" , src : "res/image/enemy-1.png" },
	// { id : "block-0" , src : "res/image/block-0.png" },
	// { id : "block-1" , src : "res/image/block-1.png" },
	// { id : "bomb" , src : "res/image/bomb.png" },
	// {id : "crack", type : "media", src : "res/sound/crack.mp3"},


	];

	list.forEach(function(r) {
		Config.resList.push(r);
	});

	
}());

