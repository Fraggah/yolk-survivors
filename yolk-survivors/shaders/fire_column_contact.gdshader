shader_type canvas_item;
render_mode unshaded;
uniform float elapsed = 0.0;
uniform float opacity = 0.95;
uniform float fade = 1.0;
uniform float distortion = 0.06;
uniform float front_start = 0.56;
void fragment() {
	vec2 uv = UV;
	// Only the near half of the painted ring belongs in front of the column.
	float front = smoothstep(front_start,front_start+0.065,UV.y);
	float anchored = 1.0-smoothstep(0.84,1.0,UV.y);
	uv.x += sin(uv.y*32.0-elapsed*7.0)*distortion*0.25*anchored;
	uv.y += sin(uv.x*24.0+elapsed*8.0)*distortion*0.1*anchored;
	vec4 paint = texture(TEXTURE,uv);
	COLOR *= vec4(paint.rgb,paint.a*front*opacity*fade);
}
