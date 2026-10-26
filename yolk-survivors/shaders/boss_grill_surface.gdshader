shader_type canvas_item;
// Dark iron and parallel raised grill ribs, using the existing tray silhouette.
uniform vec2 surface_size = vec2(2800.0,1866.67);
uniform vec4 grill_rect = vec4(-1181.25,-641.667,2362.5,1297.92);
uniform float corner_radius = 142.188;
uniform vec4 metal_color : source_color = vec4(0.105,0.112,0.12,1.0);
uniform vec4 metal_shadow : source_color = vec4(0.023,0.025,0.03,1.0);
uniform vec4 rib_highlight : source_color = vec4(0.18,0.19,0.20,1.0);
uniform float rib_spacing : hint_range(40.0,200.0) = 105.0;
uniform float rib_width : hint_range(4.0,40.0) = 18.0;
uniform float rib_angle : hint_range(-90.0,90.0) = -15.0;
varying vec4 vertex_tint;
void vertex() { vertex_tint=COLOR; }
float rounded_rect(vec2 p,vec2 half_size,float radius) {
    vec2 q=abs(p)-half_size+radius;
    return length(max(q,vec2(0.0)))+min(max(q.x,q.y),0.0)-radius;
}
void fragment() {
    vec4 source=texture(TEXTURE,UV);
    float light=dot(source.rgb,vec3(0.299,0.587,0.114));
    vec3 metal=mix(metal_shadow.rgb,metal_color.rgb,clamp(light*1.65,0.0,1.0));
    vec2 p=(UV-0.5)*surface_size;
    vec2 center=grill_rect.xy+grill_rect.zw*0.5;
    float edge=rounded_rect(p-center,grill_rect.zw*0.5,corner_radius);
    float aa=max(fwidth(edge),1.0);
    float interior=1.0-smoothstep(-aa,aa,edge);
    float angle=radians(rib_angle);
    float stripe=dot(p,vec2(-sin(angle),cos(angle)));
    float d=abs(mod(stripe+rib_spacing*0.5,rib_spacing)-rib_spacing*0.5);
    float stripe_aa=max(fwidth(stripe),1.0);
    float ribs=1.0-smoothstep(rib_width*0.5-stripe_aa,rib_width*0.5+stripe_aa,d);
    float crest=1.0-smoothstep(1.0,3.0,abs(d-rib_width*0.5));
    vec3 surface=mix(metal,metal_shadow.rgb,ribs*0.8);
    surface=mix(surface,rib_highlight.rgb,crest*0.35);
    metal=mix(metal,surface,interior);
    COLOR=vec4(metal,source.a)*vertex_tint;
}
