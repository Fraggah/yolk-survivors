shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float phase = 0.0;
uniform bool oval = false;
uniform float warning_progress : hint_range(0.0,1.0) = 0.0;
uniform float world_length = 1000.0;
uniform float distortion_pixels : hint_range(0.0,50.0) = 22.0;
uniform float initial_intensity : hint_range(0.0,1.0) = 0.2;
uniform float initial_edge_brightness : hint_range(0.0,1.0) = 0.25;
uniform float peak_progress : hint_range(0.1,1.0) = 0.92;
uniform float refraction_split_pixels : hint_range(0.0,5.0) = 1.6;
uniform vec4 edge_red : source_color = vec4(0.8,0.10,0.018,1.0);
uniform vec4 edge_orange : source_color = vec4(1.0,0.48,0.045,1.0);
uniform vec4 edge_yellow : source_color = vec4(1.0,0.78,0.23,1.0);
varying vec2 screen_normal;
void vertex() {
    screen_normal=normalize((CANVAS_MATRIX*MODEL_MATRIX*vec4(0.0,1.0,0.0,0.0)).xy);
}
void fragment() {
    float ramp=smoothstep(0.0,peak_progress,warning_progress);
    float intensity=mix(initial_intensity,1.0,ramp);
    float brightness=mix(initial_edge_brightness,1.0,ramp);
    float x=UV.x*world_length/75.0;
    float across=oval ? length((UV-0.5)*2.0) : abs(UV.y-0.5)*2.0;
    float envelope=1.0-smoothstep(0.65,1.0,across);
    float ends=oval ? 1.0 : smoothstep(0.0,0.006,UV.x)*(1.0-smoothstep(0.994,1.0,UV.x));
    float turbulence=sin(x*3.1-phase*7.0+sin(UV.y*10.0+phase*3.0))*0.58+sin(x*7.3+phase*5.4+UV.y*14.0)*0.28+sin(x*13.0-phase*9.0)*0.14;
    vec2 tangent=vec2(-screen_normal.y,screen_normal.x);
    float strength=distortion_pixels*1.2*intensity*envelope;
    vec2 offset=(screen_normal*turbulence+tangent*sin(x*4.0+phase*5.0)*0.28)*strength*SCREEN_PIXEL_SIZE;
    vec2 sample_uv=clamp(SCREEN_UV+offset,SCREEN_PIXEL_SIZE,vec2(1.0)-SCREEN_PIXEL_SIZE);
    vec2 split=screen_normal*refraction_split_pixels*intensity*envelope*SCREEN_PIXEL_SIZE;
    vec3 refracted=vec3(texture(screen_texture,sample_uv+split).r,texture(screen_texture,sample_uv).g,texture(screen_texture,sample_uv-split).b);
    float edge=exp(-pow((across-0.87)*13.0,2.0));
    float glow=exp(-pow((across-0.83)*4.0,2.0));
    float flicker=0.8+0.2*sin(x*3.7-phase*8.0);
    vec3 heat=mix(edge_red.rgb,edge_orange.rgb,0.55+0.4*ramp);
    heat=mix(heat,edge_yellow.rgb,edge*0.4*flicker);
    vec3 color=mix(refracted,edge_red.rgb,0.045*intensity*envelope);
    color=mix(color,heat,clamp((edge*0.95*flicker+glow*0.18)*brightness,0.0,1.0));
    float alpha=(1.0-smoothstep(0.97,1.0,across))*ends;
    COLOR=vec4(color,alpha);
}
