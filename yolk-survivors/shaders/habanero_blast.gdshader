shader_type canvas_item;
render_mode unshaded;
uniform float progress = 0.0;
uniform bool detonated = false;
uniform vec4 heat_color : source_color = vec4(1.0,0.33,0.035,1.0);
uniform vec4 core_color : source_color = vec4(1.0,0.945,0.678,1.0);
uniform vec4 flame_color : source_color = vec4(1.0,0.314,0.114,1.0);
uniform float opacity = 0.75;
uniform float anticipation_opacity = 0.4;
uniform float flame_strength = 1.0;
uniform float variation = 0.0;
void fragment() {
	vec2 p = (UV*2.0-1.0)*1.35;
	float r = length(p);
	float angle = atan(p.y,p.x);
	float t = clamp(progress,0.0,1.0);
	vec3 tint = heat_color.rgb;
	float alpha = 0.0;
	if (!detonated) {
		float gathering = mix(0.75,0.30,t);
		float inward = exp(-pow((r-gathering)/0.10,2.0));
		float heat = exp(-r*r/0.22);
		float flecks = pow(max(0.0,sin(angle*9.0+variation+t*3.0)),12.0);
		alpha = (heat*0.6+inward*(0.22+flecks*0.3))*smoothstep(0.0,0.4,t)*anticipation_opacity;
		tint = mix(heat_color.rgb,core_color.rgb,t*0.22*heat);
	} else {
		float expansion = mix(0.30,0.92,1.0-pow(1.0-t,3.0));
		float lobes = pow(0.5+0.5*sin(angle*9.0+variation-t*7.0),3.0);
		float small_lobes = 0.5+0.5*sin(angle*17.0-variation+t*11.0);
		float fire_edge = expansion + (lobes*0.16+small_lobes*0.045)*(1.0-t)*flame_strength;
		float body = 1.0-smoothstep(fire_edge*0.55,fire_edge,r);
		float contour = exp(-pow((r-fire_edge)/0.065,2.0));
		float outer_glow = exp(-pow((r-fire_edge)/0.17,2.0))*0.25;
		float core = exp(-r*r/max(0.015,expansion*expansion*0.25));
		float flash = exp(-t*8.0);
		float fade = 1.0-smoothstep(0.35,1.0,t);
		alpha = (body*0.65+contour*0.8+outer_glow+core*flash)*fade*opacity;
		tint = mix(flame_color.rgb,heat_color.rgb,body*0.65);
		tint = mix(tint,core_color.rgb,clamp(core*(0.65+flash)+contour*0.22,0.0,1.0));
	}
	COLOR = vec4(tint,clamp(alpha,0.0,1.0)*heat_color.a);
}
