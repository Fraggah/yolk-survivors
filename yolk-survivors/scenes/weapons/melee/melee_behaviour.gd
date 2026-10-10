extends WeaponBehaviour
class_name MeleBehaviour

@export var hitbox: HitboxComponent
enum AttackMotion { THRUST, SEMICIRCLE }
@export var attack_motion: AttackMotion = AttackMotion.THRUST

func _ready() -> void:
	lock_aim_during_attack = attack_motion == AttackMotion.SEMICIRCLE
	hitbox.hit_once_per_activation = lock_aim_during_attack

func execute_attack() -> void:
	if attack_motion == AttackMotion.SEMICIRCLE:
		_execute_semicircle()
		return
	weapon.is_attacking = true
	
	var tween := create_attack_tween()
	var stats := weapon.data.stats
	var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration)
	var recoild_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)
	tween.tween_property(weapon.sprite_2d, "position", recoild_pos, weapon.data.stats.recoil_duration * time_scale)
	
	tween.tween_callback(func():
		hitbox.enable()
		hitbox.setup(get_damage(), critical, weapon.data.stats.knockback, weapon.get_parent())
		hitbox.life_steal_chance = get_life_steal_chance()
	)
	
	var attack_pos := Vector2(weapon.atk_start_pos.x + weapon.data.stats.max_range, weapon.atk_start_pos.y)
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
	var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration)
	var tween := create_attack_tween()
	var start_position := weapon.atk_start_pos
	var radius := stats.max_range * 0.75
	var arc_start := _sweep_center() + Vector2(0, -radius)
	tween.tween_property(weapon.sprite_2d, "position", arc_start, stats.recoil_duration * time_scale)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", -PI / 2.0, stats.recoil_duration * time_scale)
	tween.tween_callback(func():
		hitbox.setup(get_damage(), critical, stats.knockback, weapon.get_parent())
		hitbox.life_steal_chance = get_life_steal_chance()
		hitbox.enable()
	)
	tween.tween_method(_set_sweep_angle.bind(radius), -PI / 2.0, PI / 2.0, stats.attack_duration * time_scale)
	tween.tween_callback(hitbox.disable)
	tween.tween_property(weapon.sprite_2d, "position", start_position, stats.back_duration * time_scale)
	tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, stats.back_duration * time_scale)
	tween.finished.connect(func():
		weapon.is_attacking = false
		critical = false
	)

func _sweep_center() -> Vector2:
	# Keep the arc centered on the player regardless of the equipped slot.
	return weapon.to_local(Global.player.global_position)

func reset_attack() -> void:
	super.reset_attack()
	hitbox.disable()

func _set_sweep_angle(angle: float, radius: float) -> void:
	weapon.sprite_2d.position = _sweep_center() + Vector2.from_angle(angle) * radius
	weapon.sprite_2d.rotation = angle
