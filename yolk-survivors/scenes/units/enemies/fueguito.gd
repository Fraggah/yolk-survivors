extends Enemy
## Persistent contact hazard. Uses Enemy's pursuit without joining its target layer.

@onready var contact_hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	super._ready()
	contact_hitbox.setup(stats.damage, false, 0.0, self)

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

func destroy_enemy() -> void:
	# Wave cleanup must not remove this manually placed level hazard.
	pass
