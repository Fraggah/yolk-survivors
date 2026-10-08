extends ItemBase
class_name ItemPassive

@export var add_value: float
@export var add_stats_id: String
@export var remove_value: float
@export var remove_stats_id: String

func get_description() -> String:
	var description := "[code]"
	
	if add_value != 0:
		description += "[color=green]+%s %s[/color]\n" %[_format_value(add_value, add_stats_id), _stat_label(add_stats_id)]
	
	if remove_value != 0:
		description += "[color=red]-%s %s[/color]" %[_format_value(remove_value, remove_stats_id), _stat_label(remove_stats_id)]
	
	description += "[/code]"
	
	return description

func apply_passive_values() -> void:
	if add_value != 0:
		Global.player.stats[add_stats_id] += add_value
	if remove_value != 0:
		Global.player.stats[remove_stats_id] -= remove_value

func _format_value(value: float, stat_id: String) -> String:
	return ItemWeapon.format_number(value) + ("%" if stat_id in ["damage_percent", "attack_speed", "life_steal", "block_chance"] else "")

func _stat_label(stat_id: String) -> String:
	return {"damage_percent": "Damage", "melee_damage": "Melee damage", "ranged_damage": "Ranged damage", "attack_speed": "Attack speed"}.get(stat_id, stat_id.replace("_", " "))
