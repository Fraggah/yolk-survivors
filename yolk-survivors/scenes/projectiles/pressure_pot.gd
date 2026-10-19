extends "res://scenes/projectiles/corpse_egg.gd"

var rest_scale := Vector2.ONE

func configure_effects(config: RangedSettings) -> void:
	super.configure_effects(config)
	egg.scale = Vector2.ONE * settings.pot_sprite_scale
	rest_scale = egg.scale

func _find_contact(_start: Vector2, _end: Vector2) -> Dictionary:
	# Fly to the target snapshot, without hitting or pushing intervening enemies.
	return {}

func _land() -> void:
	if landed: return
	super._land()
	var radius := settings.landing_slow_radius * Global.GAME_ENTITY_SCALE
	var factor := settings.landing_slow_factor
	var duration := settings.landing_slow_duration
	if hitbox.source is Unit:
		radius *= hitbox.source.stats.get_area_radius_multiplier()
		factor = hitbox.source.stats.effective_slow(factor)
		duration *= hitbox.source.stats.get_crowd_control_multiplier()
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue
		var offset: Vector2 = enemy.global_position - landing_point
		offset.y /= maxf(0.01, settings.area_y_ratio)
		if offset.length_squared() <= radius * radius:
			enemy.apply_slow(factor, duration)
	var steam = load("res://effects/pan_slow_burst.gd").new()
	get_tree().current_scene.add_child(steam)
	steam.global_position = landing_point
	steam.radius = radius
	steam.y_ratio = settings.area_y_ratio
	steam.duration = settings.landing_visual_duration
	steam.color = Color("e7e4d5")

func _process(delta: float) -> void:
	super._process(delta)
	if Global.game_paused or not landed or exploded: return
	var progress := clampf(1.0 - fuse_left / maxf(0.001, settings.fuse), 0.0, 1.0)
	egg.scale = rest_scale * (1.0 + settings.pot_inflate_amount * progress * progress)

func detonate() -> void:
	if exploded or Global.game_paused or not landed: return
	exploded = true
	var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()
	get_tree().current_scene.add_child(blast)
	blast.global_position = landing_point
	blast.setup(hitbox, settings, false)
	queue_free()
