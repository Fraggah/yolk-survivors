extends Weapon

func _process(delta: float) -> void:
	center_range_on_weapon()
	if Global.game_paused or data == null: return
	update_closest_target()
	rotate_to_target()
	update_visuals()
	weapon_behaviour.update_stream(delta, is_instance_valid(closest_target))
