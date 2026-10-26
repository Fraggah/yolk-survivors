shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float progress=0.0;
uniform float strength=1.0;
uniform vec4 flash_color : source_color = vec4(1.0,0.62,0.18,1.0);
void fragment(){ float d=length((UV-0.5)*2.0); float halo=exp(-d*d*5.0); COLOR=vec4(flash_color.rgb,halo*pow(1.0-progress,2.0)*strength); }
