shader_type canvas_item;
render_mode unshaded;
uniform sampler2D cloud_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform float elapsed = 0.0;
uniform float fade = 1.0;
uniform float opacity = 0.62;
uniform float distortion = 0.018;
uniform float billow_speed = 0.65;
varying float phase;
varying float mirror;
void vertex() { phase = INSTANCE_CUSTOM.r; mirror = INSTANCE_CUSTOM.g; }
void fragment() {
	vec2 uv = vec2(UV.x,1.0-UV.y);
	if (mirror>0.5) { uv.x = 1.0-uv.x; }
	float time = elapsed*billow_speed;
	uv.x += sin(uv.y*13.0+time*1.7+phase)*distortion;
	uv.y += sin(uv.x*15.0-time*1.4+phase)*distortion*0.55;
	vec4 paint = texture(cloud_texture,uv);
	COLOR *= vec4(paint.rgb,pow(paint.a,1.25)*opacity*fade*(0.82+0.18*sin(uv.x*5.0+uv.y*7.0+time+phase)));
}
