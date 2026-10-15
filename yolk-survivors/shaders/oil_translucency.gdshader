shader_type canvas_item;
void fragment() {
    vec4 sprite = texture(TEXTURE, UV);
    float brightest = max(sprite.r, max(sprite.g, sprite.b));
    float darkest = min(sprite.r, min(sprite.g, sprite.b));
    float outline = 1.0 - smoothstep(0.15, 0.30, brightest);
    float highlight = smoothstep(0.88, 0.97, darkest);
    float opacity = mix(0.32, 1.0, max(outline, highlight));
    COLOR.a *= opacity * smoothstep(0.06, 0.18, sprite.a);
}
