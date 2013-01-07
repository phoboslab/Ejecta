varying lowp vec4 vColor;
varying mediump vec2 vUv;

uniform sampler2D texture;
uniform int textureFormat;

#define GL_NONE 0
#define GL_RGBA 0x1908
#define GL_ALPHA 0x1906
#define GL_REPEAT 0x2901

void main() {
	// Splitting this up into several different shaders doesn't seem to make
	// any difference, performance wise.
	
	if( textureFormat == GL_NONE ) { // No texture - Used by vector functions
		gl_FragColor = vColor;
	}
	else if( textureFormat == GL_RGBA ) { // Used by drawImage
		gl_FragColor = texture2D(texture, vUv) * vColor;
	}
	else if( textureFormat == GL_ALPHA ) { // Used by fonts
		gl_FragColor = texture2D(texture, vUv).aaaa * vColor;
	}
	else if( textureFormat == GL_REPEAT ) { // Used by patterns; always RGBA
		gl_FragColor = texture2D(texture, mod(vUv, vec2(1.0, 1.0)) ) * vColor;
	}
}
