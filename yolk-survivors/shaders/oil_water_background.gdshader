shader_type canvas_item;
uniform vec4 color_a : source_color = vec4(0.70, 0.66, 0.62, 1.0);
uniform vec4 color_b : source_color = vec4(0.74, 0.70, 0.66, 1.0);
uniform float speed : hint_range(0.0, 1.0) = 0.16;
uniform float pattern_scale : hint_range(0.5, 6.0) = 2.0;
uniform float flow_strength : hint_range(0.0, 3.0) = 2.0;
uniform float pattern_world_size : hint_range(200.0, 4000.0) = 1600.0;
uniform float edge_softness : hint_range(0.0, 0.2) = 0.015;
uniform float seed = 0.0;
uniform float phase = 0.0;
varying vec2 world_position;
void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}
float hash(vec2 p) {
    vec3 value = fract(vec3(p.xyx) * 0.1031 + seed * 0.013);
    value += dot(value, value.yzx + 33.33);
    return fract((value.x + value.y) * value.z);
}
float noise(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(cell), hash(cell + vec2(1, 0)), f.x), mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1, 1)), f.x), f.y);
}
void fragment() {
    vec2 p = world_position / pattern_world_size * pattern_scale;
    float t = phase * speed;
    float n = noise(p * 1.1 + vec2(t * 0.17, -t * 0.12));
    float angle = flow_strength * (n - 0.5) * 2.0 + 0.35 * sin(t * 0.5 + length(p));
    p = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle))) * p;
    p += vec2(sin(p.y * 1.7 + t + n * 3.0), cos(p.x * 1.6 - t * 0.7 + n * 2.0)) * flow_strength * 0.45;
    float marble = sin(p.x * 2.2 + p.y * 1.3 + noise(p * 1.8 - t * 0.08) * 5.0);
    float softness = max(edge_softness, fwidth(marble));
    float blend = smoothstep(-softness, softness, marble);
    COLOR = mix(color_a, color_b, blend);
}
