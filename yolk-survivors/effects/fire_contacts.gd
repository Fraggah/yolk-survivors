extends Node
## Exact broad phase for area effects. Swept cells retain crossings between frames.
@export_range(32.0,256.0,8.0) var cell_size := 96.0
@export var merge_ground_damage := true
@export_range(0.0,0.25,0.01) var ground_ignition_refresh := 0.1
@export var scheduled_burns := true
@export var cache_status_profiles := true
@export var deduplicate_electric_attacks := true
class Sample extends RefCounted:
	var enemy: Node2D
	var previous: Vector2
	var point: Vector2
	var stamp := 0
	var hurt_point: Vector2
	var hurt_previous: Vector2
	var padding := 0.0
var samples: Dictionary = {}
var cells: Dictionary = {}
var sampled_frame := -1
var query_stamp := 0
var max_hurtbox_padding := 0.0
var profile_enabled := false
var profile_costs: Dictionary = {}
var clock := 0.0
var damage_deadlines: Dictionary = {}
var ignition_deadlines: Dictionary = {}
var cleanup_left := 1.0
var burns: Array[WeakRef] = []

func finish_profile(label: String, started: int) -> void:
	if profile_enabled: profile_costs[label] = float(profile_costs.get(label,0.0))+(Time.get_ticks_usec()-started)/1000.0

func _process(_delta: float) -> void:
	var started := Time.get_ticks_usec() if profile_enabled else 0
	_advance(_delta)
	finish_profile("fire_index_scheduler",started)

func _advance(_delta: float) -> void:
	if Global.game_paused: return
	clock += _delta
	var active_burns: Array[WeakRef] = []
	for reference in burns:
		var burn = reference.get_ref()
		if not is_instance_valid(burn) or burn.is_queued_for_deletion(): continue
		active_burns.append(reference)
		if clock+0.00001>=burn.next_update_clock: burn.sync_clock()
	burns = active_burns
	cleanup_left -= _delta
	if cleanup_left<=0.0:
		cleanup_left = 1.0
		for table in [damage_deadlines,ignition_deadlines]:
			for weapon_id in table.keys():
				if not is_instance_id_valid(weapon_id): table.erase(weapon_id); continue
				for enemy_id in table[weapon_id].keys():
					if not is_instance_id_valid(enemy_id) or table[weapon_id][enemy_id]<clock-1.0: table[weapon_id].erase(enemy_id)
	rebuild()

func claim_ground(enemy_id: int, weapon_id: int, interval: float, ignition: bool = false) -> bool:
	if not merge_ground_damage or sampled_frame!=Engine.get_process_frames(): return true
	var table := ignition_deadlines if ignition else damage_deadlines
	if not table.has(weapon_id): table[weapon_id] = {}
	var next: float = table[weapon_id].get(enemy_id,-1.0)
	if clock+0.00001<next: return false
	table[weapon_id][enemy_id] = clock+interval if next<clock-interval else next+interval
	return true

func rebuild() -> void:
	cells.clear()
	var next: Dictionary = {}
	max_hurtbox_padding = 0.0
	for enemy in get_tree().get_nodes_in_group("combat_enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health<=0.0: continue
		var id: int = enemy.get_instance_id()
		var sample: Sample = samples.get(id)
		if not sample:
			sample = Sample.new()
			sample.point = enemy.global_position
			sample.hurt_point = enemy.get_node("HurtboxComponent/CollisionShape2D").global_position
		sample.enemy = enemy
		sample.previous = sample.point
		sample.point = enemy.global_position
		next[id] = sample
		var shape := enemy.get_node_or_null("HurtboxComponent/CollisionShape2D") as CollisionShape2D
		if shape:
			sample.hurt_previous = sample.hurt_point
			sample.hurt_point = shape.global_position
			sample.padding = shape.shape.radius*maxf(absf(shape.global_scale.x),absf(shape.global_scale.y)) if shape.shape is CircleShape2D and not shape.disabled else 0.0
			var padding := sample.point.distance_to(shape.global_position)
			if shape.shape is CircleShape2D: padding += shape.shape.radius*maxf(absf(shape.global_scale.x),absf(shape.global_scale.y))
			max_hurtbox_padding = maxf(max_hurtbox_padding,padding)
		var first := Vector2i((sample.previous.min(sample.point)/cell_size).floor())
		var last := Vector2i((sample.previous.max(sample.point)/cell_size).floor())
		for x in range(first.x,last.x+1):
			for y in range(first.y,last.y+1):
				var key := Vector2i(x,y)
				if not cells.has(key): cells[key] = []
				cells[key].append(sample)
	samples = next
	sampled_frame = Engine.get_process_frames()

func query(rect: Rect2) -> Array:
	# Manual effect tests / setup before the first process sample retain exact scans.
	if sampled_frame!=Engine.get_process_frames(): return get_tree().get_nodes_in_group("combat_enemies")
	query_stamp += 1
	var result: Array = []
	var first := Vector2i((rect.position/cell_size).floor())
	var last := Vector2i((rect.end/cell_size).floor())
	for x in range(first.x,last.x+1):
		for y in range(first.y,last.y+1):
			for sample in cells.get(Vector2i(x,y),[]):
				if sample.stamp==query_stamp: continue
				sample.stamp = query_stamp
				if is_instance_valid(sample.enemy): result.append(sample.enemy)
	return result

func previous_position(enemy: Node2D) -> Vector2:
	var sample: Sample = samples.get(enemy.get_instance_id())
	return sample.previous if sample and sampled_frame==Engine.get_process_frames() else enemy.global_position

func live_sample(enemy: Node2D) -> Sample:
	return samples.get(enemy.get_instance_id()) if sampled_frame==Engine.get_process_frames() else null

func clear() -> void:
	samples.clear()
	cells.clear()
	sampled_frame = -1
	damage_deadlines.clear()
	ignition_deadlines.clear()
