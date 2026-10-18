shader_type canvas_item;
render_mode unshaded;
uniform sampler2D ring_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform float elapsed = 0.0;
uniform float opacity = 0.48;
uniform float fade = 1.0;
uniform float center_opacity = 0.28;
uniform float distortion = 0.045;
uniform float flow_speed = 1.8;
uniform sampler2D body_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform float body_height = 800.0;
uniform float body_depth = 30.0;
uniform float body_width = 140.0;
uniform float flare_height = 750.0;
uniform float top_width_multiplier = 2.1;
uniform vec2 column_screen_origin = vec2(0.0);
uniform vec2 column_screen_scale = vec2(1.0);
varying float phase;
void vertex() {
	phase = INSTANCE_CUSTOM.r;
}
void fragment() {
	// QuadMesh UVs are inverted vertically relative to the painted PNG.
	vec2 uv = vec2(UV.x,1.0-UV.y);
	if (mod(floor(phase),2.0)>0.5) { uv.x = 1.0-uv.x; }
	float time = elapsed*flow_speed;
	float anchored = 1.0-smoothstep(0.75,1.0,uv.y);
	uv.x += (sin(uv.y*29.0-time*4.0+phase)+sin(uv.y*47.0+time*3.0+phase)*0.3)*distortion*anchored*0.55;
	uv.y += sin(uv.x*25.0+time*4.0+phase)*distortion*0.16*anchored;
	vec4 paint = texture(ring_texture,uv);
	// Use the same moving silhouette as the continuous body, rather than
	// letting an independently distorted ring hang outside its painted edge.
	vec2 point = (SCREEN_UV/SCREEN_PIXEL_SIZE-column_screen_origin)/column_screen_scale;
	float height = -point.y;
	float body_y = (body_height-body_depth-height)/body_height;
	float scale_x = mix(1.0,top_width_multiplier,pow(clamp(max(0.0,height)/max(1.0,flare_height),0.0,1.0),0.8));
	vec2 body_uv = vec2(point.x/(body_width*scale_x)+0.5,body_y);
	body_uv.x += (sin(body_y*19.0-time*1.8)*0.65+sin(body_y*33.0+time*1.2)*0.35)*distortion;
	body_uv.y = body_y*0.8+0.1+sin(time*0.65)*0.075;
	float body_mask = smoothstep(0.05,0.55,texture(body_texture,body_uv).a);
	body_mask *= step(0.0,body_y)*step(body_y,1.0);
	float tip = 0.04+0.08*(0.5+0.5*sin(body_uv.x*37.0+sin(time*0.8)))+0.035*(0.5+0.5*sin(body_uv.x*73.0-time*1.2));
	body_mask *= smoothstep(tip,tip+0.035,body_y);
	float flicker = 0.9+0.1*sin(time*5.0+phase);
	COLOR *= vec4(paint.rgb,paint.a*body_mask*opacity*fade*flicker*mix(center_opacity,1.0,smoothstep(0.15,0.85,abs(UV.x-0.5)*2.0)));
}
