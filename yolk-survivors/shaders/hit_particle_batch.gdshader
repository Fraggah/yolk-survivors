shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;
uniform float elapsed = 0.0;
uniform bool circular = false;
varying vec4 particle_color;
void vertex() {
	float born = INSTANCE_CUSTOM.w;
	float duration = COLOR.a;
	float age = max(0.0, elapsed - born);
	float remaining = clamp(1.0 - age / max(0.00001, duration), 0.0, 1.0);
	float theta = INSTANCE_CUSTOM.z * age;
	mat2 turn = mat2(vec2(cos(theta), sin(theta)), vec2(-sin(theta), cos(theta)));
	vec2 local = turn * VERTEX * (0.65 + 0.35 * remaining);
	VERTEX = (MODEL_MATRIX * vec4(local, 0.0, 1.0)).xy;
	VERTEX += INSTANCE_CUSTOM.xy * (1.0 - exp(-7.0 * age)) / 7.0;
	particle_color = vec4(COLOR.rgb, min(1.0, remaining * 2.0));
	if (duration <= 0.0 || age >= duration) particle_color.a = 0.0;
}
void fragment() {
	COLOR = particle_color;
	if (circular) {
		float radius = length(UV * 2.0 - 1.0);
		float softness = max(fwidth(radius), 0.025);
		COLOR.a *= 1.0 - smoothstep(1.0 - softness, 1.0, radius);
	}
}
