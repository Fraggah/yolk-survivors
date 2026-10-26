extends Node2D
## Full-width barriers enter from outside the background and sweep across it.
var area: ArenaEnvironment
var config: Resource
var source: Node2D
var elapsed := 0.0
var attack_index := -1
var stage := -1
var running := false
var renderer: Node2D
var arrows: Control
var barriers: Array[Dictionary] = []
var warning_directions: Array[Vector2] = []

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	area = geometry
	config = settings
	source = damage_source
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("boss_hazards")
	renderer = load("res://scenes/bosses/static_fire_lines.gd").new()
	renderer.config = config.duplicate()
	renderer.persistent_glow = true
	renderer.config.line_width = config.moving_line_width
	renderer.config.line_damage = config.moving_line_damage
	renderer.source = source
	add_child(renderer)
	arrows = load("res://scenes/bosses/moving_line_arrows.gd").new()
	arrows.section = self
	source.get_parent().get_node("GameUI").add_child(arrows)
	running = true
	advance(0)

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if elapsed >= config.section_seconds-0.0000001:
		stop()
		return
	if config.moving_line_directions.is_empty(): return
	var index := int(floor((elapsed+0.0000001)/config.moving_line_interval))
	if index != attack_index: _begin_attack(index)
	var local_time: float = maxf(0,elapsed-index*config.moving_line_interval)
	stage = 0 if local_time < config.moving_line_warning_seconds else 1 if local_time < config.moving_line_warning_seconds+config.moving_line_travel_seconds else 2
	var progress := clampf((local_time-config.moving_line_warning_seconds)/config.moving_line_travel_seconds,0,1)
	for barrier in barriers:
		var center: Vector2 = barrier.origin.lerp(barrier.destination,progress)
		barrier.line.visual.position = center
		barrier.line.start = center-barrier.half_span
		barrier.line.end = center+barrier.half_span
	renderer.set_line_stage(stage)
	renderer.animate_lines(elapsed,clampf(local_time/config.moving_line_warning_seconds,0,1))
	arrows.refresh()

func _begin_attack(index: int) -> void:
	renderer._clear_lines()
	renderer.stage = -1
	barriers.clear()
	warning_directions.clear()
	attack_index = index
	var direction: Vector2 = config.moving_line_directions[index%config.moving_line_directions.size()].normalized()
	if direction.is_zero_approx(): return
	_add_barrier(direction)
	if config.moving_line_double_attacks.has(index+1): _add_barrier(direction.orthogonal())

func _add_barrier(direction: Vector2) -> void:
	warning_directions.append(direction)
	var count: int = config.moving_line_parallel_count if attack_index+1 >= config.moving_line_triple_from else 1
	var spacing: float = maxf(0,config.moving_line_triple_spacing) if count > 1 else 0.0
	var center := area.background_offset
	var half_size := area.background_size*0.5
	var tangent := direction.orthogonal()
	# Projection covers every corner, including oblique sweeps. Margin also keeps
	# the flame's visual outskirts outside the background during the whole warning.
	var margin: float = config.moving_line_width+4.0
	var travel_half := absf(direction.x)*half_size.x+absf(direction.y)*half_size.y+margin+spacing*(count-1)*0.5
	var coverage := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),maxf(margin,config.laser_end_overscan))
	var span_half := 0.0
	for corner in [coverage.position,coverage.end,Vector2(coverage.position.x,coverage.end.y),Vector2(coverage.end.x,coverage.position.y)]:
		span_half=maxf(span_half,absf((corner-center).dot(tangent)))
	var half_span := tangent*span_half
	for index in count:
		var offset := direction*(index-(count-1)*0.5)*spacing
		var origin := center-direction*travel_half+offset
		var destination := center+direction*travel_half+offset
		renderer._add_segment(origin-half_span,origin+half_span)
		barriers.append({"direction":direction,"origin":origin,"destination":destination,"half_span":half_span,"line":renderer.lines.back()})

func stop() -> void:
	running = false
	stage = 2
	if is_instance_valid(renderer): renderer.stop()
	barriers.clear()
	warning_directions.clear()
	if is_instance_valid(arrows):
		arrows.hide()
		arrows.queue_free()
	arrows = null
	hide()

func _exit_tree() -> void:
	if is_instance_valid(arrows): arrows.queue_free()
