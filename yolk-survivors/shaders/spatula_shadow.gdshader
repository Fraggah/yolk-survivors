shader_type canvas_item;
uniform vec4 shadow_color : source_color = vec4(0.12, 0.08, 0.04, 0.52);
void fragment() {
    float silhouette = smoothstep(0.20, 0.60, texture(TEXTURE, UV).a);
    COLOR = vec4(shadow_color.rgb, silhouette * shadow_color.a * COLOR.a);
}
