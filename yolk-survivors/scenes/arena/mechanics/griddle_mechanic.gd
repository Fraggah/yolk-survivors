extends StageMechanic

@export var initial_delay := 0.8
@export var minimum_interval := 0.9
@export var maximum_interval := 1.5
@export var radius := 350.0
@export var damage := 2.0
@export var warning_duration := 1.0
@export var active_duration := 12.0
@export var cooling_duration := 1.2
@export var damage_interval := 0.75
@export_range(1, 12) var maximum_zones := 6
@export_range(0.0, 200.0) var minimum_zone_gap := 8.0
@export var breathing_period := 2.5
@export_range(0.2, 0.9) var damage_core_ratio := 0.60
@export_group("Heat distortion")
@export var distortion_enabled := true
@export_range(0.0, 20.0) var distortion_strength_pixels := 5.5
@export_range(0.0, 10.0) var distortion_vertical_pixels := 1.5
@export_range(0.0, 600.0) var distortion_height := 180.0
@export_range(0.0, 5.0) var distortion_speed := 1.0
var next_zone := 0.0

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	super.start(context, geometry)
	z_index = -2
	if distortion_enabled:
		var screen_copy := BackBufferCopy.new()
		screen_copy.name = "HeatScreenCopy"
		screen_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
		screen_copy.z_as_relative = false
		screen_copy.z_index = 4
		add_child(screen_copy)
	next_zone = maxf(0.05, initial_delay)

func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	next_zone -= delta
	if next_zone <= 0.0:
		spawn_zone()
		next_zone = random_interval(minimum_interval, maximum_interval)

func spawn_zone() -> StageAreaEffect:
	if not active or Global.game_paused or live_effect_count() >= maximum_zones: return null
	var effective_radius := maxf(10.0, radius)
	var point := Vector2.INF
	for attempt in 32:
		var candidate := random_effect_position(effective_radius * damage_core_ratio)
		if candidate.is_finite() and is_zone_position_free(candidate, effective_radius):
			point = candidate
			break
	if not point.is_finite(): return null
	var zone = preload("res://scenes/arena/mechanics/hot_zone_effect.gd").new()
	zone.mechanic = self
	zone.radius = effective_radius
	zone.damage = maxf(0, damage)
	zone.warning_duration = maxf(0.05, warning_duration)
	zone.active_duration = maxf(0.05, active_duration)
	zone.cooling_duration = maxf(0.05, cooling_duration)
	zone.damage_interval = maxf(0.05, damage_interval)
	zone.distortion_enabled = distortion_enabled
	zone.distortion_strength_pixels = distortion_strength_pixels
	zone.distortion_vertical_pixels = distortion_vertical_pixels
	zone.distortion_height = distortion_height
	zone.distortion_speed = distortion_speed
	zone.shape_phase = random.randf_range(0, TAU)
	zone.breathing_offset = random.randf_range(0, TAU)
	zone.breathing_period = maxf(0.1, breathing_period)
	zone.damage_core_ratio = clampf(damage_core_ratio, 0.2, 0.9)
	add_child(zone)
	zone.global_position = point
	return zone

func is_zone_position_free(point: Vector2, new_radius: float) -> bool:
	for child in get_children():
		if child is StageAreaEffect and not child.is_queued_for_deletion():
			var separation: float = new_radius * damage_core_ratio + child.radius * child.damage_core_ratio + maxf(0, minimum_zone_gap)
			if point.distance_squared_to(child.global_position) < separation * separation:
				return false
	return true
