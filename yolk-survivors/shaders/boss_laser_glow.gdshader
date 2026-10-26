shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float phase=0.0;
uniform float world_length=1000.0;
uniform float intensity=1.0;
uniform float ripple_strength : hint_range(0.0,0.2) = 0.06;
uniform vec4 glow_color : source_color = vec4(1.0,0.32,0.025,1.0);
void fragment(){
 float x=UV.x*world_length/75.0;
 float y=abs(UV.y-0.5)*2.0;
 float ripple=1.0-ripple_strength+ripple_strength*sin(x*2.1-phase*5.0);
 float halo=exp(-y*y*16.0)*0.66+exp(-y*y*5.0)*0.14;
 float ends=smoothstep(0.0,0.004,UV.x)*(1.0-smoothstep(0.996,1.0,UV.x));
 COLOR=vec4(glow_color.rgb,clamp(halo*intensity*ripple*ends,0.0,1.0));
}
