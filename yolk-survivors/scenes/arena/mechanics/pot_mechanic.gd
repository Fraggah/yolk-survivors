extends StageMechanic

@export var initial_delay := 0.5
@export var minimum_interval := 0.25
@export var maximum_interval := 0.55
@export var radii := PackedFloat32Array([55.0, 85.0, 120.0])
@export var damages := PackedFloat32Array([2.0, 4.0, 6.0])
@export var explosion_times := PackedFloat32Array([1.8, 2.8, 4.0])
@export_range(0.1, 5.0) var animation_speed := 1.5
@export var burst_duration := 0.075
@export_range(1, 30) var maximum_bubbles := 12
@export var minimum_gap := 12.0
@export_range(0.1, 0.95) var red_phase_start := 0.75
var next_bubble := 0.0

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	super.start(context, geometry)
	z_index = -2
	next_bubble = maxf(0.05, initial_delay)

func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	next_bubble -= delta
	if next_bubble <= 0.0:
		spawn_bubble()
		next_bubble = random_interval(minimum_interval, maximum_interval)

func spawn_bubble(size_index: int = -1) -> StageAreaEffect:
	if not active or Global.game_paused or radii.is_empty() or live_effect_count() >= maximum_bubbles: return null
	var index := clampi(size_index, 0, radii.size() - 1) if size_index >= 0 else random.randi_range(0, radii.size() - 1)
	var radius := maxf(10.0, radii[index])
	var point := Vector2.INF
	for attempt in 24:
		var candidate := random_effect_position(radius)
		if candidate.is_finite() and is_bubble_position_free(candidate, radius): point = candidate; break
	if not point.is_finite(): return null
	var bubble = preload("res://scenes/arena/mechanics/bubble_effect.gd").new()
	bubble.mechanic = self
	bubble.red_phase_start = red_phase_start
	bubble.radius = radius
	bubble.damage = maxf(0, damages[mini(index, damages.size() - 1)]) if not damages.is_empty() else 0.0
	bubble.warning_duration = maxf(0.1, explosion_times[mini(index, explosion_times.size() - 1)]) if not explosion_times.is_empty() else 1.8
	bubble.warning_duration /= maxf(0.1, animation_speed)
	bubble.burst_duration = maxf(0.05, burst_duration / maxf(0.1, animation_speed))
	add_child(bubble)
	bubble.global_position = point
	return bubble

func is_bubble_position_free(point: Vector2, new_radius: float) -> bool:
	for child in get_children():
		if child is StageAreaEffect and not child.is_queued_for_deletion():
			var separation: float = new_radius + child.radius + maxf(0, minimum_gap)
			if point.distance_squared_to(child.global_position) < separation * separation: return false
	return true
