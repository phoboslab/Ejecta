attribute vec2 pos;
attribute vec2 uv;
attribute vec4 color;

varying lowp vec4 vColor;
varying mediump vec2 vUv;

uniform mediump vec2 scale;
uniform mediump vec2 translate;

void main() {
	vColor = color;
	vUv = uv;
	
	gl_Position = vec4(pos * scale + translate, 0.0, 1.0);
}
