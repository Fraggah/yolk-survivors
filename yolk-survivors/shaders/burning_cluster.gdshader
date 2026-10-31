shader_type canvas_item;
uniform sampler2D flame_texture : source_color, filter_linear_mipmap;
uniform float elapsed = 0.0;
uniform int flame_count : hint_range(2, 12) = 4;
varying vec4 layout;
void vertex() {
	layout = INSTANCE_CUSTOM;
	VERTEX *= layout.xy * 1.25;
}
void fragment() {
	vec2 point = (UV - vec2(0.5)) * layout.xy * 1.25;
	vec4 fire = vec4(0.0);
	for (int i = 0; i < 12; i++) {
		if (i >= flame_count) break;
		float phase = float(i) * 2.399963 + layout.a;
		float height = layout.y * layout.b * (0.8 + 0.2 * sin(phase));
		vec2 anchor = vec2(sin(phase) * layout.x * 0.32,
			layout.y * (0.32 - 0.28 * float(i) / float(flame_count)) - height * 0.45);
		vec2 uv = (point - anchor) / vec2(height, height * 1.25) + vec2(0.5);
		uv.x += (1.0 - uv.y) * sin(uv.y * 12.0 + elapsed * 7.0 + phase) * 0.025;
		if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) {
			vec4 sample_color = texture(flame_texture, uv);
			fire.rgb = sample_color.rgb * sample_color.a + fire.rgb * (1.0 - sample_color.a);
			fire.a = sample_color.a + fire.a * (1.0 - sample_color.a);
		}
	}
	fire.rgb /= max(0.0001, fire.a);
	COLOR *= fire;
}
