extends Node2D
## Each attack rolls exactly once: a Phase 1 grid or five parallel moving lines.
var area: ArenaEnvironment
var config: Resource
var source: Node2D
var random := RandomNumberGenerator.new()
var elapsed := 0.0
var attack_index := -1
var attack_kind := -1 # 0 static, 1 moving
var attack: Node2D
var running := false
var stage := 0
var current_label := "Complex lines"
var history: Array[int] = []
var forced_kind := -1 # Single-attack composition; normal sections keep -1.

func _init() -> void:
	random.randomize()

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	area = geometry
	config = settings
	source = damage_source
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("boss_hazards")
	running = true
	advance(0)

func roll_kind() -> int:
	if forced_kind >= 0: return forced_kind
	if not history.is_empty() and history.back() == 1: return 0
	return 0 if random.randf()<0.5 else 1

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds-0.0000001:
		stop()
		return
	var index := int(floor((elapsed+0.0000001)/config.complex_line_interval))
	if index != attack_index: _begin_attack(index)
	if is_instance_valid(attack):
		var local_time: float = maxf(0,elapsed-index*config.complex_line_interval)
		attack.advance(maxf(0,local_time-attack.elapsed))
		stage = attack.stage

func _begin_attack(index: int) -> void:
	_clear_attack()
	attack_index = index
	attack_kind = roll_kind()
	history.append(attack_kind)
	var settings := config.duplicate()
	settings.section_seconds = config.complex_line_interval
	if attack_kind == 0:
		var cycle: float = config.line_warning_seconds+config.line_active_seconds+config.line_rest_seconds
		var scale_time: float = config.complex_line_interval/maxf(0.001,cycle)
		settings.line_warning_seconds *= scale_time
		settings.line_active_seconds *= scale_time
		settings.line_rest_seconds *= scale_time
		if not config.static_line_patterns.is_empty():
			var patterns: Array[Resource] = [config.static_line_patterns[random.randi_range(0,config.static_line_patterns.size()-1)]]
			settings.static_line_patterns = patterns
		attack = load("res://scenes/bosses/static_fire_lines.gd").new()
		current_label = "Complex lines · Static grid"
	else:
		var directions: Array[Vector2] = []
		for value in config.moving_line_directions:
			var direction: Vector2 = value.normalized()
			if not direction.is_zero_approx() and not directions.has(direction): directions.append(direction)
		var direction := directions[random.randi_range(0,directions.size()-1)] if not directions.is_empty() else Vector2.UP
		settings.moving_line_directions = PackedVector2Array([direction])
		settings.moving_line_interval = config.complex_line_interval
		settings.moving_line_warning_seconds = config.complex_moving_warning_seconds
		settings.moving_line_travel_seconds = config.complex_moving_travel_seconds
		settings.moving_line_triple_from = 1
		settings.moving_line_parallel_count = config.complex_moving_parallel_count
		settings.moving_line_triple_spacing = config.complex_moving_spacing
		settings.moving_line_double_attacks = PackedInt32Array()
		attack = load("res://scenes/bosses/moving_fire_lines.gd").new()
		current_label = "Complex lines · Moving parallels"
	add_child(attack)
	attack.setup(area,settings,source)
	attack.remove_from_group("boss_hazards")

func _clear_attack() -> void:
	if is_instance_valid(attack):
		attack.stop()
		attack.queue_free()
	attack = null

func stop() -> void:
	running = false
	stage = 2
	_clear_attack()
	hide()
