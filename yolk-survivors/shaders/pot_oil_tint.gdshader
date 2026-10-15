shader_type canvas_item;
uniform vec2 floor_center = vec2(0.496, 0.513);
uniform vec2 floor_radii = vec2(0.342, 0.328);
uniform vec4 oil_tint : source_color = vec4(0.76, 0.60, 0.35, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.55;
void fragment() {
    float radius = length((UV - floor_center) / floor_radii);
    float mask = 1.0 - smoothstep(0.90, 1.02, radius);
    float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
    vec3 warmed = oil_tint.rgb * luminance * 1.7;
    COLOR.rgb = mix(COLOR.rgb, warmed, mask * tint_strength);
}
