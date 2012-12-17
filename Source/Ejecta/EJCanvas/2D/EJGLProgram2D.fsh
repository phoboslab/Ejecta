varying lowp vec4 colorVarying;
varying mediump vec2 uvVarying;

uniform sampler2D texture;
uniform int textureFormat;

void main() {
	// Splitting this up into several different shaders doesn't seem to make
	// any differen, performance wise.
	if( textureFormat == 0 ) { // No Texture
		gl_FragColor = colorVarying;
	}
	else if( textureFormat == 0x1908 ) { // GL_RGBA
		gl_FragColor = texture2D(texture, uvVarying) * colorVarying;
	}
	else if( textureFormat == 0x1906 ) { // GL_ALPHA
		gl_FragColor = texture2D(texture, uvVarying).aaaa * colorVarying;
	}
}
