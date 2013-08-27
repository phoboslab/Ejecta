precision highp float;

varying highp vec2 vUv;
varying lowp vec4 vColor;

uniform mediump vec3 inner; // x, y, z=radius
uniform mediump vec3 diff; // x, y, z=radius

uniform sampler2D texture;

void main() {
	vec2 p2 = vUv - inner.xy;
	
	float A = dot(diff.xy, diff.xy) - diff.z * diff.z;
	float B = dot(p2.xy, diff.xy) + inner.z * diff.z;
	float C = dot(p2, p2) - (inner.z * inner.z);
	float D = (B * B) - (A * C);
	
	float DA = sqrt(D) / A;
	float BA = B / A;
	
	float t = max(BA+DA, BA-DA);
	
	lowp float keep = sign(diff.z * t + inner.z); // discard if < 0.0
	gl_FragColor = texture2D(texture, vec2(t, 0.0)) * vColor * keep;
}
