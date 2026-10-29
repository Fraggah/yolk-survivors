shader_type canvas_item;
uniform sampler2D flame_texture: source_color, filter_linear_mipmap;
uniform float elapsed=0.0;
varying float phase;
varying vec4 timing;
void vertex(){phase=MODEL_MATRIX[3].x+MODEL_MATRIX[3].y*0.7;timing=INSTANCE_CUSTOM;}
void fragment(){
	vec2 uv=UV;
	uv.x+=(1.0-UV.y)*sin(UV.y*12.0+elapsed*7.0+phase)*0.025;
	COLOR*=texture(flame_texture,uv);
	float age=elapsed-timing.r;
	COLOR.a*=min(clamp(age/max(0.01,timing.b),0.0,1.0),clamp((timing.g-age)/max(0.01,timing.a),0.0,1.0));
}
