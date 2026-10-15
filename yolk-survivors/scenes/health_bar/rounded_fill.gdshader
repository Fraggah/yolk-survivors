shader_type canvas_item;
uniform vec2 bar_size = vec2(320.0,48.0);
uniform float ratio : hint_range(0.0,1.0) = 1.0;
uniform float radius = 24.0;
uniform float inset = 5.0;
uniform vec4 fill_color : source_color = vec4(0.9,0.3,0.35,1.0);
float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q,vec2(0.0))) + min(max(q.x,q.y),0.0) - r;
}
void fragment() {
	vec2 inner_size = max(bar_size-vec2(inset*2.0),vec2(1.0));
	vec2 point = UV * bar_size-vec2(inset);
	float r = min(max(0.0,radius-inset),min(inner_size.x,inner_size.y)*0.5);
	float outer = rounded_box(point-inner_size*0.5,inner_size*0.5,r);
	float width = inner_size.x * ratio;
	vec2 half_fill = vec2(width,inner_size.y)*0.5;
	float filled = rounded_box(point-half_fill,half_fill,min(r,width*0.5));
	float mask = 1.0-smoothstep(-0.6,0.6,max(outer,filled));
	COLOR = vec4(fill_color.rgb,fill_color.a*mask*step(0.0001,ratio));
}
