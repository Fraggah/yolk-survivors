extends Node
## Spatial separation replaces N large monitoring Areas and their overlap pairs.
const CELL_SIZE := 96.0
const GRID_INTERVAL := 0.05
const MAX_NEIGHBORS := 16
const MAX_CANDIDATES := 64
const UPDATES_PER_FRAME := 32
@export_range(4,64,4) var updates_per_frame := 12
class Entry extends RefCounted:
	var ref: WeakRef
	var position: Vector2
	var sensor: CollisionShape2D
	var radius: float
	var body: float
	var steering := Vector2.ZERO
	var slot: int
	var hurtbox_id: int

var members: Dictionary = {}
var member_ids: Array[int] = []
var cells: Dictionary = {}
var offsets: Array[Vector2i] = []
var clock := 0.0
var grid_left := 0.0
var max_body_radius := 0.0
var checks_last_sample := 0
var cursor := 0

func _ready() -> void:
	process_priority = -100
	for x in range(-6,7):
		for y in range(-6,7): offsets.append(Vector2i(x,y))
	offsets.sort_custom(func(a,b): return a.length_squared()<b.length_squared())
	set_process(false)

func register_enemy(enemy: Node2D) -> void:
	var sensor = enemy.get_node("VisionArea/CollisionShape2D")
	var body = enemy.get_node("CollisionShape2D")
	var id := enemy.get_instance_id()
	if members.has(id): return
	var entry := Entry.new()
	entry.ref = weakref(enemy)
	entry.position = enemy.global_position
	entry.sensor = sensor
	entry.radius = sensor.shape.radius*absf(sensor.global_scale.x)
	entry.body = body.shape.radius*absf(body.global_scale.x)
	entry.slot = member_ids.size()
	entry.hurtbox_id = enemy.get_node("HurtboxComponent").get_instance_id()
	members[id] = entry
	member_ids.append(id)
	max_body_radius = maxf(max_body_radius,members[id].body)
	enemy.tree_exiting.connect(unregister_enemy.bind(id),CONNECT_ONE_SHOT)
	grid_left = 0.0
	set_process(true)

func unregister_enemy(id: int) -> void:
	if not members.has(id): return
	var slot: int = members[id].slot
	var last: int = member_ids.back()
	member_ids[slot] = last
	members[last].slot = slot
	member_ids.pop_back()
	members.erase(id)
	if members.is_empty():
		cells.clear()
		max_body_radius = 0.0
		set_process(false)

func _process(delta: float) -> void:
	var started := Time.get_ticks_usec() if FireContacts.profile_enabled else 0
	_advance_crowd(delta)
	FireContacts.finish_profile("crowd",started)

func _advance_crowd(delta: float) -> void:
	if Global.game_paused: return
	clock += delta
	grid_left -= delta
	if grid_left <= 0.0:
		rebuild()
		grid_left = GRID_INTERVAL
	# Fixed work budget avoids every cache expiring together after a slow frame.
	var ids := member_ids
	if ids.is_empty(): return
	for i in mini(updates_per_frame,ids.size()):
		cursor %= ids.size()
		var id: int = ids[cursor]
		cursor += 1
		var enemy = members[id].ref.get_ref()
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion(): continue
		if not enemy.can_move or enemy.get_movement_multiplier()<=0.0 or (not enemy.movement_override_enabled and not enemy.can_move_towards_player() and enemy.knockback_power<=0):
			members[id].steering = Vector2.ZERO
			enemy.crowd_steering = Vector2.ZERO
			continue
		_calculate(enemy,id)

func rebuild() -> void:
	cells.clear()
	for id in members:
		var entry: Entry = members[id]
		var enemy = entry.ref.get_ref()
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health<=0: continue
		entry.position = enemy.global_position
		var cell := Vector2i((entry.position/CELL_SIZE).floor())
		if not cells.has(cell): cells[cell] = []
		cells[cell].append(id)

func separation(enemy: Node2D) -> Vector2:
	var id := enemy.get_instance_id()
	if not members.has(id): return Vector2.ZERO
	return members[id].steering

func reset_steering(enemy: Node2D) -> void:
	enemy.crowd_steering = Vector2.ZERO
	var id := enemy.get_instance_id()
	if members.has(id): members[id].steering = Vector2.ZERO

func random_target(excluded_hurtboxes: Dictionary) -> Node2D:
	if member_ids.is_empty(): return null
	# Rejection sampling preserves the old uniform choice without allocating and
	# scanning every enemy for every bounce. Fall back when most have been hit.
	for i in 8:
		var candidate := _bounce_candidate(member_ids.pick_random(),excluded_hurtboxes)
		if candidate: return candidate
	var chosen: Node2D
	var eligible := 0
	for id in member_ids:
		var candidate := _bounce_candidate(id,excluded_hurtboxes)
		if candidate:
			eligible += 1
			if randi_range(1,eligible)==1: chosen = candidate
	return chosen

func _bounce_candidate(id: int, excluded: Dictionary) -> Node2D:
	var entry: Entry = members[id]
	if excluded.has(entry.hurtbox_id): return null
	var enemy = entry.ref.get_ref()
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health<=0: return null
	return enemy

func nearest(origin: Vector2, radius: float) -> Node2D:
	var center := Vector2i((origin/CELL_SIZE).floor())
	var reach := ceili(radius/CELL_SIZE)
	var best_distance := radius*radius
	var best: Node2D
	if reach>6:
		# Unusually long-range resources still get correct acquisition.
		for entry in members.values():
			var enemy = entry.ref.get_ref()
			if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not enemy.targetable or enemy.is_retiring or enemy.health_component.current_health<=0: continue
			var distance := origin.distance_squared_to(enemy.global_position)
			if distance<=best_distance:
				best = enemy
				best_distance = distance
		return best
	# Search nearby cells first, then prune cells farther than the current best.
	for offset in offsets:
		if absi(offset.x)>reach or absi(offset.y)>reach: continue
		var key := center+offset
		if not cells.has(key): continue
		var corner := Vector2(key)*CELL_SIZE
		var closest := Vector2(clampf(origin.x,corner.x,corner.x+CELL_SIZE),clampf(origin.y,corner.y,corner.y+CELL_SIZE))
		if origin.distance_squared_to(closest)>best_distance: continue
		for id in cells[key]:
			if not members.has(id): continue
			var entry: Entry = members[id]
			var distance := origin.distance_squared_to(entry.position)
			if distance>best_distance: continue
			var enemy = entry.ref.get_ref()
			if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not enemy.targetable or enemy.is_retiring or enemy.health_component.current_health<=0: continue
			# Check the live position before accepting a cached-grid candidate.
			distance = origin.distance_squared_to(enemy.global_position)
			if distance<=best_distance:
				best = enemy
				best_distance = distance
	return best

func nearby(origin: Vector2, radius: float, excluded: int, limit: int, y_ratio: float = 0.6) -> Array:
	var center := Vector2i((origin/CELL_SIZE).floor())
	var reach := ceili(radius/CELL_SIZE)
	var found: Array = []
	var checked := 0
	for offset in offsets:
		if absi(offset.x)>reach or absi(offset.y)>reach: continue
		var bucket: Array = cells.get(center+offset,[])
		for id in bucket:
			if id==excluded or not members.has(id): continue
			checked += 1
			var entry: Entry = members[id]
			var delta: Vector2 = entry.position-origin
			delta.y /= maxf(0.01,y_ratio)
			if delta.length_squared()<=radius*radius:
				var enemy = entry.ref.get_ref()
				if is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.targetable and not enemy.is_retiring and enemy.health_component.current_health>0:
					found.append(enemy)
					if found.size()>=limit: return found
			if checked>=128: return found
	return found

func _calculate(enemy: Node2D, id: int) -> Vector2:
	var entry: Entry = members[id]
	var center: Vector2 = entry.sensor.global_position
	var cell := Vector2i((center/CELL_SIZE).floor())
	var reach := ceili((entry.radius+max_body_radius)/CELL_SIZE)
	var steering := Vector2.ZERO
	var neighbors := 0
	var checked := 0
	for offset in offsets:
		if absi(offset.x)>reach or absi(offset.y)>reach: continue
		var bucket: Array = cells.get(cell+offset,[])
		if bucket.is_empty(): continue
		# Rotate samples in dense cells instead of favoring the oldest instances.
		var start := (id+int(clock*10))%bucket.size()
		var samples := mini(bucket.size(),4)
		var weight := float(bucket.size())/samples
		for index in samples:
			var other_id: int = bucket[(start+index)%bucket.size()]
			if other_id==id or not members.has(other_id): continue
			checked += 1
			var other: Entry = members[other_id]
			var radius: float = entry.radius+other.body
			if center.distance_squared_to(other.position)>radius*radius: continue
			var vector: Vector2 = enemy.global_position-other.position
			var distance_squared := vector.length_squared()
			if distance_squared>0.001:
				steering += enemy.flock_push * vector / distance_squared * weight
				neighbors += 1
			if neighbors>=MAX_NEIGHBORS or checked>=MAX_CANDIDATES: break
		if neighbors>=MAX_NEIGHBORS or checked>=MAX_CANDIDATES: break
	checks_last_sample = checked
	# Near-coincident bodies (for example a harpoon's captured group) must not
	# turn the inverse-distance separation into an extreme velocity multiplier.
	entry.steering = entry.steering.lerp(steering.limit_length(1.0),0.5)
	enemy.crowd_steering = entry.steering
	return entry.steering
