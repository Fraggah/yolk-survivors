shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float ray_count = 7.0;
uniform bool burst_mode = false;
varying float across;
varying float glow_strength;

vec2 aura_point(int index, vec2 start, vec2 direction, vec2 tangent, float jitter) {
	if (index==0) return start;
	if (index==1) return start+tangent*5.0+direction*4.0;
	if (index==2) return start+tangent*10.0-direction*(4.0+jitter);
	return start+tangent*16.0+direction*5.0;
}
vec2 burst_point(int index, vec2 direction, vec2 side, float reach, float wobble) {
	if (index==0) return direction*reach*0.12;
	if (index==1) return direction*reach*0.38+side*wobble;
	if (index==2) return direction*reach*0.58-side*wobble;
	if (index==3) return direction*reach*0.78+side*3.0;
	return direction*reach;
}
void vertex() {
	vec2 corner = VERTEX;
	float ray = UV.x;
	int segment = int(UV.y);
	float elapsed = INSTANCE_CUSTOM.z;
	vec2 a;
	vec2 b;
	if (burst_mode) {
		float angle = 6.28318530718*ray/ray_count+0.19;
		vec2 direction = vec2(cos(angle),sin(angle)*0.6);
		vec2 side = vec2(-direction.y,direction.x);
		float reach = INSTANCE_CUSTOM.x*(0.65+INSTANCE_CUSTOM.y*0.65);
		float wobble = sin(ray*13.7+floor(elapsed*35.0)*2.1)*6.0;
		a = burst_point(segment,direction,side,reach,wobble);
		b = burst_point(segment+1,direction,side,reach,wobble);
	} else {
		float frame = floor(elapsed*18.0);
		float angle = 6.28318530718*ray/ray_count+frame*0.17;
		vec2 direction = vec2(cos(angle),sin(angle));
		vec2 tangent = vec2(-direction.y,direction.x);
		vec2 start = direction*INSTANCE_CUSTOM.xy*0.75;
		float jitter = sin(frame*3.1+ray*9.7)*5.0;
		a = aura_point(segment,start,direction,tangent,jitter);
		b = aura_point(segment+1,start,direction,tangent,jitter);
		COLOR.a *= 0.7+0.3*sin(elapsed*35.0+ray);
	}
	vec2 axis = (b-a)/max(0.00001,length(b-a));
	VERTEX = mix(a,b,corner.x)+axis*(corner.x-0.5)*1.5+vec2(-axis.y,axis.x)*corner.y*12.0;
	across = corner.y*2.0;
	glow_strength = INSTANCE_CUSTOM.w;
}
void fragment() {
	float edge = abs(across);
	float glow = exp(-edge*edge*5.0)*0.24*glow_strength;
	float body = 1.0-smoothstep(0.15,0.27,edge);
	float core = 1.0-smoothstep(0.045,0.10,edge);
	vec3 color = mix(COLOR.rgb,vec3(0.88,0.98,1.0),core);
	COLOR = vec4(color,COLOR.a*(glow+body*0.7+core*0.5));
}
