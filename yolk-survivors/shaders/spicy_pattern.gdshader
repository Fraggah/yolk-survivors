shader_type canvas_item;
render_mode unshaded;
uniform int mode = 0;
uniform vec4 tint : source_color = vec4(1.0,0.35,0.05,1.0);
uniform float elapsed = 0.0;
uniform float opacity = 0.65;
uniform float progress = 0.0;
uniform bool detonated = false;
void fragment() {
	vec2 p = UV*2.0-1.0;
	float r = length(p);
	float mask = 1.0-smoothstep(0.65,1.0,r);
	float pattern = 0.75+0.25*sin(p.x*12.0+sin(p.y*8.0-elapsed*4.0)*2.0+elapsed*2.0);
	vec3 color = tint.rgb;
	if (mode == 0) {
		float x = fract(UV.x*3.0)-0.5 + sin(UV.y*10.0-elapsed*7.0)*0.06;
		float width = 0.1+UV.y*0.22;
		float tongue = (1.0-smoothstep(width*0.5,width,abs(x)))*smoothstep(0.0,0.2,UV.y)*(1.0-smoothstep(0.85,1.0,UV.y));
		mask *= 0.3+0.7*tongue;
		pattern = 0.9;
		color = mix(tint.rgb,vec3(1.0,0.85,0.2),tongue*0.7);
	} else if (mode == 2) {
		float width = mix(0.65,0.2,UV.y);
		float x = p.x + sin(UV.y*14.0-elapsed*8.0)*0.06;
		mask = (1.0-smoothstep(width*0.7,width,abs(x))) * smoothstep(0.0,0.12,UV.y) * (1.0-smoothstep(0.92,1.0,UV.y));
		pattern = 0.75+0.25*sin(UV.y*38.0+p.x*8.0-elapsed*15.0);
		color = mix(tint.rgb,vec3(1.0,0.85,0.2),(1.0-abs(x)/width)*pattern*0.8);
	} else if (mode == 3) {
		mask *= 0.7+0.3*sin(p.x*5.0+sin(p.y*6.0+elapsed)*2.0);
	} else if (mode == 5 && !detonated) {
		mask = 1.0-smoothstep(0.22,0.3,r);
		pattern = 0.7+0.3*sin(elapsed*6.0);
	} else if (mode == 6 || (mode == 5 && detonated)) {
		float ring = abs(r-max(0.05,progress));
		mask = (1.0-smoothstep(0.025,0.12,ring))*(1.0-progress);
	}
	COLOR = vec4(color, mask*pattern*opacity*tint.a);
}
