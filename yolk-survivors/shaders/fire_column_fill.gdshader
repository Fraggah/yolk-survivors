shader_type canvas_item;
render_mode unshaded;
uniform float elapsed = 0.0;
uniform float opacity = 0.96;
uniform float fade = 1.0;
uniform float distortion = 0.025;
uniform float flow_speed = 1.8;
uniform float base_roundness = 0.05;
uniform float world_height = 800.0;
uniform float base_depth = 0.0;
uniform float flare_height = 750.0;
uniform float top_width_multiplier = 2.1;
void vertex() {
	// Keep a rectangle: tapering its four vertices skews UV interpolation
	// across the diagonal and makes the painted body drift off its axis.
	VERTEX.x *= top_width_multiplier;
}
void fragment() {
	vec2 uv = UV;
	float time = elapsed*flow_speed;
	float height = max(0.0,(1.0-UV.y)*world_height-base_depth);
	float flare = pow(clamp(height/max(1.0,flare_height),0.0,1.0),0.8);
	float width = mix(1.0,top_width_multiplier,flare);
	uv.x = (UV.x-0.5)*top_width_multiplier/width+0.5;
	// One continuous full-height image: no vertical tiling or wrap seam.
	uv.x += (sin(UV.y*19.0-time*1.8)*0.65+sin(UV.y*33.0+time*1.2)*0.35)*distortion;
	uv.y = UV.y*0.8+0.1+sin(time*0.65)*0.075;
	vec4 paint = texture(TEXTURE,uv);
	float x = clamp((uv.x-0.5)/0.36,-1.0,1.0);
	float bottom = 1.0-base_roundness*(1.0-sqrt(max(0.0,1.0-x*x)));
	float mask = 1.0-smoothstep(bottom-0.006,bottom,UV.y);
	float tip = 0.04+0.08*(0.5+0.5*sin(uv.x*37.0+sin(time*0.8)))+0.035*(0.5+0.5*sin(uv.x*73.0-time*1.2));
	mask *= smoothstep(tip,tip+0.035,UV.y);
	COLOR *= vec4(paint.rgb,paint.a*opacity*fade*mask);
}
