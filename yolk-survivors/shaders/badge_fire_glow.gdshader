shader_type canvas_item;
render_mode unshaded, blend_add;
uniform float phase=0.0;
uniform int shape=0;
uniform vec4 glow_color : source_color = vec4(1.0,0.34,0.035,1.0);
uniform float strength=1.15;
float segment(vec2 p,vec2 a,vec2 b){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.0,1.0));}
void fragment(){
 vec2 p=(UV-0.5)*110.0;
 float d=abs(length(p)-37.2);
 if(shape==1){
  float shaft=length(max(abs(p-vec2(-7.5,0.0))-vec2(14.5,4.5),vec2(0.0)));
  float head=min(segment(p,vec2(7,-18),vec2(30,0)),min(segment(p,vec2(30,0),vec2(7,18)),segment(p,vec2(7,18),vec2(7,-18))));
  if(p.x>=7.0 && p.x<=30.0 && abs(p.y)<(30.0-p.x)*18.0/23.0) head=0.0;
  d=min(shaft,head);
 }
 float halo=exp(-d*d/50.0)*0.6+exp(-d*d/160.0)*0.22;
 COLOR=vec4(glow_color.rgb,clamp(halo*strength,0.0,1.0));
}
