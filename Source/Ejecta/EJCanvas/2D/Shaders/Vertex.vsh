attribute vec2 pos;
attribute vec2 uv;
attribute vec4 color;

varying lowp vec4 vColor;
varying highp vec2 vUv;

uniform highp vec2 screen;

void main() {
	vColor = color;
	vUv = uv;
	
	gl_Position = vec4(pos * (vec2(2,2)/screen) - clamp(screen,-1.0,1.0), 0.0, 1.0);
}
