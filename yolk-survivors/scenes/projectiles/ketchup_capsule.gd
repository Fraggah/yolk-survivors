extends Projectile
var effects: RangedSettings
var impact_direction := Vector2.RIGHT
var impact_directions: Dictionary = {}
var splattered_targets: Dictionary = {}
var initial_shot_range := 0.0

func _ready() -> void:
	super._ready()
	hitbox.damage_dealt.connect(_on_damage_dealt)

func configure_effects(settings: RangedSettings) -> void:
	effects = settings

func setup_projectile(projectile_velocity: Vector2, damage: float, critical: bool, knockback: float, unit: Node2D, travel_range: float = INF) -> void:
	super.setup_projectile(projectile_velocity, damage, critical, knockback, unit, travel_range)
	impact_direction = projectile_velocity.normalized()
	initial_shot_range = travel_range

func _on_hitbox_component_on_hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	if Global.game_paused or is_queued_for_deletion() or hit_targets.has(hurtbox.get_instance_id()): return
	# Capture the incoming direction before the base projectile can bounce.
	impact_direction = velocity.normalized()
	impact_directions[hurtbox.get_instance_id()] = impact_direction
	super._on_hitbox_component_on_hit_hurtbox(hurtbox)

func _on_damage_dealt(target: Unit, _amount: float) -> void:
	if not effects or not target is Enemy or splattered_targets.has(target.get_instance_id()): return
	splattered_targets[target.get_instance_id()] = true
	var hurtbox := target.get_node("HurtboxComponent") as HurtboxComponent
	var direction: Vector2 = impact_directions.get(hurtbox.get_instance_id(),impact_direction)
	# Keep the capsule's rolled damage, including its critical, without a second roll.
	var droplet_damage := hitbox.damage * effects.splatter_damage_multiplier
	var origin := hurtbox.global_position + direction * 5.0 * Global.GAME_ENTITY_SCALE
	# Physics callbacks cannot safely insert new collision shapes immediately.
	call_deferred("_spawn_splatter", origin, direction, hurtbox.get_instance_id(), droplet_damage, hitbox.critical)

func _spawn_splatter(origin: Vector2, direction: Vector2, excluded_hurtbox: int, droplet_damage: float, was_critical: bool) -> void:
	for index in effects.splatter_count:
		var offset := deg_to_rad(effects.splatter_spread_degrees) * (float(index) / maxf(1.0, effects.splatter_count - 1) - 0.5) if effects.splatter_count > 1 else 0.0
		var arena := get_tree().current_scene as Arena
		var droplet: Projectile
		if arena:
			droplet = arena.projectile_pool.acquire_drop()
		else:
			droplet = load("res://scenes/projectiles/projectile_ketchup_drop.tscn").instantiate()
			(get_tree().current_scene if get_tree().current_scene else get_tree().root).add_child(droplet)
		droplet.global_position = origin
		droplet.setup_projectile(direction.rotated(offset) * effects.splatter_speed, droplet_damage, was_critical, 0.0, hitbox.source, initial_shot_range * effects.splatter_range_multiplier)
		droplet.hitbox.weapon_damage_record = hitbox.weapon_damage_record
		droplet.hitbox.life_steal_chance = hitbox.life_steal_chance
		for effect in hitbox.status_effects:
			if not droplet.hitbox.status_effects.has(effect): droplet.hitbox.status_effects.append(effect)
		# Droplets must leave the struck enemy and damage enemies behind it.
		droplet.hitbox._hit_hurtboxes[excluded_hurtbox] = true
		droplet.hit_targets[excluded_hurtbox] = true
