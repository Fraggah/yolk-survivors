extends Node2D
## 0 grid, 1 moving lines, 2 stationary rotating turret, 3 moving fixed turret.
var area: ArenaEnvironment
var config: Resource
var source: Node2D
var random := RandomNumberGenerator.new()
var elapsed := 0.0
var attack_index := -1
var attack_kind := -1
var stage := 0
var current_label := "Final mix"
var running := false
var attack: Node2D
var preview: Node2D
var attack_origin := 0.0
var preview_origin := 0.0
var preview_index := -1
var schedule: Array[int] = []
var history: Array[int] = []

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

func roll_kind(previous: int) -> int:
	if previous in [1,3]: return 0 if random.randf()<0.5 else 2
	return random.randi_range(0,3)

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds-0.0000001:
		stop()
		return
	var index := int(floor((elapsed+0.0000001)/config.mixed_mechanic_interval))
	while schedule.size() <= index+1 and schedule.size()*config.mixed_mechanic_interval < config.section_seconds:
		schedule.append(roll_kind(schedule.back() if not schedule.is_empty() else -1))
	if index != attack_index: _begin_slot(index)
	var next := index+1
	var warning: float = config.rotating_turret_warning_seconds
	var next_origin: float = next*config.mixed_mechanic_interval-warning
	if next < schedule.size() and schedule[next] in [2,3] and elapsed >= next_origin-0.0000001 and preview_index != next:
		_clear_preview()
		preview = _create_attack(schedule[next],warning,next)
		preview_index = next
		preview_origin = next_origin
	if is_instance_valid(attack):
		attack.advance(maxf(0,elapsed-attack_origin-attack.elapsed))
		stage = _child_stage(attack)
	if is_instance_valid(preview): preview.advance(maxf(0,elapsed-preview_origin-preview.elapsed))

func _begin_slot(index: int) -> void:
	_clear_attack()
	attack_index = index
	attack_kind = schedule[index]
	history.append(attack_kind)
	current_label = "Final mix · "+["Static grid","Moving parallels","Rotating turret","Moving turret"][attack_kind]
	if preview_index == index and is_instance_valid(preview):
		attack = preview
		attack_origin = preview_origin
		preview = null
		preview_index = -1
	else:
		_clear_preview()
		var lead: float = config.rotating_turret_warning_seconds if index>0 and attack_kind in [2,3] else 0.0
		attack = _create_attack(attack_kind,lead,index)
		attack_origin = index*config.mixed_mechanic_interval-lead

func _create_attack(kind: int, lead: float, sequence: int) -> Node2D:
	var settings := config.duplicate()
	settings.section_seconds = config.mixed_mechanic_interval+lead
	var child: Node2D
	if kind in [0,1]:
		settings.complex_line_interval = config.mixed_mechanic_interval
		child = load("res://scenes/bosses/complex_fire_lines.gd").new()
		child.forced_kind = kind
	elif kind == 2:
		child = load("res://scenes/bosses/rotating_turrets.gd").new()
	else:
		child = load("res://scenes/bosses/mobile_rotating_turrets.gd").new()
		child.forced_moving = 1
	if kind in [2,3]:
		settings.rotating_turret_interval = config.mixed_mechanic_interval
		settings.rotating_turret_lifetime = config.mixed_mechanic_interval+lead
		settings.rotating_turret_spawn_limit = 1
		settings.rotating_turret_sequence_offset = sequence
	add_child(child)
	child.setup(area,settings,source)
	child.remove_from_group("boss_hazards")
	return child

func _child_stage(child: Node2D) -> int:
	if attack_kind in [0,1]: return child.stage
	if child.turrets.is_empty(): return 2
	return child.turrets[0].beams.stage

func _clear_attack() -> void:
	if is_instance_valid(attack):
		attack.stop()
		attack.queue_free()
	attack = null

func _clear_preview() -> void:
	if is_instance_valid(preview):
		preview.stop()
		preview.queue_free()
	preview = null
	preview_index = -1

func stop() -> void:
	running = false
	stage = 2
	_clear_attack()
	_clear_preview()
	hide()
