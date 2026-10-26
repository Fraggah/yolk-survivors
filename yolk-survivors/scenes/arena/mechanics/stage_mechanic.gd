extends Node2D
class_name StageMechanic

var spawner: Spawner
var area: ArenaEnvironment
var active := false
var random := RandomNumberGenerator.new()

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	spawner = context
	area = geometry
	active = true
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_priority = 50
	random.randomize()

func stop() -> void:
	active = false
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()
	for child in get_children():
		if child.has_method("complete"): child.complete()
		if child is CanvasItem: child.hide()
		child.process_mode = Node.PROCESS_MODE_DISABLED
		child.queue_free()

func live_units() -> Array[Unit]:
	var result: Array[Unit] = []
	for actor in Global.live_players(): result.append(actor)
	for list in [spawner.spawned_enemies, spawner.boss_enemies, spawner.special_enemies, spawner.reward_enemies]:
		for unit in list:
			if is_live(unit): result.append(unit)
	return result

func is_live(unit) -> bool:
	return is_instance_valid(unit) and not unit.is_queued_for_deletion() and unit.health_component.current_health > 0.0 and (not unit is Enemy or not unit.is_retiring)

func move_unit(unit: Unit, displacement: Vector2) -> void:
	if active and not Global.game_paused and is_live(unit):
		unit.global_position = area.clamp_position(unit.global_position + displacement)

func random_interval(minimum: float, maximum: float) -> float:
	return random.randf_range(maxf(0.05, minimum), maxf(0.05, maxf(minimum, maximum)))

func random_effect_position(radius: float) -> Vector2:
	for attempt in 32:
		var bounds := area.movement_bounds
		var point := Vector2(random.randf_range(bounds.position.x, bounds.end.x), random.randf_range(bounds.position.y, bounds.end.y))
		var fits := true
		for step in 16:
			var sample := point + Vector2.from_angle(TAU * step / 16.0) * radius
			if not area.clamp_position(sample).is_equal_approx(sample): fits = false; break
		if fits: return point
	return Vector2.INF

func live_effect_count() -> int:
	var count := 0
	for child in get_children():
		if child is StageAreaEffect and not child.is_queued_for_deletion(): count += 1
	return count
