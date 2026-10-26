extends Enemy
## Indestructible contact hazard; its pan mechanic owns the timed lifecycle.

@onready var contact_hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	super._ready()
	SoundManager.play_event("fueguito_spawn")
	contact_hitbox.setup(stats.damage, false, 0.0, self)
	contact_hitbox.status_effects.append(load("res://resources/statuses/fueguito_fire.tres"))

func _process(delta: float) -> void:
	super._process(delta)
	# The project pauses gameplay through Global rather than SceneTree.paused.
	anim_player.speed_scale = 0.0 if Global.game_paused else 1.0

func _on_hurtbox_component_on_damage(_hitbox: HitboxComponent) -> void:
	pass

func apply_knockback(_knock_dir: Vector2, _knock_pow: float) -> void:
	pass

func _on_health_component_on_unit_died() -> void:
	pass

var exit_announced := false
func announce_exit() -> void:
	if exit_announced: return
	exit_announced = true
	SoundManager.play_event("fueguito_exit")

func _exit_tree() -> void:
	if is_instance_valid(get_tree().current_scene) and not get_tree().current_scene.is_queued_for_deletion(): announce_exit()

func destroy_enemy() -> void:
	# The pan owner handles retirement and its flare, outside generic enemy cleanup.
	pass
