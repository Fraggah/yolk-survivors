shader_type canvas_item;
render_mode unshaded;
void fragment() {
	vec2 p = UV*2.0-1.0;
	float core = exp(-dot(p,p)*5.0);
	float edge = 1.0-smoothstep(0.5,1.0,length(p));
	COLOR = vec4(COLOR.rgb,core*edge*COLOR.a);
}
