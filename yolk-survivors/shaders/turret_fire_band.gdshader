shader_type canvas_item;
render_mode unshaded;
uniform float phase = 0.0;
uniform bool use_color_mask = true;
uniform float firing : hint_range(0.0,1.0) = 0.0;
uniform vec4 fire_red : source_color = vec4(0.75,0.08,0.018,1.0);
uniform vec4 fire_orange : source_color = vec4(1.0,0.48,0.045,1.0);
uniform vec4 fire_yellow : source_color = vec4(1.0,0.86,0.33,1.0);
void fragment() {
    vec4 original=texture(TEXTURE,UV);
    // The asset's yellow belt is a color mask; the orange casing is untouched.
    float belt=use_color_mask ? smoothstep(0.61,0.72,original.g)* (1.0-smoothstep(0.40,0.55,original.b)) : 1.0;
    float flow=sin(UV.x*47.0-phase*4.0)+0.5*sin(UV.y*63.0+UV.x*19.0+phase*5.0);
    float hot=smoothstep(-0.1,0.8,flow);
    vec3 fire=mix(fire_red.rgb,fire_orange.rgb,0.55+0.45*sin(flow+phase*0.5));
    fire=mix(fire,fire_yellow.rgb,hot*(0.35+firing*0.5));
    COLOR=vec4(mix(original.rgb,fire,belt),original.a);
}
