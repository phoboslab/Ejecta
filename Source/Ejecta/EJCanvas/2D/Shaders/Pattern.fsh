varying lowp vec4 vColor;
varying highp vec2 vUv;

uniform sampler2D texture;

void main() {
	gl_FragColor = texture2D(texture, mod(vUv, vec2(1.0, 1.0)) ) * vColor;
}
