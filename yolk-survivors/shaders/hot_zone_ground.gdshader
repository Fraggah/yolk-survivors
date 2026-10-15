shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float phase = 0.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float shape_phase = 0.0;
uniform float breath : hint_range(0.0, 1.0) = 0.5;
uniform float damage_core_ratio : hint_range(0.2, 0.9) = 0.60;
uniform float zone_radius = 350.0;
uniform vec2 zone_center = vec2(0.0);
uniform vec4 arena_rect = vec4(-1021.5, -511.7, 2041.0, 1015.6);
uniform float arena_corner = 109.4;
void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    float angle = atan(p.y, p.x);
    float boundary = 0.75 + 0.13 * sin(angle * 3.0 + shape_phase) + 0.08 * cos(angle * 2.0 - shape_phase * 0.7);
    float r = length(p) / boundary;
    float halo = 1.0 - smoothstep(0.20, 1.0, r);
    vec2 at = zone_center + p * zone_radius;
    vec2 q = abs(at - (arena_rect.xy + arena_rect.zw * 0.5)) - (arena_rect.zw * 0.5 - vec2(arena_corner));
    float floor_edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - arena_corner;
    halo *= 1.0 - smoothstep(-8.0, 0.0, floor_edge);
    float core = 1.0 - smoothstep(0.15, damage_core_ratio + 0.12, r);
    vec3 metal = texture(screen_texture, SCREEN_UV).rgb;
    vec3 warm_metal = metal * vec3(1.15, 0.74, 0.52);
    vec3 emission = vec3(0.68, 0.18, 0.035) * core * mix(0.65, 1.0, breath);
    COLOR = vec4(warm_metal + emission, halo * (0.32 + core * mix(0.28, 0.50, breath)) * intensity);
}
