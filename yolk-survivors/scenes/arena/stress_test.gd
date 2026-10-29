extends Node
## Isolated endless load test. Ordinary wave/profile caps remain unchanged.
@export var target_population := 1000
@export var batch_size := 5
@export var batch_interval := 0.1
@export var spawn_per_frame := 1
@export_range(0,1,0.01) var yolk_attraction_chance := 1.0
var active := false
var arena: Arena
var enemies: Array[Enemy] = []
var total_spawned := 0
var pending := 0
var batch_left := 0.0
var hud_left := 0.0
var label: Label
var profile: EnemyProfile = preload("res://resources/wave/enemies/chaser_mid.tres")

func _ready() -> void:
	label=$UI/Status

func start(context: Arena) -> void:
	arena = context
	active = true
	total_spawned = 0
	batch_left = batch_interval
	pending = mini(batch_size,target_population)
	enemies.clear()
	arena.spawner.wave_timer.stop()
	arena.spawner.spawn_timer.stop()
	arena.stage_mechanics.stop()
	arena.spawner.clear_fueguito()
	Global.player.health_component.debug_invulnerable = true
	Global.player.passive_items.debug_yolk_magnet_chance = yolk_attraction_chance
	Engine.time_scale = 1.0
	label.show()
	_update_hud()

func stop() -> void:
	if active and is_instance_valid(Global.player) and is_instance_valid(Global.player.passive_items):
		Global.player.passive_items.debug_yolk_magnet_chance = -1.0
	active = false
	pending = 0
	enemies.clear()
	label.hide()

func _process(delta: float) -> void:
	if not active or not is_instance_valid(arena) or not arena.in_arena: return
	if Global.game_paused: return
	batch_left -= delta
	hud_left -= delta
	if hud_left <= 0.0:
		enemies = enemies.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0)
		_update_hud()
		hud_left = 0.25
	if batch_left <= 0.0:
		pending += mini(batch_size,maxi(0,target_population-enemies.size()-pending))
		# Keep the cadence without releasing multiple overdue batches after a stall.
		batch_left = maxf(0.0,batch_left+batch_interval)
	for i in mini(spawn_per_frame,pending):
		if enemies.size() >= target_population:
			pending = 0
			break
		if _spawn_enemy(): pending -= 1
		else: break

func _spawn_enemy() -> bool:
	var point := arena.spawner.get_safe_spawn_position(profile)
	if not point.is_finite(): return false
	var enemy := profile.scene.instantiate() as Enemy
	arena.spawner.prepare_enemy(enemy,profile)
	enemy.position = point
	arena.add_child(enemy)
	arena.spawner.spawned_enemies.append(enemy)
	enemies.append(enemy)
	total_spawned += 1
	return true

func _update_hud() -> void:
	label.text = "PRUEBA DE ESTRÉS — INMORTAL\nEnemigos: %d / %d   Generados: %d\nFPS: %d   Armas: 6\nAtracción de yemas: %d%%\nPausa: Esc / Start" % [enemies.size(),target_population,total_spawned,Engine.get_frames_per_second(),roundi(yolk_attraction_chance*100)]
