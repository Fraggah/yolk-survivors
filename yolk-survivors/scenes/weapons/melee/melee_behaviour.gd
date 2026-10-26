extends WeaponBehaviour
class_name MeleBehaviour

@export var hitbox: HitboxComponent
enum AttackMotion { THRUST, SEMICIRCLE }
@export var attack_motion: AttackMotion = AttackMotion.THRUST

func _ready() -> void:
	lock_aim_during_attack = true
	hitbox.hit_once_per_activation = true
	hitbox.disable()

func execute_attack() -> void:
	if attack_motion == AttackMotion.SEMICIRCLE:
		_execute_semicircle()
		return
	weapon.is_attacking = true
	
	var tween := create_attack_tween()
	var stats := weapon.data.stats
	var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration) / maxf(0.01, stats.melee_settings.animation_speed)
	var recoild_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)
	tween.tween_property(weapon.sprite_2d, "position", recoild_pos, weapon.data.stats.recoil_duration * time_scale)
	
	tween.tween_callback(func():
		hitbox.enable()
		hitbox.setup(get_base_damage(), false, weapon.data.stats.knockback, weapon.get_parent())
		configure_hit_criticals(hitbox)
		hitbox.life_steal_chance = get_life_steal_chance()
		hitbox.weapon_damage_record = weapon.damage_record
	)
	
	var attack_pos := Vector2(weapon.atk_start_pos.x + weapon.get_effective_range(), weapon.atk_start_pos.y)
	tween.tween_property(weapon.sprite_2d, "position", attack_pos, weapon.data.stats.attack_duration * time_scale)
	
	tween.tween_callback(func():
		hitbox.disable()
	)
	
	
	tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, weapon.data.stats.back_duration * time_scale)
	
	tween.finished.connect(func():
		weapon.is_attacking = false
		critical = false
	)

func _execute_semicircle() -> void:
	weapon.is_attacking = true
	var stats := weapon.data.stats
	var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration) / maxf(0.01, stats.melee_settings.animation_speed)
	var tween := create_attack_tween()
	var start_position := weapon.atk_start_pos
	var radius := weapon.get_effective_range() * stats.melee_settings.semicircle_radius_multiplier
	var first_angle := deg_to_rad(stats.melee_settings.sweep_start_angle)
	var last_angle := deg_to_rad(stats.melee_settings.sweep_end_angle)
	var arc_start := _sweep_center() + Vector2.from_angle(first_angle) * radius
	tween.tween_property(weapon.sprite_2d, "position", arc_start, stats.recoil_duration * time_scale)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", first_angle, stats.recoil_duration * time_scale)
	tween.tween_callback(func():
		hitbox.setup(get_base_damage(), false, stats.knockback, weapon.get_parent())
		configure_hit_criticals(hitbox)
		hitbox.life_steal_chance = get_life_steal_chance()
		hitbox.weapon_damage_record = weapon.damage_record
		hitbox.enable()
	)
	tween.tween_method(_set_sweep_angle.bind(radius), first_angle, last_angle, stats.attack_duration * time_scale)
	tween.tween_callback(hitbox.disable)
	tween.tween_property(weapon.sprite_2d, "position", start_position, stats.back_duration * time_scale)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, stats.back_duration * time_scale)
	tween.finished.connect(func():
		weapon.is_attacking = false
		critical = false
	)

func _sweep_center() -> Vector2:
	# Keep the arc centered on the player regardless of the equipped slot.
	return weapon.to_local(weapon.get_parent().global_position)

func reset_attack() -> void:
	super.reset_attack()
	hitbox.disable()

func _set_sweep_angle(angle: float, radius: float) -> void:
	weapon.sprite_2d.position = _sweep_center() + Vector2.from_angle(angle) * radius
	weapon.sprite_2d.rotation = angle
