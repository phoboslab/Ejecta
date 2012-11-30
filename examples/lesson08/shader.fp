precision mediump float;

varying vec2 vTextureCoord;
varying vec3 vLightWeighting;

uniform float uAlpha;

uniform sampler2D uSampler;

void main(void) {
    vec4 textureColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
    gl_FragColor = vec4(textureColor.rgb * vLightWeighting, textureColor.a * uAlpha);
}