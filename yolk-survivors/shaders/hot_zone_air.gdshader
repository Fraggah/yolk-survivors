shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float phase = 0.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float strength_pixels : hint_range(0.0, 20.0) = 5.5;
uniform float vertical_strength_pixels : hint_range(0.0, 10.0) = 1.5;
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float flow(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(cell), hash(cell + vec2(1, 0)), f.x), mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1, 1)), f.x), f.y) * 2.0 - 1.0;
}
void fragment() {
    vec2 p = UV * 2.0 - 1.0;
    float envelope = 1.0 - smoothstep(0.50, 1.0, length(p));
    float mask = envelope * smoothstep(0.0, 0.30, UV.y) * (1.0 - smoothstep(0.85, 1.0, UV.y)) * intensity;
    // Irregular rising air: refraction only, with no luminous wave bands.
    vec2 movement = vec2(phase * 0.13, phase * 1.2);
    vec2 drift = vec2(flow(p * 7.0 + movement), flow(p * 5.0 + movement + vec2(19.3, 7.8)));
    vec2 offset = drift * vec2(strength_pixels, vertical_strength_pixels) * SCREEN_PIXEL_SIZE * mask;
    COLOR = vec4(texture(screen_texture, SCREEN_UV + offset).rgb, mask);
}
