shader_type canvas_item;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.32, 0.055, 0.035, 1.0);
void fragment() {
	vec2 p = abs(UV * 2.0 - 1.0);
	float edge = smoothstep(0.28, 1.20, length(p));
	COLOR = vec4(tint.rgb, edge * strength);
}
