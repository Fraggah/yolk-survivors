shader_type canvas_item;
render_mode unshaded, blend_add;
varying float glow_strength;
void vertex() { glow_strength = INSTANCE_CUSTOM.r; }
void fragment() {
	float edge = abs(UV.y*2.0-1.0);
	float glow = exp(-edge*edge*5.0)*0.24*glow_strength;
	float body = 1.0-smoothstep(0.15,0.27,edge);
	float core = 1.0-smoothstep(0.045,0.10,edge);
	vec3 color = mix(COLOR.rgb,vec3(0.88,0.98,1.0),core);
	COLOR = vec4(color,COLOR.a*(glow+body*0.7+core*0.5));
}
