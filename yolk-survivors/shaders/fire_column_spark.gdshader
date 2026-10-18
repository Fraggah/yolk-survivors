shader_type canvas_item;
render_mode unshaded;
void fragment() {
	vec2 p = UV*2.0-1.0;
	float r2 = dot(p,p);
	float core = exp(-r2*12.0);
	float ember = exp(-r2*4.0);
	float glow = exp(-r2*1.7)*0.17;
	float edge = 1.0-smoothstep(0.7,1.0,length(p));
	vec3 tint = mix(COLOR.rgb,vec3(1.0,0.97,0.65),core*0.8);
	COLOR = vec4(tint,clamp(core+ember*0.65+glow,0.0,1.0)*edge*COLOR.a);
}
