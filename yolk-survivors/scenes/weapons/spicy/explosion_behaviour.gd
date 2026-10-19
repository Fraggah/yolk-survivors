extends WeaponBehaviour

var explosions_remaining := 0
var next_explosion := 0.0

func execute_attack() -> void:
	if not is_instance_valid(weapon.get_parent()) or weapon.is_attacking: return
	weapon.is_attacking = true
	explosions_remaining = weapon.data.stats.spicy_explosion_settings.explosion_count
	_spawn_next()

func _process(delta: float) -> void:
	if Global.game_paused or not weapon.is_attacking: return
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source) or source.health_component.current_health <= 0.0:
		reset_attack()
		return
	next_explosion -= delta
	if next_explosion > 0.0: return
	if explosions_remaining > 0:
		_spawn_next()
	else:
		weapon.is_attacking = false

func _spawn_next() -> void:
	var source := weapon.get_parent() as Player
	if not is_instance_valid(source): return
	var settings := weapon.data.stats.spicy_explosion_settings
	var scale_factor := Global.GAME_ENTITY_SCALE
	var max_distance := weapon.get_effective_range() * scale_factor
	var min_distance := minf(settings.minimum_distance * scale_factor, max_distance)
	var angle := randf_range(0.0, TAU)
	var distance := sqrt(randf_range(min_distance * min_distance, max_distance * max_distance))
	var offset := Vector2.from_angle(angle) * distance
	offset.y *= settings.area_y_ratio
	var point := source.global_position + offset
	if source.arena_environment: point = source.arena_environment.clamp_position(point)
	var blast = load("res://effects/spicy_explosion.gd").new()
	blast.configure(weapon, point, settings, get_base_damage(), get_life_steal_chance())
	get_tree().current_scene.add_child(blast)
	explosions_remaining -= 1
	# Keep individual blasts separate, even if anticipation is changed in the resource.
	next_explosion = maxf(settings.explosion_interval, settings.anticipation + settings.visual_duration)

func reset_attack() -> void:
	explosions_remaining = 0
	next_explosion = 0.0
	super.reset_attack()
