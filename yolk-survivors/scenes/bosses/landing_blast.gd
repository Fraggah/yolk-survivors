extends Node2D
## Presentation only: reuse Scotch Bonnet; landing damage stays in the encounter.
@export var visual_radius := 140.0
@export var y_ratio := 0.6
@export var duration := 0.3
@export var flash_seconds := 0.1
var elapsed := 0.0
var blast: Node2D
func _ready() -> void:
	add_to_group("projectiles")
	add_to_group("boss_landing_effects")
	var settings: Resource = load("res://resources/items/weapons/chili/scotch_bonnet/stats_scotch_bonnet.tres").spicy_pattern.duplicate()
	settings.wave_duration=duration
	settings.area_y_ratio=y_ratio
	blast=load("res://effects/scotch_mine_visual.gd").new()
	add_child(blast)
	blast.configure(settings,visual_radius,settings.mine_texture)
	blast.update_visual(0,true,0)
	$Flash.scale=Vector2(visual_radius*3.0,visual_radius*3.0*y_ratio)
func _process(delta: float) -> void:
	if Global.game_paused: return
	elapsed+=delta
	blast.update_visual(elapsed,true,elapsed)
	$Flash.material.set_shader_parameter("progress",clampf(elapsed/flash_seconds,0,1))
	if elapsed>=duration: queue_free()
