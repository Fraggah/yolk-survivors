shader_type canvas_item;
uniform float elapsed=0.0;
uniform vec4 tint: source_color=vec4(1.0,0.32,0.03,1.0);
varying vec4 timing;
void vertex(){timing=INSTANCE_CUSTOM;}
void fragment(){
	vec2 p=(UV-vec2(0.5))*2.0;
	float mask=1.0-smoothstep(0.65,1.0,length(p));
	float pulse=0.8+0.2*sin(p.x*13.0+p.y*7.0+elapsed*5.0);
	float age=elapsed-timing.r;
	float fade=min(clamp(age/max(0.01,timing.b),0.0,1.0),clamp((timing.g-age)/max(0.01,timing.a),0.0,1.0));
	COLOR*=tint;
	COLOR.a*=mask*pulse*fade;
}
