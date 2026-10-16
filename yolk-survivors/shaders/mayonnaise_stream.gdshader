shader_type canvas_item;
render_mode unshaded;
uniform vec4 mayo_color : source_color = vec4(1.0, 0.94, 0.75, 1.0);
uniform vec4 core_color : source_color = vec4(1.0, 0.99, 0.94, 1.0);
uniform vec4 edge_color : source_color = vec4(0.77, 0.71, 0.53, 1.0);
uniform float phase = 0.0;
uniform float strand_length = 100.0;

void fragment() {
	float flow = UV.x * strand_length * 0.09 - phase;
	float thickness = 0.85 + 0.08 * sin(flow) + 0.055 * sin(flow * 1.73 + 1.2);
	float edge = abs(UV.y * 2.0 - 1.0) / thickness;
	float alpha = 1.0 - smoothstep(0.86, 1.0, edge);
	float center = 1.0 - smoothstep(0.1, 0.72, edge);
	vec3 cream = mix(edge_color.rgb, mayo_color.rgb, 1.0 - smoothstep(0.55, 0.95, edge));
	cream = mix(cream, core_color.rgb, center * (0.85 + 0.1 * sin(flow * 0.65)));
	COLOR = vec4(cream, alpha * mayo_color.a);
}
