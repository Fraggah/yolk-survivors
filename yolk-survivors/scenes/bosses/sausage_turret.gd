extends Node2D
@export_range(0.1,1.0,0.01) var spawn_seconds := 0.46
@export var spawn_small_scale := Vector2(0.2,0.12)
@export var spawn_peak_scale := Vector2(1.16,1.45)
@export var spawn_recoil_scale := Vector2(0.96,0.92)
@export_range(0.1,1.0,0.01) var retire_seconds := 0.36
@export var retire_peak_scale := Vector2(1.12,1.32)
var retiring := false
var retire_age := 0.0
var retire_from := Vector2.ONE
var retire_phase := 0.0
var retirement_first_frame := false
var rest_sprite_scale := Vector2.ONE
func _ready() -> void:
	SoundManager.play_event("turret_spawn")
	rest_sprite_scale=$Sprite.scale
	animate_birth(0)
	set_process(false)
func animate_birth(age: float) -> void:
	var progress := clampf(age/spawn_seconds,0,1)
	var factor: Vector2
	if progress<0.6:
		var t := 1.0-pow(1.0-progress/0.6,3.0)
		factor=spawn_small_scale.lerp(spawn_peak_scale,t)
	elif progress<0.84:
		factor=spawn_peak_scale.lerp(spawn_recoil_scale,smoothstep(0.6,0.84,progress))
	else:
		factor=spawn_recoil_scale.lerp(Vector2.ONE,smoothstep(0.84,1.0,progress))
	if age>=spawn_seconds:
		var breath := 0.025*sin((age-spawn_seconds)*4.0)
		factor=Vector2(1.0+breath,1.0-breath)
	$Sprite.scale=rest_sprite_scale*factor

func begin_retirement() -> void:
	if retiring: return
	retiring=true
	retire_age=0
	retirement_first_frame=true
	retire_from=$Sprite.scale/rest_sprite_scale
	retire_phase=$Sprite.material.get_shader_parameter("phase")
	$Sprite.material.set_shader_parameter("firing",0.0)
	$HitboxComponent.damage=0
	$HitboxComponent.base_damage=0
	$HitboxComponent.collision_layer=0
	$HitboxComponent/CollisionShape2D.set_deferred("disabled",true)
	for child in get_children():
		if child.get_script() == preload("res://scenes/bosses/turret_rotation_cue.gd"):
			child.hide()
	add_to_group("projectiles")
	add_to_group("boss_retiring_turrets")
	set_process(true)
	animate_retirement(0)

func animate_retirement(age: float) -> void:
	var progress := clampf(age/retire_seconds,0,1)
	var factor: Vector2
	if progress<0.22:
		factor=retire_from.lerp(retire_peak_scale,smoothstep(0,0.22,progress))
	else:
		factor=retire_peak_scale.lerp(Vector2.ZERO,smoothstep(0.22,1,progress))
	$Sprite.scale=rest_sprite_scale*factor
	$Sprite.material.set_shader_parameter("phase",retire_phase+age)
	if progress>=1: queue_free()

func _process(delta: float) -> void:
	if not retiring or Global.game_paused: return
	# A turret can be retired earlier in this same process pass. Render its
	# starting pose before consuming time, rather than skipping it on a long frame.
	if retirement_first_frame:
		retirement_first_frame=false
		return
	retire_age+=maxf(0,delta)
	animate_retirement(retire_age)
