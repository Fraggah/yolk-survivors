shader_type canvas_item;
render_mode unshaded;
uniform vec4 heat_color : source_color = vec4(1.0, 0.31, 0.08, 1.0);
uniform vec4 ember_color : source_color = vec4(1.0, 0.455, 0.208, 1.0);
uniform float opacity = 0.22;
uniform float elapsed = 0.0;
uniform float breathing_speed = 2.0;
uniform float breathing_strength = 0.2;
uniform int orbit_particle_count = 16;
uniform float orbit_speed = 0.65;
uniform float orbit_particle_size = 0.025;
uniform float orbit_opacity = 0.4;
uniform float ring_opacity = 0.25;
uniform int central_particle_count = 24;
uniform float central_particle_size = 0.008;
uniform float central_travel = 0.14;
uniform float central_lifetime = 0.9;
uniform float central_opacity = 0.45;

uniform int coverage_count = 0;
uniform vec2 coverage_extents[6];
float coverage_at(vec2 point) {
	if (coverage_count == 0) { return 1.0; }
	float density = 0.0;
	for (int i = 0; i < 6; i++) {
		if (i >= coverage_count) { break; }
		density += 1.0 - smoothstep(0.84, 1.0, length(point / max(coverage_extents[i], vec2(0.001))));
	}
	return density;
}
void fragment() {
	// The rectangular surface projects all radial shapes onto the damage oval.
	vec2 p = UV * 2.0 - 1.0;
	float radius = length(p);
	float breath = 1.0 - breathing_strength * 0.5 + sin(elapsed * breathing_speed) * breathing_strength * 0.5;
	float fill = (1.0 - smoothstep(0.15, 1.0, radius)) * opacity * breath * 0.65;
	float rim = exp(-pow((radius - 0.80) / 0.085, 2.0)) * ring_opacity * breath;
	float inner_rim = exp(-pow((radius - 0.57) / 0.045, 2.0)) * ring_opacity * 0.22;
	float glow = 0.0;
	float cores = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i >= orbit_particle_count) { break; }
		float seed = float(i);
		float lane = mix(0.58, 0.86, fract(seed * 0.6180339));
		float speed = orbit_speed * mix(0.75, 1.25, fract(seed * 0.381966));
		float angle = seed * 2.399963 + elapsed * speed;
		float size = orbit_particle_size * mix(0.7, 1.3, fract(seed * 0.754877));
		float twinkle = 0.72 + 0.28 * sin(elapsed * 3.0 + seed * 1.7);
		vec2 center = vec2(cos(angle), sin(angle)) * lane;
		float d = length(p - center);
		cores += exp(-pow(d / size, 2.0)) * twinkle;
		glow += exp(-pow(d / (size * 2.0), 2.0)) * 0.12 * twinkle;
		// Short tapered sparks follow the same smooth orbit, without wavy bands.
		for (int j = 1; j <= 3; j++) {
			float trail_angle = angle - float(j) * 0.045;
			vec2 trail_center = vec2(cos(trail_angle), sin(trail_angle)) * lane;
			float trail = exp(-pow(length(p - trail_center) / (size * 0.75), 2.0));
			glow += trail * (1.0 - float(j) / 4.0) * 0.22;
		}
	}
	float central_sparks = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i >= central_particle_count) { break; }
		float seed = float(i);
		float cycle = elapsed / max(central_lifetime, 0.1) + seed * 0.6180339;
		float age = fract(cycle);
		float generation = floor(cycle);
		float angle = seed * 2.399963 + generation * 1.71;
		float start_radius = mix(0.10, 0.28, fract(seed * 0.381966));
		float travel_radius = start_radius + central_travel * age;
		vec2 center = vec2(cos(angle), sin(angle)) * travel_radius;
		center.y -= sin(age * 3.14159265) * 0.025;
		float size = central_particle_size * mix(0.7, 1.2, fract(seed * 0.754877));
		float fade = smoothstep(0.0, 0.15, age) * (1.0 - smoothstep(0.45, 1.0, age));
		central_sparks += exp(-pow(length(p - center) / size, 2.0)) * fade;
	}
	float spark_alpha = clamp((cores + glow) * orbit_opacity + central_sparks * central_opacity, 0.0, 1.0);
	float base_alpha = clamp(fill + rim + inner_rim, 0.0, 0.7);
	float alpha = (1.0 - (1.0 - base_alpha) * (1.0 - spark_alpha)) * (1.0 - smoothstep(0.94, 1.0, radius));
	vec3 tint = mix(heat_color.rgb, ember_color.rgb, clamp(cores * 0.3 + glow * 0.1 + central_sparks * 0.2, 0.0, 1.0));
	float density = coverage_at(p);
	float strength = min(density, 1.0) * (1.0 + max(density - 1.0, 0.0) * 0.14);
	tint = mix(tint, ember_color.rgb, clamp((density - 1.0) * 0.06, 0.0, 0.25));
	COLOR = vec4(tint, min(alpha * strength, 0.85) * heat_color.a);
}
