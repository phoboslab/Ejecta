varying lowp vec4 vColor;
varying highp vec2 vUv;

uniform sampler2D texture;
uniform mediump vec4 tintAdd;
uniform mediump vec4 tintMul;

void main() {
    gl_FragColor = (texture2D(texture, vUv) * tintMul + tintAdd * texture2D(texture, vUv).a) * vColor;
}
