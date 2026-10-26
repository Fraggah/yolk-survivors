extends "res://scenes/bosses/rotating_turrets.gd"
var aim_on_spawn := true
var forced_moving := -1 # -1 random, 0 rotating, 1 moving.
var random := RandomNumberGenerator.new()

func _init() -> void:
	random.randomize()

func roll_moving() -> bool:
	if forced_moving >= 0: return forced_moving == 1
	return random.randf()<0.5

func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	aim_on_spawn = settings.turret_target_player
	var mobile := settings.duplicate()
	mobile.turret_positions = settings.mobile_turret_start_positions
	# Honor the configured A endpoint; aim the initial beams instead of moving A.
	mobile.turret_target_player = false
	super.setup(geometry,mobile,damage_source)

func _spawn_batch(batch: int, born: float) -> void:
	if config.turret_positions.is_empty(): return
	super._spawn_batch(batch,born)
	var turret: Dictionary = turrets.back()
	turret.moving = roll_moving()
	if turret.moving: turret.rotation_sign = 0.0
	turret.cue.visible = not turret.moving
	turret.path_start = turret.position
	var destination: Vector2 = turret.position
	if turret.moving and not config.mobile_turret_end_positions.is_empty():
		var fraction: Vector2 = config.mobile_turret_end_positions[(batch+config.rotating_turret_sequence_offset)%config.mobile_turret_end_positions.size()]
		destination = area.clamp_position(area.movement_bounds.position+area.movement_bounds.size*fraction)
	turret.path_end = destination
	if aim_on_spawn and is_instance_valid(Global.nearest_player(area.movement_bounds.get_center())):
		turret.base_angle = turret.body.get_node("RayOrigin").global_position.angle_to_point(Global.nearest_player(area.movement_bounds.get_center()).global_position)
		turret.angle = turret.base_angle
	var path = load("res://scenes/bosses/turret_path_cue.gd").new()
	path.start = turret.path_start
	path.finish = turret.path_end
	add_child(path)
	turret.path_cue = path
	path.visible = turret.moving

func _update_motion(turret: Dictionary, spinning_age: float) -> void:
	if not turret.moving: return
	var duration: float = maxf(0.001,turret.expires_at-turret.firing_at)
	var progress := clampf(spinning_age/duration,0,1)
	turret.position = turret.path_start.lerp(turret.path_end,progress)
	turret.body.position = turret.position
	turret.path_cue.progress = progress
	turret.path_cue.firing = turret.beams.stage==1
	turret.path_cue.queue_redraw()

func _remove_turret(turret: Dictionary) -> void:
	# Retire where the laser stopped, even when a section interrupts the path.
	# Snapping to B first can move the body out of the camera before its exit.
	if turret.has("path_cue") and is_instance_valid(turret.path_cue):
		turret.path_cue.hide()
		turret.path_cue.queue_free()
	super._remove_turret(turret)
