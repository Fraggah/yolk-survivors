extends StageMechanic

## Clear floor ellipse; separate from the larger dark, playable slope.
@export var safe_zone_bounds := Rect2(-86.328, -101.562, 657.617, 451.953)
@export var maximum_force := 450.0
@export_range(1.0, 3.0) var force_exponent := 1.5

func start(context: Spawner, geometry: ArenaEnvironment) -> void:
	super.start(context, geometry)
	z_index = -2
	queue_redraw()

func force_at(point: Vector2) -> Vector2:
	var offset := point - safe_zone_bounds.get_center()
	var distance := (offset / (safe_zone_bounds.size * 0.5).max(Vector2.ONE)).length()
	if distance <= 1.0: return Vector2.ZERO
	var outer_distance := ((point - area.movement_bounds.get_center()) / (area.movement_bounds.size * 0.5)).length()
	var penetration := distance - 1.0
	var strength := clampf(penetration / maxf(0.01, penetration + maxf(0, 1.0 - outer_distance)), 0, 1)
	return -offset.normalized() * maxf(0, maximum_force) * pow(strength, force_exponent)

func _process(delta: float) -> void:
	if not active or Global.game_paused: return
	# Use the spawner's bounded lists, not a scene-wide entity search.
	if is_live(Global.player): apply_force(Global.player, delta)
	for list in [spawner.spawned_enemies, spawner.boss_enemies, spawner.special_enemies]:
		for unit in list:
			if is_live(unit): apply_force(unit, delta)

func apply_force(unit: Unit, delta: float) -> void:
	var force := force_at(unit.global_position)
	move_unit(unit, force * delta)

func _draw() -> void:
	if not area: return
	var center := safe_zone_bounds.get_center()
	var radii := safe_zone_bounds.size * 0.5
	for step in 8:
		var direction := Vector2.from_angle(TAU * step / 8.0)
		var at := center + direction * radii * 1.12
		var inward := at.direction_to(center)
		var side := inward.orthogonal()
		draw_polyline(PackedVector2Array([at - inward * 10 + side * 10, at + inward * 8, at - inward * 10 - side * 10]), Color(1, 0.9, 0.65, 0.35), 4, true)
