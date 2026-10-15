shader_type canvas_item;
render_mode unshaded;
uniform vec4 heat_color : source_color = vec4(1.0, 0.31, 0.08, 1.0);
uniform float opacity = 0.22;
uniform float elapsed = 0.0;
uniform float breathing_speed = 2.0;
uniform float breathing_strength = 0.2;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float radius = length(p);
	float edge = 1.0 - smoothstep(0.55, 1.0, radius);
	float wisps = 0.82 + 0.18 * sin(p.x * 11.0 + sin(p.y * 7.0 + elapsed) * 2.0 + elapsed * 0.7);
	float breath = 1.0 - breathing_strength * 0.5 + sin(elapsed * breathing_speed) * breathing_strength * 0.5;
	COLOR = vec4(heat_color.rgb, heat_color.a * opacity * edge * wisps * breath);
}
