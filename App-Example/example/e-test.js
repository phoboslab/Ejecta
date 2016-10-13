console.log("This is e-test.js");


var img = new Image();
console.log("HTMLImageElement: ", img instanceof HTMLImageElement);

var canvas = document.createElement("canvas");
console.log("HTMLCanvasElement: ", canvas instanceof HTMLCanvasElement);

var video = new Video();
console.log("HTMLVideoElement: ", video instanceof HTMLVideoElement);

var audio = new Audio();
console.log("HTMLAudioElement: ", audio instanceof HTMLAudioElement);
