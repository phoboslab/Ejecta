precision mediump float;

varying vec2 vTextureCoord;

uniform sampler2D uSampler;

uniform vec3 uColor;

void main(void) {
    vec4 textureColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
    gl_FragColor = textureColor * vec4(uColor, 1.0);
}