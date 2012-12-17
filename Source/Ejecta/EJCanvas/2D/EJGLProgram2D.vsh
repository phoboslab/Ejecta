attribute vec2 pos;
attribute vec2 uv;
attribute vec4 color;

varying lowp vec4 colorVarying;
varying mediump vec2 uvVarying;

uniform mediump vec2 scale;
uniform mediump vec2 translate;

void main() {
	colorVarying = color;
	uvVarying = uv;
	
	gl_Position = vec4(pos * scale + translate, 0.0, 1.0);
}
