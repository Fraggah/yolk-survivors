shader_type canvas_item;
render_mode unshaded;
uniform sampler2D flame_texture : source_color, filter_linear, repeat_disable;
uniform float elapsed = 0.0;
uniform float fade = 1.0;
uniform float opacity = 0.85;
uniform float size_pulse = 0.22;
uniform float flicker_speed = 1.0;
uniform float distortion_strength = 0.018;
uniform float distortion_frequency = 38.0;
uniform float distortion_speed = 2.2;
varying float phase;
void vertex() {
	phase = INSTANCE_CUSTOM.r;
	float time = elapsed*flicker_speed;
	float pulse = sin(time*INSTANCE_CUSTOM.g*6.2831853+phase);
	float flip = mod(floor(time/max(0.1,INSTANCE_CUSTOM.b)+phase),2.0) < 1.0 ? 1.0 : -1.0;
	VERTEX.x *= (1.0-pulse*size_pulse*0.45)*flip;
	VERTEX.y *= 1.0+pulse*size_pulse;
}
void fragment() {
	// QuadMesh uses 3D UV orientation; invert Y for upright 2D flame artwork.
	vec2 uv = vec2(UV.x,1.0-UV.y);
	float anchored = 1.0-smoothstep(0.75,1.0,uv.y);
	float wave = sin(uv.y*distortion_frequency-elapsed*distortion_speed*3.0+phase);
	wave += sin(uv.y*distortion_frequency*1.7+elapsed*distortion_speed*2.0+phase*2.0)*0.35;
	uv.x += wave*distortion_strength*anchored;
	uv.y += sin(uv.x*distortion_frequency+elapsed*distortion_speed+phase)*distortion_strength*0.2*anchored;
	vec4 paint = texture(flame_texture,uv);
	COLOR *= vec4(paint.rgb,paint.a*opacity*fade);
}
