extends "res://scenes/arena/mechanics/pan_mechanic.gd"
## Reuses the pan's safe arrival, flare, separation and cleanup, plus griddle zones.
var config: Resource
var elapsed := 0.0
var running := false
var griddle: StageMechanic
var next_fueguito := 0.0
var materialize_at := INF
var zone_batch := -1
var births := 0

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	config = settings
	start(damage_source.get_parent().spawner,geometry)
	set_process(false)
	y_sort_enabled = true
	add_to_group("boss_hazards")
	profile = config.fueguito_profile
	flare_duration = config.fueguito_flare_seconds
	batch_size = 1
	griddle = load("res://scenes/arena/mechanics/griddle_mechanic.tscn").instantiate()
	griddle.radius = config.hot_zone_radius
	griddle.damage = config.hot_zone_damage
	griddle.maximum_zones = config.hot_zone_count
	griddle.warning_duration = config.hot_zone_warning_seconds
	griddle.cooling_duration = config.hot_zone_cooling_seconds
	griddle.active_duration = maxf(0.05,config.hot_zone_interval-griddle.warning_duration-griddle.cooling_duration)
	griddle.damage_interval = config.hot_zone_damage_interval
	add_child(griddle)
	griddle.start(spawner,area)
	griddle.set_process(false)
	running = true
	advance(0)

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds:
		stop()
		return
	for zone in zones(): zone._process(maxf(0,delta))
	if pending > 0 and elapsed >= materialize_at: materialize_batch()
	while elapsed >= next_fueguito:
		begin_batch()
		materialize_at = next_fueguito+flare_duration
		next_fueguito += config.fueguito_interval
		if pending > 0 and elapsed >= materialize_at: materialize_batch()
	var batch := int(floor(elapsed/config.hot_zone_interval))
	if batch != zone_batch:
		_clear_zones()
		zone_batch = batch
		# Placement may fail if the configured arena cannot fit every damage core.
		for attempt in config.hot_zone_count*3:
			if griddle.live_effect_count() >= config.hot_zone_count: break
			var zone = griddle.spawn_zone()
			if is_instance_valid(zone):
				zone.damage_hitbox.status_effects.append(preload("res://resources/bosses/boss_burning.tres"))
				zone.set_process(false)
				zone.update_visuals()
	separate_hazards(maxf(0,delta))

func zones() -> Array[Node]:
	var result: Array[Node] = []
	if is_instance_valid(griddle):
		for child in griddle.get_children():
			if child is StageAreaEffect and not child.is_queued_for_deletion(): result.append(child)
	return result

func materialize_batch() -> void:
	if not active or Global.game_paused or not profile: return
	for point in spawn_points:
		if not is_instance_valid(Global.player) or Global.player.global_position.distance_to(point) < spawner.spawn_relocation_distance: continue
		var enemy := profile.scene.instantiate() as Enemy
		# Boss hazards use their existing base stats, independent of the normal wave.
		enemy.stats = enemy.stats.duplicate()
		enemy.stats.coin_drop = 0
		enemy.stats.experience_reward = 0
		enemy.arena_environment = area
		enemy.visual_scale = profile.visual_scale
		enemy.targetable = false
		enemy.set_meta("stage_hazard",true)
		add_child(enemy)
		enemy.global_position = point
		hazards.append(enemy)
		spawner.special_enemies.append(enemy)
		births += 1
	spawn_points.clear()
	pending = 0
	materialize_at = INF

func _clear_zones() -> void:
	if not is_instance_valid(griddle): return
	for zone in griddle.get_children():
		if not zone is StageAreaEffect: continue
		zone.damage_hitbox.damage = 0
		zone.damage_hitbox.base_damage = 0
		zone.hide()
		zone.set_process(false)
		zone.queue_free()

func stop() -> void:
	running = false
	_clear_zones()
	if is_instance_valid(griddle): griddle.stop()
	for enemy in hazards:
		spawner.special_enemies.erase(enemy)
		if is_instance_valid(enemy):
			if enemy.has_method("announce_exit"): enemy.announce_exit()
			enemy.get_node("HitboxComponent").damage = 0
			enemy.get_node("HitboxComponent").collision_layer = 0
			enemy.anim_player.stop(true)
			if not enemy.is_retiring and is_inside_tree():
				var flare=preload("res://scenes/arena/mechanics/flame_transition.gd").new()
				flare.duration=flare_duration
				flare.add_to_group("projectiles")
				flare.add_to_group("boss_fueguito_exits")
				get_tree().current_scene.add_child(flare)
				flare.global_position=enemy.global_position
	super.stop()
