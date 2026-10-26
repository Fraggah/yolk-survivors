shader_type canvas_item;
render_mode unshaded;
uniform float phase=0.0;
uniform vec4 fire_color : source_color = vec4(1.0,0.6,0.12,1.0);
void fragment(){ COLOR=fire_color; }
