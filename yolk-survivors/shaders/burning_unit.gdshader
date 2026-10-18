shader_type canvas_item;
render_mode unshaded;
uniform vec4 heat_color : source_color = vec4(1.0,0.35,0.05,1.0);
uniform vec4 core_color : source_color = vec4(1.0,0.82,0.416,1.0);
uniform float elapsed = 0.0;
uniform float variation = 0.0;
uniform float fade = 1.0;
uniform float flicker_speed = 1.0;
uniform int ember_count = 16;
uniform float ember_size = 0.008;
uniform float ember_opacity = 0.65;
uniform float heat_opacity = 0.16;
uniform bool coverage_enabled = false;
uniform int coverage_count = 0;
uniform vec2 coverage_extents[6];
uniform float coverage_weights[6];
float coverage_at(vec2 point) {
	if (!coverage_enabled) { return 1.0; }
	float density = 0.0;
	for (int i = 0; i < 6; i++) {
		if (i >= coverage_count) { break; }
		density += (1.0 - smoothstep(0.82, 1.0, length(point / max(coverage_extents[i], vec2(0.001))))) * coverage_weights[i];
	}
	return min(density, 1.0) * (1.0 + max(density - 1.0, 0.0) * 0.14);
}
void fragment() {
	vec2 p = UV;
	float time = elapsed*flicker_speed;
	float embers = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i >= ember_count) { break; }
		float seed = float(i);
		float cycle = time*mix(0.6,1.1,fract(seed*0.41421))+seed*0.618034;
		float age = fract(cycle);
		float x = mix(0.2,0.8,fract(seed*0.754877+floor(cycle)*0.37+variation));
		vec2 center = vec2(x+sin(age*5.0+seed)*0.04,0.76-age*0.65);
		float size = ember_size*mix(0.5,1.5,fract(seed*0.56984));
		float life = smoothstep(0.0,0.12,age)*(1.0-smoothstep(0.5,1.0,age));
		embers += exp(-pow(length((p-center)*vec2(1.0,0.7))/size,2.0))*life*coverage_at(vec2((x-0.5)*2.0,0.0));
	}
	vec2 aura_p = (p-vec2(0.5,0.80))/vec2(0.43,0.14);
	float aura = exp(-dot(aura_p,aura_p)*2.0)*heat_opacity*(0.85+0.15*sin(time*4.0+variation));
	aura *= coverage_at((p-vec2(0.5,0.80))*2.0);
	float alpha = 1.0-(1.0-clamp(embers*ember_opacity,0.0,1.0))*(1.0-aura);
	vec3 tint = mix(heat_color.rgb,core_color.rgb,clamp(embers*0.4,0.0,0.8));
	COLOR = vec4(tint,alpha*fade*heat_color.a);
}
