extends Weapon

# Spicy attacks are autonomous; nearby enemies never gate or aim them.
func can_use_weapon() -> bool:
	if data == null or not cooldown_timer.is_stopped() or is_attacking: return false
	return weapon_behaviour.can_execute_attack() if weapon_behaviour.has_method("can_execute_attack") else true

func update_closest_target() -> void:
	closest_target = null

func rotate_to_target() -> void:
	rotation = 0.0

func calculate_spread() -> void:
	weapon_spread = 0.0

func update_visuals() -> void:
	sprite_2d.scale = sprite_base_scale
