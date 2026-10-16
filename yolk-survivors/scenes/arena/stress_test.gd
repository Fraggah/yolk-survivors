extends Node
## Isolated endless load test. Ordinary wave/profile caps remain unchanged.
@export var target_population := 1000
@export var batch_size := 100
@export var batch_interval := 2.0
@export var spawn_per_frame := 10
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
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	label = Label.new()
	label.position = Vector2(22,190)
	label.add_theme_font_size_override("font_size",22)
	label.add_theme_color_override("font_color",Color.WHITE)
	label.add_theme_color_override("font_outline_color",Color.BLACK)
	label.add_theme_constant_override("outline_size",5)
	layer.add_child(label)
	label.hide()

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
	Engine.time_scale = 1.0
	label.show()
	_update_hud()

func stop() -> void:
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
		batch_left = batch_interval
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
	label.text = "PRUEBA DE ESTRÉS — INMORTAL\nEnemigos: %d / %d   Generados: %d\nFPS: %d   Armas: 6\nPausa: Esc / Start" % [enemies.size(),target_population,total_spawned,Engine.get_frames_per_second()]
