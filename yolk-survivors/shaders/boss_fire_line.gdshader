shader_type canvas_item;
render_mode unshaded;
uniform float phase = 0.0;
uniform float flash : hint_range(0.0,1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0,0.58,0.12,1.0);
uniform float world_length = 1000.0;
void fragment() {
	float x = UV.x * world_length / 38.0;
	float drift = sin(x * 2.1 - phase * 5.0) * 0.035 + sin(x * 4.7 + phase * 3.0) * 0.025;
	float y = abs(UV.y - 0.5 - drift);
	float licks = 0.28 + sin(x * 3.6 - phase * 6.0) * 0.055 + sin(x * 6.3 + phase * 4.0) * 0.025;
	float flame = 1.0 - smoothstep(licks * 0.6, licks, y);
	float core = 1.0 - smoothstep(0.06,0.19,y);
	float hot = 1.0 - smoothstep(0.01,0.08,y);
	vec3 color = mix(vec3(0.75,0.08,0.018),vec3(1.0,0.48,0.045),core);
	color = mix(color,vec3(1.0,0.86,0.33),hot * 0.9);
	color = mix(color,flash_color.rgb,flash*0.45);
	float ends = smoothstep(0.0,0.005,UV.x) * (1.0 - smoothstep(0.995,1.0,UV.x));
	COLOR = vec4(color, flame * ends);
}
