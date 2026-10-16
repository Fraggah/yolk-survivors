extends Projectile
var arena_environment: ArenaEnvironment

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	super.setup_projectile(projectile_velocity, damage, critical, knockback, unit, travel_range)
	if unit is Player: arena_environment = unit.arena_environment

func _process(delta: float) -> void:
	if Global.game_paused or is_queued_for_deletion(): return
	super._process(delta)
	if arena_environment:
		var bounds := Rect2(arena_environment.background_offset - arena_environment.background_size * 0.5, arena_environment.background_size)
		var sprite := get_node("Sprite2D") as Sprite2D
		var footprint := sprite.global_transform * sprite.get_rect()
		# Wait until the entire rolling pin has left the full world background.
		if not bounds.intersects(footprint): queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Camera visibility does not limit this arena-wide shot.
	pass
