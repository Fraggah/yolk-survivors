extends WeaponBehaviour
class_name RangeBehaviour

@onready var muzzle: Marker2D = %Muzzle
var burst_generation := 0

func reset_attack() -> void:
	lock_aim_during_attack = false
	burst_generation += 1
	super.reset_attack()

func execute_attack() -> void:
	weapon.is_attacking = true
	
	var settings := weapon.data.stats.ranged_settings
	lock_aim_during_attack = settings != null and settings.lock_burst_aim and settings.burst_count > 1
	if settings and settings.burst_count > 1:
		var generation := burst_generation
		for shot in settings.burst_count:
			get_tree().create_timer(shot * settings.burst_interval, false).timeout.connect(func():
				if generation == burst_generation and is_instance_valid(weapon) and weapon.is_inside_tree() and not Global.game_paused:
					create_projectile()
			)
	else:
		create_projectile()
	
	var tween := create_attack_tween()
	var time_scale := weapon.get_animation_time_scale(weapon.data.stats.recoil_duration * 2.0)
	var attack_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)
	tween.tween_property(weapon.sprite_2d, "position", attack_pos, weapon.data.stats.recoil_duration * time_scale)
	tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, weapon.data.stats.recoil_duration * time_scale)
	if lock_aim_during_attack:
		# Keep aim locked until all scheduled shots have left the muzzle.
		var burst_duration := (settings.burst_count - 1) * settings.burst_interval + 0.01
		var recoil_duration := weapon.data.stats.recoil_duration * 2.0 * time_scale
		if burst_duration > recoil_duration:
			tween.tween_interval(burst_duration - recoil_duration)

	tween.finished.connect(func():
		lock_aim_during_attack = false
		weapon.is_attacking = false
		critical = false
	)

func create_projectile() -> void:
	var settings := weapon.data.stats.ranged_settings
	var count := settings.projectile_count if settings else 1
	for index in count:
		var offset := deg_to_rad(settings.spread_degrees) * (float(index) / maxf(1.0, count - 1) - 0.5) if settings and count > 1 else 0.0
		_spawn_projectile(offset)
	if settings and settings.leaves_pit and settings.pit_projectile_scene:
		_spawn_pit(settings)
	elif settings and settings.leaves_pit:
		var pit = load("res://scenes/projectiles/ranged_area_effect.gd").new()
		get_tree().current_scene.add_child(pit)
		pit.global_position = weapon.get_parent().global_position + Vector2.from_angle(randf() * TAU) * 28.0
		var template := HitboxComponent.new()
		template.setup(get_base_damage(), false, weapon.data.stats.knockback, weapon.get_parent())
		configure_hit_criticals(template)
		template.weapon_damage_record = weapon.damage_record
		template.life_steal_chance = get_life_steal_chance()
		pit.setup(template, settings, true)
		template.free()

func _spawn_pit(settings: RangedSettings) -> void:
	var pit := settings.pit_projectile_scene.instantiate() as Projectile
	(get_tree().current_scene if get_tree().current_scene else get_tree().root).add_child(pit)
	pit.global_position = weapon.global_position
	var deviation := deg_to_rad(randf_range(-settings.pit_deviation_degrees, settings.pit_deviation_degrees))
	var direction := Vector2.RIGHT.rotated(weapon.rotation + PI + deviation)
	var travel_range := weapon.get_effective_range() * absf(weapon.collision.global_scale.x) * settings.pit_range_multiplier
	pit.setup_projectile(direction * settings.pit_projectile_speed, get_base_damage() * settings.pit_damage_multiplier, false, weapon.data.stats.knockback, weapon.get_parent(), travel_range)
	configure_hit_criticals(pit.hitbox)
	pit.hitbox.weapon_damage_record = weapon.damage_record
	pit.hitbox.life_steal_chance = get_life_steal_chance()

func _spawn_projectile(angle_offset: float) -> void:
	var instance := weapon.data.stats.projectile_scene.instantiate() as Projectile
	(get_tree().current_scene if get_tree().current_scene else get_tree().root).add_child(instance)
	instance.global_position = muzzle.global_position
	
	var velocity := Vector2.RIGHT.rotated(weapon.rotation + angle_offset) * weapon.data.stats.projectile_speed
	# Match the detection circle's world-space radius, including the entity scale.
	var travel_range := weapon.get_effective_range() * absf(weapon.collision.global_scale.x)
	if weapon.data.stats.unlimited_range: travel_range = INF
	instance.setup_projectile(velocity, get_base_damage(), false, weapon.data.stats.knockback, weapon.get_parent(), travel_range)
	configure_hit_criticals(instance.hitbox)
	instance.hitbox.life_steal_chance = get_life_steal_chance()
	instance.hitbox.weapon_damage_record = weapon.damage_record
	var player_stats: UnitStats = weapon.get_parent().stats
	instance.remaining_piercing = weapon.data.get_effective_piercing(player_stats)
	instance.unlimited_piercing = weapon.data.stats.unlimited_piercing
	instance.remaining_bounces = weapon.data.get_effective_bounces(player_stats)
	if instance.has_method("configure_effects"): instance.configure_effects(weapon.data.stats.ranged_settings)
	if instance.has_method("configure_target"):
		var landing_point := weapon.closest_target.global_position if is_instance_valid(weapon.closest_target) else muzzle.global_position + velocity.normalized() * travel_range
		instance.configure_target(landing_point)
