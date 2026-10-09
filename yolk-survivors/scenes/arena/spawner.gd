extends Node2D
class_name Spawner

signal on_wave_completed
signal on_wave_started(wave: int)

const DIFFICULTY_RULES = preload("res://resources/difficulty_rules.gd")
const HORDE_SCENES = [preload("res://scenes/units/enemies/enemy_chaser_fast.tscn"), preload("res://scenes/units/enemies/enemy_chaser_mid.tscn"), preload("res://scenes/units/enemies/enemy_chaser.tscn")]

const FUEGUITO_SCENE = preload("res://scenes/units/enemies/enemy_fueguito.tscn")

@export_range(1, 500) var max_alive_enemies := 80

@export var spawn_area_size := Vector2(1000, 500)
@export var waves_data: Array[WaveData]
@export_range(100.0, 1500.0, 10.0) var fueguito_min_spawn_distance := 450.0

@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_timer: Timer = $SpawnTimer

var wave_index := 1
var current_wave_data: WaveData
var spawned_enemies: Array[Enemy] = []
var difficulty_index := 0:
	set(value): difficulty_index = DIFFICULTY_RULES.normalize_level(value)
var spawn_generation := 0
var pending_spawns := 0
var fueguito: Enemy
var arena_environment: ArenaEnvironment

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func find_wave_data() -> WaveData:
	for wave: WaveData in waves_data:
		if wave and wave.is_valid_index(wave_index):
			return wave
	return null

func start_wave() -> void:
	spawn_generation += 1
	pending_spawns = 0
	current_wave_data = find_wave_data()
	if not current_wave_data:
		printerr("No valid wave.")
		spawn_timer.stop()
		wave_timer.stop()
		return
	
	on_wave_started.emit(wave_index)
	wave_timer.wait_time = current_wave_data.wave_time
	wave_timer.start()
	spawn_fueguito_if_needed()
	
	start_spawn_timer()

func spawn_fueguito_if_needed() -> void:
	if wave_index < 2 or is_instance_valid(fueguito): return
	var spawn_pos := get_fueguito_spawn_position()
	if is_instance_valid(Global.player) and spawn_pos.distance_to(Global.player.global_position) < fueguito_min_spawn_distance:
		# A future arena may be too small: never force an unfair nearby spawn.
		return
	fueguito = FUEGUITO_SCENE.instantiate() as Enemy
	fueguito.position = get_parent().to_local(spawn_pos)
	get_parent().add_child(fueguito)

func get_fueguito_spawn_position() -> Vector2:
	if not is_instance_valid(Global.player): return get_random_spawn_position()
	var player_pos := Global.player.global_position
	var min_distance_squared := fueguito_min_spawn_distance * fueguito_min_spawn_distance
	for attempt in 32:
		var candidate := get_random_spawn_position()
		if candidate.distance_squared_to(player_pos) >= min_distance_squared:
			return candidate
	# Bounded fallback searches the arena perimeter instead of retrying forever.
	var bounds := arena_environment.movement_bounds if arena_environment else Rect2(-spawn_area_size, spawn_area_size * 2.0)
	var farthest := bounds.get_center()
	for step in 64:
		var candidate := bounds.get_center() + Vector2.RIGHT.rotated(TAU * step / 64.0) * bounds.size.length()
		if arena_environment:
			candidate = arena_environment.clamp_position(candidate)
		else:
			candidate = Vector2(clampf(candidate.x, bounds.position.x, bounds.end.x), clampf(candidate.y, bounds.position.y, bounds.end.y))
		if candidate.distance_squared_to(player_pos) > farthest.distance_squared_to(player_pos):
			farthest = candidate
	return farthest

func clear_fueguito() -> void:
	# Remove the wave's Fueguito explicitly, bypassing its death immunity.
	if is_instance_valid(fueguito):
		fueguito.queue_free()
	fueguito = null

func start_spawn_timer() -> void:
	match current_wave_data.spawn_type:
		WaveData.SpawnType.FIXED:
			spawn_timer.wait_time = current_wave_data.fixed_spawn_time
		WaveData.SpawnType.RANDOM:
			var min_t := current_wave_data.min_spawn_time
			var max_t := current_wave_data.max_spawn_time
			spawn_timer.wait_time = randf_range(min_t, max_t)
	
	if DIFFICULTY_RULES.is_horde(difficulty_index, wave_index):
		spawn_timer.wait_time *= DIFFICULTY_RULES.HORDE_SPAWN_INTERVAL_MULTIPLIER
	spawn_timer.wait_time = maxf(0.05, spawn_timer.wait_time)
	if spawn_timer.is_stopped():
		spawn_timer.start()

func get_random_spawn_position() -> Vector2:
	if arena_environment:
		return arena_environment.random_spawn_position()
	var random_x := randf_range(-spawn_area_size.x, spawn_area_size.x)
	var random_y := randf_range(-spawn_area_size.y, spawn_area_size.y)
	return Vector2(random_x, random_y)

func alive_enemy_count() -> int:
	var alive := 0
	# Inspect validity before using a typed callback: freed references cannot be
	# converted to Enemy. Remove backwards to preserve the Array[Enemy] type.
	for index in range(spawned_enemies.size() - 1, -1, -1):
		var enemy = spawned_enemies[index]
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			spawned_enemies.remove_at(index)
			continue
		if enemy.health_component.current_health > 0.0:
			alive += 1
	return alive

func get_enemy_scene() -> PackedScene:
	if DIFFICULTY_RULES.is_horde(difficulty_index, wave_index):
		# Favor fragile, mobile enemies over projectile saturation in horde waves.
		var roll := randf()
		return HORDE_SCENES[0] if roll < 0.5 else (HORDE_SCENES[1] if roll < 0.875 else HORDE_SCENES[2])
	return current_wave_data.get_random_unit_scene(difficulty_index, wave_index)

func prepare_enemy(instance: Enemy) -> void:
	# Each spawned enemy owns its stats; roster resources never accumulate growth.
	var base := instance.stats
	var scaled := base.duplicate() as UnitStats
	var elapsed_waves := maxi(0, wave_index - 1)
	var multiplier := DIFFICULTY_RULES.stat_multiplier(difficulty_index)
	scaled.health = (base.initial_health + base.health_increase_per_wave * elapsed_waves) * multiplier
	scaled.damage = (base.initial_damage + base.damage_increase_per_wave * elapsed_waves) * multiplier
	instance.stats = scaled

func spawn_enemy() -> void:
	if Global.game_paused or not current_wave_data or wave_timer.is_stopped(): return
	if alive_enemy_count() + pending_spawns >= max_alive_enemies:
		start_spawn_timer()
		return
	var enemy_scene := get_enemy_scene()
	if not enemy_scene:
		start_spawn_timer()
		return
	var generation := spawn_generation
	pending_spawns += 1
	# Schedule independently from the visual warning; pending reservations enforce the cap.
	start_spawn_timer()
	var spawn_pos := get_random_spawn_position()
	var spawn_effect := Global.SPAWN_EFFECT_SCENE.instantiate()
	get_parent().add_child(spawn_effect)
	spawn_effect.global_position = spawn_pos
	await spawn_effect.completed
	if generation != spawn_generation: return
	pending_spawns -= 1
	# Ended/exited waves cannot finish an old asynchronous spawn.
	if wave_timer.is_stopped() or not is_instance_valid(Global.player): return
	while Global.game_paused:
		await get_tree().process_frame
		if generation != spawn_generation or wave_timer.is_stopped(): return
	if alive_enemy_count() >= max_alive_enemies:
		return
	var instance := enemy_scene.instantiate() as Enemy
	prepare_enemy(instance)
	instance.global_position = spawn_pos
	get_parent().add_child(instance)
	spawned_enemies.append(instance)

func clear_enemies() -> void:
	spawn_generation += 1
	pending_spawns = 0
	for effect in get_tree().get_nodes_in_group("spawn_effects"):
		effect.complete()
	if spawned_enemies.size() > 0:
		for enemy: Enemy in spawned_enemies:
			if is_instance_valid(enemy):
				enemy.destroy_enemy()
	
	spawned_enemies.clear()

func get_wave_timer_text() -> String:
	return str(int(wave_timer.time_left + 1))

func get_wave_text() -> String:
	return "Wave %d%s" % [wave_index, " - Horde" if DIFFICULTY_RULES.is_horde(difficulty_index, wave_index) else ""]

func reset_run(level: int) -> void:
	wave_timer.stop()
	spawn_timer.stop()
	wave_timer.paused = false
	spawn_timer.paused = false
	clear_enemies()
	clear_fueguito()
	wave_index = 1
	difficulty_index = level
	current_wave_data = null

func _on_spawn_timer_timeout() -> void:
	if not current_wave_data or wave_timer.is_stopped():
		spawn_timer.stop()
		return
	
	spawn_enemy()


func _on_wave_timer_timeout() -> void:
	Global.game_paused = true
	clear_fueguito()
	on_wave_completed.emit()
	spawn_timer.stop()
	clear_enemies()
