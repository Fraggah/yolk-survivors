extends WeaponBehaviour
class_name RangeBehaviour

@onready var muzzle: Marker2D = %Muzzle
var burst_generation := 0

func reset_attack() -> void:
	burst_generation += 1
	super.reset_attack()

func execute_attack() -> void:
	weapon.is_attacking = true
	
	var settings := weapon.data.stats.ranged_settings
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
	
	
	tween.finished.connect(func():
		weapon.is_attacking = false
		critical = false
	)

func create_projectile() -> void:
	var settings := weapon.data.stats.ranged_settings
	var count := settings.projectile_count if settings else 1
	for index in count:
		var offset := deg_to_rad(settings.spread_degrees) * (float(index) / maxf(1.0, count - 1) - 0.5) if settings and count > 1 else 0.0
		_spawn_projectile(offset)
	if settings and settings.leaves_pit:
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

func _spawn_projectile(angle_offset: float) -> void:
	var instance := weapon.data.stats.projectile_scene.instantiate() as Projectile
	get_tree().root.add_child(instance)
	instance.global_position = muzzle.global_position
	
	var velocity := Vector2.RIGHT.rotated(weapon.rotation + angle_offset) * weapon.data.stats.projectile_speed
	# Match the detection circle's world-space radius, including the entity scale.
	var travel_range := weapon.data.stats.max_range * absf(weapon.collision.global_scale.x)
	instance.setup_projectile(velocity, get_base_damage(), false, weapon.data.stats.knockback, weapon.get_parent(), travel_range)
	configure_hit_criticals(instance.hitbox)
	instance.hitbox.life_steal_chance = get_life_steal_chance()
	instance.hitbox.weapon_damage_record = weapon.damage_record
	var player_stats: UnitStats = weapon.get_parent().stats
	instance.remaining_piercing = weapon.data.get_effective_piercing(player_stats)
	instance.remaining_bounces = weapon.data.get_effective_bounces(player_stats)
	if instance.has_method("configure_effects"): instance.configure_effects(weapon.data.stats.ranged_settings)
