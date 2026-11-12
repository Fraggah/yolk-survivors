extends Projectile
var settings: RangedSettings
var broken := false

func configure_effects(config: RangedSettings) -> void:
	settings = config

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	super.setup_projectile(projectile_velocity, damage, critical, knockback, unit, travel_range)
	rotation = 0.0

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if Global.game_paused or broken or is_queued_for_deletion(): return
	var id := hurtbox.get_instance_id()
	if hit_targets.has(id): return
	hit_targets[id] = true
	var luck: float = hitbox.source.stats.luck if is_instance_valid(hitbox.source) and hitbox.source is Unit else 0.0
	if not settings or randf() >= settings.get_plate_bounce_chance(luck):
		_break_plate()
		return
	var target: Node2D = EnemyCrowd.random_target(hit_targets)
	if not is_instance_valid(target):
		_break_plate()
		return
	velocity = global_position.direction_to((target as Unit).get_aim_position()) * velocity.length()
	max_distance = INF
	rotation = 0.0

func _break_plate() -> void:
	if broken: return
	broken = true
	hide()
	# Called from physics contacts: insert the visual node after callbacks finish.
	call_deferred("_emit_break")
	finish()

func _emit_break() -> void:
	if not settings: return
	var fragments = load("res://effects/plate_fragments.gd").new()
	get_tree().current_scene.add_child(fragments)
	fragments.global_position = global_position
	fragments.setup(settings)
	SoundManager.play_stream(SoundManager.plate_break, "plate_break")
