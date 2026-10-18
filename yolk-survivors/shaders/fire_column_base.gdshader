shader_type canvas_item;
render_mode unshaded;
uniform vec4 flame_color : source_color = vec4(1.0,0.18,0.025,1.0);
uniform vec4 core_color : source_color = vec4(1.0,0.87,0.35,1.0);
uniform float elapsed = 0.0;
uniform float fade = 1.0;
uniform float opacity = 0.65;
void fragment() {
	vec2 p = UV*2.0-1.0;
	float r = length(p);
	float a = atan(p.y,p.x);
	float flicker = 0.88+0.12*sin(elapsed*13.0+a*8.0);
	float hot = (1.0-smoothstep(0.0,0.9,r))*0.62;
	float edge = exp(-pow((r-0.86)/0.08,2.0))*flicker;
	float ripple_r = fract(elapsed*2.2)*0.8+0.12;
	float ripple = exp(-pow((r-ripple_r)/0.055,2.0))*(1.0-ripple_r)*0.3;
	float limit = 1.0-smoothstep(0.93,1.0,r);
	vec3 tint = mix(flame_color.rgb,core_color.rgb,clamp(hot+edge*0.85+ripple,0.0,1.0));
	COLOR = vec4(tint,(hot+edge+ripple)*limit*opacity*fade);
}
