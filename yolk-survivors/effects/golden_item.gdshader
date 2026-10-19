shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.55;
uniform bool perfect = false;
uniform bool overlay = false;

void fragment() {
	vec4 original = texture(TEXTURE, UV) * COLOR;
	float band = pow(max(0.0, sin((UV.x + UV.y * 0.55) * 11.0 - TIME * 2.6)), 12.0);
	float pulse = 0.14 + 0.07 * sin(TIME * 2.1);
	vec3 gold = vec3(1.0, 0.72, 0.16);
	float shimmer = strength * (pulse + band * 0.65);
	float stars = pow(max(0.0, sin(UV.x * 39.0 + TIME * 1.3) * sin(UV.y * 31.0 - TIME * 1.7)), 30.0);
	vec3 tint = mix(original.rgb, gold, shimmer);
	if (perfect) tint += vec3(1.0, 0.88, 0.5) * stars * 0.8;
	COLOR = vec4(tint, original.a * (overlay ? min(0.85, shimmer + stars * float(perfect)) : 1.0));
}
