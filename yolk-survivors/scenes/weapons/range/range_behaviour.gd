extends WeaponBehaviour
class_name RangeBehaviour

@onready var muzzle: Marker2D = %Muzzle

func execute_attack() -> void:
	weapon.is_attacking = true
	
	create_projectile()
	SoundManager.play_sound(SoundManager.Sound.FIRE)
	
	var tween := create_tween()
	var time_scale := weapon.get_animation_time_scale(weapon.data.stats.recoil_duration * 2.0)
	var attack_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)
	tween.tween_property(weapon.sprite_2d, "position", attack_pos, weapon.data.stats.recoil_duration * time_scale)
	tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, weapon.data.stats.recoil_duration * time_scale)
	
	
	await tween.finished
	weapon.is_attacking = false
	critical = false

func create_projectile() -> void:
	var instance := weapon.data.stats.projectile_scene.instantiate() as Projectile
	get_tree().root.add_child(instance)
	instance.global_position = muzzle.global_position
	
	var velocity := Vector2.RIGHT.rotated(weapon.rotation) * weapon.data.stats.projectile_speed
	# Match the detection circle's world-space radius, including the entity scale.
	var travel_range := weapon.data.stats.max_range * absf(weapon.collision.global_scale.x)
	instance.setup_projectile(velocity, get_damage(), critical, weapon.data.stats.knockback, weapon.get_parent(), travel_range)
	instance.hitbox.life_steal_chance = get_life_steal_chance()
