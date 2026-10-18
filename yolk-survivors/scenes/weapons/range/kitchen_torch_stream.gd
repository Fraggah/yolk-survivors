extends "res://scenes/weapons/range/mayonnaise_stream.gd"
## One continuous flame silhouette; damage uses the shared short hitscan trace.
func _ready() -> void:
	super._ready()
	line.z_index=0
	stream_material.shader=preload("res://shaders/kitchen_torch_flame.gdshader")

func _update_trace() -> void:
	super._update_trace()
	line.width=weapon.data.stats.ranged_settings.stream_width*1.25
	line.default_color=Color.WHITE

func _emit_particles(_delta: float) -> void:
	# The procedural flame replaces rectangular sprite clusters and mayo drops.
	pass
