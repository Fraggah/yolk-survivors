shader_type canvas_item;
render_mode unshaded;
uniform float phase = 0.0;
uniform float strand_length = 100.0;

void fragment() {
	float x = UV.x;
	float time = phase;
	float drift = sin(x*21.0-time*2.4)*0.035+sin(x*37.0-time*3.1)*0.018;
	float y = abs(UV.y-0.5-drift*x);
	float licks = sin(x*29.0-time*3.6)*0.028+sin(x*47.0-time*2.7)*0.018;
	float width = mix(0.12,0.36,smoothstep(0.0,0.6,x));
	width *= 1.0-smoothstep(0.72,1.0,x)*0.7;
	width += licks*smoothstep(0.0,0.2,x);
	float edge = 1.0-smoothstep(width*0.7,width,y);
	float tail = 1.0-smoothstep(0.76,1.0,x+sin(UV.y*35.0-time*2.1)*0.045);
	// Explicit transparent margins keep the ribbon from exposing a rectangle.
	float border = smoothstep(0.0,0.035,x)*(1.0-smoothstep(0.965,1.0,x));
	border *= smoothstep(0.0,0.05,UV.y)*(1.0-smoothstep(0.95,1.0,UV.y));
	float core = 1.0-smoothstep(width*0.12,width*0.65,y);
	vec3 color = mix(vec3(0.85,0.14,0.035),vec3(1.0,0.57,0.08),core);
	color = mix(color,vec3(1.0,0.88,0.38),core*(1.0-smoothstep(0.15,0.85,x))*0.8);
	COLOR = vec4(color,edge*tail*border*0.95);
}
