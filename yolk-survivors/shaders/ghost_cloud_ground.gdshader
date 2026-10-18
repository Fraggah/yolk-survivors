shader_type canvas_item;
render_mode unshaded;
uniform vec4 tint : source_color = vec4(0.8,0.18,0.15,1.0);
uniform float fade = 1.0;
void fragment() {
	float r = length(UV*2.0-1.0);
	float fog = (1.0-smoothstep(0.3,1.0,r))*0.18;
	COLOR = vec4(tint.rgb,fog*fade*tint.a);
}
