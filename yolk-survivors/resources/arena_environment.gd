extends Resource
class_name ArenaEnvironment
## Art, geometry and camera settings for a cooking arena.

@export var first_wave := 1
@export var background: Texture2D
@export var vessel: Texture2D
@export var background_size := Vector2(6144, 4096)
@export var background_offset := Vector2.ZERO
@export var vessel_size := Vector2(2900, 1900)
@export var vessel_offset := Vector2.ZERO
@export var movement_bounds := Rect2(-1000, -500, 2000, 985)
@export var oval := false
@export var corner_radius := 0.0
@export var camera_zoom := 1.0

func clamp_position(point: Vector2) -> Vector2:
	if not oval:
		var bounded := Vector2(clampf(point.x, movement_bounds.position.x, movement_bounds.end.x),
			clampf(point.y, movement_bounds.position.y, movement_bounds.end.y))
		if corner_radius <= 0.0: return bounded
		var inner := movement_bounds.grow(-corner_radius)
		var nearest := Vector2(clampf(bounded.x, inner.position.x, inner.end.x),
			clampf(bounded.y, inner.position.y, inner.end.y))
		return nearest + (bounded - nearest).limit_length(corner_radius)
	var center := movement_bounds.get_center()
	var radii := movement_bounds.size * 0.5
	var normalized := (point - center) / radii
	if normalized.length_squared() > 1.0:
		normalized = normalized.normalized()
	return center + normalized * radii

func random_spawn_position() -> Vector2:
	if oval:
		# Square root gives uniform area density rather than clustering at the center.
		return movement_bounds.get_center() + Vector2.RIGHT.rotated(randf() * TAU) \
			* sqrt(randf()) * movement_bounds.size * 0.5
	while true:
		var point := Vector2(randf_range(movement_bounds.position.x, movement_bounds.end.x),
			randf_range(movement_bounds.position.y, movement_bounds.end.y))
		if clamp_position(point).is_equal_approx(point): return point
	return movement_bounds.get_center()

## Distance to the playable boundary, including rounded corners and oval arenas.
func boundary_clearance(point: Vector2) -> float:
	if not clamp_position(point).is_equal_approx(point): return 0.0
	var offset := (point - movement_bounds.get_center()).abs()
	var half := movement_bounds.size * 0.5
	if not oval:
		var radius := clampf(corner_radius, 0.0, minf(half.x, half.y))
		var q := offset - (half - Vector2.ONE * radius)
		return maxf(0.0, radius - q.max(Vector2.ZERO).length() - minf(maxf(q.x, q.y), 0.0))
	# Locate the closest arc, then refine it; no bounding-box approximation for ovals.
	var best_angle := 0.0
	var best_distance := INF
	var step := PI * 0.5 / 24.0
	for index in 25:
		var angle := index * step
		var distance := (Vector2(cos(angle), sin(angle)) * half).distance_squared_to(offset)
		if distance < best_distance:
			best_distance = distance
			best_angle = angle
	var low := maxf(0.0, best_angle-step)
	var high := minf(PI*0.5, best_angle+step)
	for iteration in 16:
		var a := lerpf(low,high,1.0/3.0)
		var b := lerpf(low,high,2.0/3.0)
		if (Vector2(cos(a),sin(a))*half).distance_squared_to(offset) < (Vector2(cos(b),sin(b))*half).distance_squared_to(offset): high=b
		else: low=a
	var middle := (low+high)*0.5
	return sqrt(minf(best_distance,(Vector2(cos(middle),sin(middle))*half).distance_squared_to(offset)))
