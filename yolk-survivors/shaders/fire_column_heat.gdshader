shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float elapsed = 0.0;
uniform float fade = 1.0;
uniform float opacity = 0.85;
uniform float strength_pixels = 8.0;
uniform float world_height = 800.0;
uniform float flare_height = 750.0;
uniform float top_width_multiplier = 2.1;
uniform float base_depth = 0.0;
void vertex() {
	VERTEX.x *= top_width_multiplier;
}
void fragment() {
	vec2 p = UV*2.0-1.0;
	float height = max(0.0,(1.0-UV.y)*world_height-base_depth);
	float flare = pow(clamp(height/max(1.0,flare_height),0.0,1.0),0.8);
	p.x *= top_width_multiplier/mix(1.0,top_width_multiplier,flare);
	float time = elapsed;
	float sides = exp(-pow((abs(p.x)-0.57)/0.25,2.0));
	float vertical = smoothstep(0.0,0.03,UV.y)*(1.0-smoothstep(0.94,1.0,UV.y));
	float mask = sides*vertical*opacity*fade;
	float flow = UV.y*world_height*0.035;
	vec2 wave = vec2(sin(flow-time*7.0+p.x*4.0)+sin(flow*1.73-time*4.0)*0.35, cos(flow*0.83-time*5.0+p.x*6.0)*0.45);
	vec2 offset = wave*SCREEN_PIXEL_SIZE*strength_pixels*mask;
	vec3 scene = texture(screen_texture,SCREEN_UV+offset).rgb;
	COLOR = vec4(scene,mask);
}
