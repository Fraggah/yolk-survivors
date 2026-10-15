extends Weapon

# Spicy attacks are autonomous; nearby enemies never gate or aim them.
func can_use_weapon() -> bool:
	return data != null and cooldown_timer.is_stopped() and not is_attacking

func update_closest_target() -> void:
	closest_target = null

func rotate_to_target() -> void:
	rotation = 0.0

func calculate_spread() -> void:
	weapon_spread = 0.0

func update_visuals() -> void:
	sprite_2d.scale = sprite_base_scale
