shader_type spatial;

uniform vec3 scale = vec3(2.0);
uniform float width: hint_range(0.0, 10.0) = 0.25;
uniform float sharpness: hint_range(0.0, 1.0) = 0.5;
uniform float glow: hint_range(1.0, 16.0) = 4.0;
uniform vec4 color = vec4(1.0);
uniform sampler2D tex;

varying vec3 vert;
varying vec3 normal;

void vertex(){
	VERTEX += sign(VERTEX) * (scale - 1.0) * 0.5;

	vert = VERTEX;
	normal = abs(NORMAL);
}

void fragment(){
	ALPHA = 0.5;
	vec3 fv = fract(vec3(vert.x, vert.y * -1.0, vert.z));
	vec3 vs = abs(vert) - scale * 0.5;
	float ws = width * sharpness;
	vec3 result = (texture(tex, fv.zy).rgb * normal.x + texture(tex, fv.xz).rgb * normal.y + texture(tex, fv.xy).rgb * normal.z) * float(width < length(vs.xy)) * float(width < length(vs.yz)) * float(width < length(vs.xz));
	if (result.x > 0.1) {
		ALPHA = 0.;
	}
	ALBEDO = result;
}