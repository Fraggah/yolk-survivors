extends StageMechanic

enum State { WAITING, ENTERING, ACTIVE, EXITING, RESTING }
@export var spawn_delay := 1.0
@export var active_duration := 5.0
@export var rest_duration := 1.0
@export var flare_duration := 0.45
@export_range(1, 32) var maximum_active := 16
@export var separation_distance := 120.0
@export var separation_force := 150.0
@export var profile: EnemyProfile
var state := State.WAITING
var phase_time := 0.0
var batch_size := 1
var pending := 0
var hazards: Array[Enemy] = []
var spawn_points: Array[Vector2] = []

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	super.start(context, geometry)

func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	phase_time += delta
	match state:
		State.WAITING:
			if phase_time >= maxf(0.05, spawn_delay): begin_batch()
		State.ENTERING:
			if phase_time >= maxf(0.05, flare_duration): materialize_batch()
		State.ACTIVE:
			separate_hazards(delta)
			if phase_time >= maxf(0.05, active_duration): retire_batch()
		State.EXITING:
			if phase_time >= maxf(0.05, flare_duration): state = State.RESTING; phase_time = 0
		State.RESTING:
			if phase_time >= maxf(0.0, rest_duration - flare_duration * 2.0):
				batch_size = mini(batch_size + 1, maximum_active)
				begin_batch()

func create_flare(point: Vector2) -> void:
	var flare = preload("res://scenes/arena/mechanics/flame_transition.gd").new()
	flare.duration = maxf(0.05, flare_duration)
	add_child(flare)
	flare.global_position = point

func begin_batch() -> void:
	SoundManager.play_sound(SoundManager.Sound.FUEGUITO)
	if not active or Global.game_paused or not profile: return
	spawn_points.clear()
	for index in mini(batch_size, maximum_active):
		for attempt in 32:
			var point := spawner.get_safe_spawn_position(profile)
			if not point.is_finite(): break
			var free := true
			for other in spawn_points:
				if point.distance_to(other) < separation_distance: free = false; break
			if not free: continue
			spawn_points.append(point)
			create_flare(point)
			break
	pending = spawn_points.size()
	state = State.ENTERING
	phase_time = 0

func materialize_batch() -> void:
	if not active or Global.game_paused: return
	for point in spawn_points:
		# The flare owns its location: cancel unsafe arrivals rather than teleport.
		if not is_instance_valid(Global.player) or Global.player.global_position.distance_to(point) < spawner.spawn_relocation_distance: continue
		var enemy := profile.scene.instantiate() as Enemy
		spawner.prepare_enemy(enemy, profile)
		enemy.stats.coin_drop = 0
		enemy.stats.experience_reward = 0
		enemy.targetable = false
		enemy.set_meta("stage_hazard", true)
		add_child(enemy)
		enemy.global_position = point
		hazards.append(enemy)
	spawn_points.clear()
	pending = 0
	state = State.ACTIVE
	phase_time = 0

func retire_batch() -> void:
	for enemy in hazards:
		if not is_instance_valid(enemy): continue
		create_flare(enemy.global_position)
		enemy.is_retiring = true
		enemy.get_node("HitboxComponent").disable()
		enemy.hide()
		enemy.set_process(false)
		enemy.queue_free()
	hazards.clear()
	state = State.EXITING
	phase_time = 0

func separate_hazards(delta: float) -> void:
	for i in hazards.size():
		if not is_live(hazards[i]): continue
		for j in range(i + 1, hazards.size()):
			if not is_live(hazards[j]): continue
			var offset := hazards[i].global_position - hazards[j].global_position
			var distance := offset.length()
			if distance >= separation_distance: continue
			var direction := offset / distance if distance > 0.01 else Vector2.RIGHT.rotated(TAU * float(i + j) / maxf(1, hazards.size()))
			var push := direction * maxf(0, separation_force) * (1.0 - distance / maxf(1, separation_distance)) * delta * 0.5
			move_unit(hazards[i], push)
			move_unit(hazards[j], -push)

func stop() -> void:
	for enemy in hazards:
		if is_instance_valid(enemy):
			enemy.is_retiring = true
			enemy.get_node("HitboxComponent").disable()
	pending = 0
	spawn_points.clear()
	super.stop()
	hazards.clear()
