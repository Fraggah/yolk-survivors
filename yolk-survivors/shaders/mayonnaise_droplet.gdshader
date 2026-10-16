shader_type canvas_item;
render_mode unshaded;
void fragment() {
	float distance_from_center = length(UV * 2.0 - 1.0);
	float softness = max(fwidth(distance_from_center), 0.025);
	float coverage = 1.0 - smoothstep(1.0 - softness, 1.0, distance_from_center);
	COLOR.a *= coverage;
}
