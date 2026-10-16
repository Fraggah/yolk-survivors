extends Node2D
class_name Spawner

@export_range(0.0, 150.0) var spawn_relocation_distance := 70.0

signal on_wave_completed
signal on_wave_cleared
signal on_wave_started(wave: int)
const DIFFICULTY_RULES = preload("res://resources/difficulty_rules.gd")
@export var waves_data: Array[WaveData]
@export var spawn_area_size := Vector2(1000, 500)
@export var min_spawn_distance := 120.0
@export_flags_2d_physics var obstacle_mask := 1
@export_range(1, 500) var max_alive_enemies := 500
@export var debug_enabled := false
@export_range(1, 100) var debug_start_wave := 1
@export_range(0.1, 5.0) var debug_density := 1.0
@export_range(0.1, 8.0) var debug_time_scale := 1.0
@export var debug_invulnerable := false
@export_group("Temporary crowd test")
@export var temporary_crowd_test := true
@export_range(1.0, 10.0) var test_heavy_health_multiplier := 4.0
@export_group("Temporary reward test")
@export var temporary_reward_test := true
@export_range(1.0, 100.0) var test_health_per_experience := 10.0
@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_timer: Timer = $SpawnTimer
var wave_index := 1
var current_wave_data: WaveData
var spawned_enemies: Array[Enemy] = []
var special_enemies: Array[Enemy] = []
var boss_enemies: Array[Enemy] = []
var difficulty_index := 0:
	set(value): difficulty_index = DIFFICULTY_RULES.normalize_level(value)
var spawn_generation := 0
var pending_spawns := 0
var pending_population := [0, 0, 0]
var total_spawned := 0
var generated_by_type: Dictionary = {}
var active_groups: Array[Dictionary] = []
var arena_environment: ArenaEnvironment
var debug_label: Label
var fueguito: Enemy:
	get:
		for enemy in special_enemies:
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion(): return enemy
		return null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if OS.is_debug_build():
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--wave="): debug_start_wave = maxi(1, int(arg.get_slice("=", 1))); debug_enabled = true
			if arg.begins_with("--density="): debug_density = clampf(float(arg.get_slice("=", 1)), 0.1, 5.0); debug_enabled = true
			if arg.begins_with("--speed="): debug_time_scale = clampf(float(arg.get_slice("=", 1)), 0.1, 8.0); debug_enabled = true
			if arg == "--invulnerable": debug_invulnerable = true; debug_enabled = true
		if debug_enabled:
			var layer := CanvasLayer.new()
			layer.layer = 100
			add_child(layer)
			debug_label = Label.new()
			debug_label.position = Vector2(20, 160)
			debug_label.add_theme_font_size_override("font_size", 18)
			debug_label.add_theme_color_override("font_color", Color.WHITE)
			debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
			debug_label.add_theme_constant_override("outline_size", 4)
			layer.add_child(debug_label)

func _process(_delta: float) -> void:
	if debug_label:
		var info := debug_snapshot()
		debug_label.text = "DEBUG Wave %d | common %d/%d + %d pending\nHazards %d | bosses %d | generated %d\nGroups: %s | density %.2f | time %.2f" % [wave_index, info.common, info.limit, pending_population[0], info.hazards, info.bosses, total_spawned, ", ".join(info.groups), debug_density, Engine.time_scale]

func last_wave_number() -> int:
	var last := 0
	for wave in waves_data:
		if wave: last = maxi(last, wave.number)
	return last

func find_wave_data() -> WaveData:
	for wave in waves_data:
		if wave and wave.is_valid_index(wave_index): return wave
	return null

func start_wave() -> void:
	clear_enemies()
	clear_fueguito()
	current_wave_data = find_wave_data()
	if not current_wave_data:
		push_error("No configuration for wave %d" % wave_index)
		wave_timer.stop()
		spawn_timer.stop()
		return
	total_spawned = 0
	generated_by_type.clear()
	active_groups.clear()
	var groups: Array[SpawnGroup] = []
	groups.append_array(current_wave_data.groups)
	groups.append_array(current_wave_data.events)
	groups.sort_custom(func(a: SpawnGroup, b: SpawnGroup): return a.priority > b.priority)
	for group in groups:
		if not group or group.enemies.is_empty(): continue
		if not group.guaranteed and randf() >= group.activation_probability: continue
		active_groups.append({"group": group, "next": group.start_second, "executions": 0, "pending": 0, "completed": 0, "active": true})
	on_wave_started.emit(wave_index)
	wave_timer.start(maxf(0.1, current_wave_data.wave_time))
	if OS.is_debug_build() and debug_enabled:
		Engine.time_scale = debug_time_scale
		if is_instance_valid(Global.player): Global.player.health_component.debug_invulnerable = debug_invulnerable
	start_spawn_timer()

func start_spawn_timer() -> void:
	spawn_timer.start(0.1)

func scheduler_tick(elapsed: float) -> void:
	for state in active_groups:
		if not state.active: continue
		var group: SpawnGroup = state.group
		if (group.duration >= 0.0 and elapsed > group.start_second + group.duration) or (group.repetitions >= 0 and (state.completed if group.guaranteed else state.executions) >= group.repetitions):
			state.active = false
			continue
		if elapsed < state.next or (group.guaranteed and state.pending > 0): continue
		# Drop missed ticks. Never accumulate a backlog or catch up in a burst.
		var density := debug_density if OS.is_debug_build() and debug_enabled and not group.guaranteed else 1.0
		var difficulty_density := DIFFICULTY_RULES.density_multiplier(difficulty_index)
		state.next = elapsed + maxf(group.minimum_interval, group.interval_at(elapsed) / (density * difficulty_density * (Global.player.stats.final_multiplier("enemy_count") if is_instance_valid(Global.player) and not group.guaranteed else 1.0)))
		state.executions += 1
		var count := randi_range(maxi(1, group.minimum_count), maxi(group.minimum_count, group.maximum_count))
		if group.school:
			var school_profile := group.select_enemy()
			if school_profile: spawn_school(school_profile, count, Vector2.INF, group.school_radius, state)
			continue
		for i in count:
			var profile := group.select_enemy()
			if profile:
				var members := test_profile_count(profile) if group.affected_by_density else 1
				if group.school_probability > 0.0 and randf() < group.school_probability and profile.id in [&"chaser_mini", &"chaser_mid", &"chaser_fast"]:
					spawn_school(profile, members, Vector2.INF, group.school_radius, state)
					continue
				for duplicate in members:
					if not has_capacity(profile.population): break
					spawn_profile(profile, state)

func test_wave_multiplier() -> int:
	if current_wave_data and current_wave_data.density_multiplier > 0: return current_wave_data.density_multiplier
	return clampi(wave_index, 1, 5) if temporary_crowd_test else 1

func test_profile_count(profile: EnemyProfile) -> int:
	# Big keeps its original cadence/count; hazards and bosses remain independent.
	return test_wave_multiplier() if profile.population == 0 and profile.id != &"chaser_slow" else 1

func population_count(population: int) -> int:
	var list: Array[Enemy] = spawned_enemies if population == 0 else special_enemies if population == 1 else boss_enemies
	var alive := 0
	for i in range(list.size() - 1, -1, -1):
		var enemy = list[i]
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion(): list.remove_at(i)
		elif enemy.health_component.current_health > 0.0 and not enemy.is_retiring: alive += 1
	return alive

func alive_enemy_count() -> int:
	return population_count(0)

func population_limit(population: int) -> int:
	if not current_wave_data: return 0
	return mini(max_alive_enemies, current_wave_data.common_limit * test_wave_multiplier()) if population == 0 else current_wave_data.hazard_limit if population == 1 else current_wave_data.boss_limit

func has_capacity(population: int) -> bool:
	return population_count(population) + pending_population[population] < population_limit(population)

func get_random_spawn_position() -> Vector2:
	if arena_environment: return arena_environment.random_spawn_position()
	return Vector2(randf_range(-spawn_area_size.x, spawn_area_size.x), randf_range(-spawn_area_size.y, spawn_area_size.y))

func is_spawn_position_safe(point: Vector2, profile: EnemyProfile = null) -> bool:
	if not point.is_finite() or not is_instance_valid(Global.player): return false
	var margin := profile.spawn_margin * profile.visual_scale if profile else 80.0
	var player_distance := maxf(min_spawn_distance, profile.minimum_player_distance if profile else min_spawn_distance) + margin
	if point.distance_squared_to(Global.player.global_position) < player_distance * player_distance: return false
	return is_spawn_geometry_valid(point, profile)

func is_spawn_geometry_valid(point: Vector2, profile: EnemyProfile = null) -> bool:
	if not point.is_finite(): return false
	var margin := profile.spawn_margin * profile.visual_scale if profile else 80.0
	for step in 16:
		var sample := point + Vector2.from_angle(TAU * step / 16.0) * margin
		if arena_environment:
			if not arena_environment.clamp_position(sample).is_equal_approx(sample): return false
		elif not Rect2(-spawn_area_size, spawn_area_size * 2.0).has_point(sample): return false
	var shape := CircleShape2D.new()
	shape.radius = margin
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, point)
	query.collision_mask = obstacle_mask
	query.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func get_safe_spawn_position(profile: EnemyProfile = null) -> Vector2:
	for attempt in 32:
		var candidate := get_random_spawn_position()
		if is_spawn_position_safe(candidate, profile): return candidate
	return Vector2.INF

func prepare_enemy(instance: Enemy, profile: EnemyProfile = null) -> void:
	var base := instance.stats
	var scaled := base.duplicate() as UnitStats
	var elapsed := maxi(0, wave_index - 1)
	var multiplier := DIFFICULTY_RULES.stat_multiplier(difficulty_index)
	var hp_growth := profile.health_growth_multiplier if profile else 1.0
	var damage_growth := profile.damage_growth_multiplier if profile else 1.0
	scaled.health = maxf(1.0, (base.initial_health + base.health_increase_per_wave * elapsed * hp_growth) * multiplier * (current_wave_data.health_multiplier if current_wave_data else 1.0))
	scaled.damage = maxf(0.0, (base.initial_damage + base.damage_increase_per_wave * elapsed * damage_growth) * multiplier * (current_wave_data.damage_multiplier if current_wave_data else 1.0))
	scaled.speed = maxf(0.0, base.speed + (profile.speed_growth_per_wave * elapsed if profile else 0.0)) * (current_wave_data.speed_multiplier if current_wave_data else 1.0)
	if is_instance_valid(Global.player): scaled.speed *= Global.player.stats.final_multiplier("enemy_speed")
	if temporary_crowd_test and profile:
		if profile.id in [&"chaser_slow", &"charger"]: scaled.health *= test_heavy_health_multiplier
	if temporary_reward_test and profile and profile.population != 1:
		scaled.coin_drop = 1
		scaled.experience_reward = maxi(1, ceili(scaled.health / maxf(1.0, test_health_per_experience)))
	instance.stats = scaled
	var shooting := instance.get_node_or_null("ShootingBehaviour") as ShootingBehaviour
	if shooting:
		shooting.wave_offset = elapsed
		shooting.damage_multiplier = multiplier * (current_wave_data.damage_multiplier if current_wave_data else 1.0) * damage_growth
	instance.arena_environment = arena_environment
	if profile:
		instance.visual_scale = profile.visual_scale
		instance.knockback_resistance = clampf((profile.knockback_resistance + profile.resistance_growth_per_wave * elapsed) * current_wave_data.resistance_multiplier, 0.0, 1.0)
		instance.set_meta("enemy_profile", profile.id)

func spawn_profile(profile: EnemyProfile, state: Dictionary = {}) -> void:
	if Global.game_paused or not current_wave_data or wave_timer.is_stopped() or not has_capacity(profile.population): return
	var point := get_safe_spawn_position(profile)
	if not point.is_finite(): return
	_spawn_profile_at(profile, point, state)

func spawn_school(profile: EnemyProfile, count: int = 10, center: Vector2 = Vector2.INF, spread_radius: float = 140.0, state: Dictionary = {}) -> int:
	if not profile or not profile.is_valid() or profile.population != 0 or profile.id not in [&"chaser_mini", &"chaser_fast", &"chaser_mid"]: return 0
	if Global.game_paused or not current_wave_data or wave_timer.is_stopped() or count <= 0: return 0
	if not center.is_finite(): center = get_safe_spawn_position(profile)
	if not center.is_finite(): return 0
	var admitted := 0
	var available := maxi(0, population_limit(0) - population_count(0) - pending_population[0])
	var desired := mini(count, available)
	for index in desired:
		var point := center + Vector2.from_angle(index * 2.399963) * sqrt((index + 0.5) / maxf(1, desired)) * maxf(0, spread_radius)
		if not is_spawn_position_safe(point, profile):
			var found := false
			for attempt in 24:
				point = center + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * maxf(0, spread_radius)
				if is_spawn_position_safe(point, profile): found = true; break
			if not found: continue
		_spawn_profile_at(profile, point, state)
		admitted += 1
	return admitted

func _spawn_profile_at(profile: EnemyProfile, point: Vector2, state: Dictionary = {}) -> void:
	if Global.game_paused or wave_timer.is_stopped() or not has_capacity(profile.population): return
	var generation := spawn_generation
	pending_spawns += 1
	pending_population[profile.population] += 1
	if not state.is_empty(): state.pending += 1
	var effect := Global.SPAWN_EFFECT_SCENE.instantiate()
	get_parent().add_child(effect)
	effect.global_position = point
	await effect.completed
	if generation != spawn_generation: return
	while Global.game_paused and not wave_timer.is_stopped():
		await get_tree().process_frame
		if generation != spawn_generation: return
	if is_instance_valid(Global.player) and (Global.player.global_position.distance_to(point) < spawn_relocation_distance or not is_spawn_geometry_valid(point, profile)):
		point = get_safe_spawn_position(profile)
	var ready_to_spawn := point.is_finite() and is_instance_valid(Global.player)
	pending_spawns -= 1
	pending_population[profile.population] -= 1
	if not state.is_empty(): state.pending -= 1
	if not ready_to_spawn or wave_timer.is_stopped() or not has_capacity(profile.population): return
	var enemy := profile.scene.instantiate() as Enemy
	prepare_enemy(enemy, profile)
	get_parent().add_child(enemy)
	enemy.global_position = point
	if profile.population == 0: spawned_enemies.append(enemy)
	elif profile.population == 1: special_enemies.append(enemy)
	else: boss_enemies.append(enemy)
	total_spawned += 1
	generated_by_type[profile.id] = int(generated_by_type.get(profile.id, 0)) + 1
	if not state.is_empty(): state.completed += 1

func spawn_enemy() -> void:
	if not current_wave_data or current_wave_data.groups.is_empty(): return
	var profile := current_wave_data.groups[0].select_enemy()
	if profile: spawn_profile(profile)

func get_enemy_scene() -> PackedScene:
	if not current_wave_data: return null
	for group in current_wave_data.groups:
		var profile := group.select_enemy()
		if profile: return profile.scene
	return null

func clear_enemies() -> void:
	on_wave_cleared.emit()
	spawn_generation += 1
	Engine.time_scale = 1.0
	pending_spawns = 0
	pending_population = [0, 0, 0]
	active_groups.clear()
	for effect in get_tree().get_nodes_in_group("spawn_effects"): effect.complete()
	for enemy in spawned_enemies + boss_enemies:
		if is_instance_valid(enemy): enemy.destroy_enemy()
	spawned_enemies.clear()
	boss_enemies.clear()

func clear_fueguito() -> void:
	for enemy in special_enemies:
		if is_instance_valid(enemy): enemy.queue_free()
	special_enemies.clear()

func debug_snapshot() -> Dictionary:
	var labels: Array[String] = []
	var elapsed := current_wave_data.wave_time - wave_timer.time_left if current_wave_data else 0.0
	for state in active_groups:
		if state.active and elapsed >= state.group.start_second: labels.append(state.group.label)
	return {"common": population_count(0), "limit": population_limit(0), "hazards": population_count(1), "bosses": population_count(2), "generated": total_spawned, "groups": labels, "pending": pending_spawns}

func get_wave_timer_text() -> String:
	return str(int(ceil(wave_timer.time_left)))

func get_wave_text() -> String:
	return "Wave %d%s" % [wave_index, " - Horde" if current_wave_data and current_wave_data.wave_type == WaveData.WaveType.HORDE else ""]

func reset_run(level: int) -> void:
	wave_timer.stop()
	spawn_timer.stop()
	wave_timer.paused = false
	spawn_timer.paused = false
	clear_enemies()
	clear_fueguito()
	Engine.time_scale = 1.0
	wave_index = clampi(debug_start_wave, 1, last_wave_number()) if OS.is_debug_build() and debug_enabled else 1
	difficulty_index = level
	current_wave_data = null

func _on_spawn_timer_timeout() -> void:
	if current_wave_data and not wave_timer.is_stopped():
		if not Global.game_paused: scheduler_tick(current_wave_data.wave_time - wave_timer.time_left)
		start_spawn_timer()
	else: spawn_timer.stop()

func _on_wave_timer_timeout() -> void:
	Global.game_paused = true
	spawn_timer.stop()
	clear_fueguito()
	clear_enemies()
	Engine.time_scale = 1.0
	on_wave_completed.emit()
