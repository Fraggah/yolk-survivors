extends ItemBase
class_name ItemPassive

@export var add_value: float
@export var add_stats_id: String
@export var remove_value: float
@export var remove_stats_id: String
@export var on_hit_effects: Array[StatusEffect] = []

func get_description() -> String:
	var description := "[code]"
	
	if add_value != 0:
		description += "[color=green]+%s %s[/color]\n" %[_format_value(add_value, add_stats_id), _stat_label(add_stats_id)]
	
	if remove_value != 0:
		description += "[color=red]-%s %s[/color]" %[_format_value(remove_value, remove_stats_id), _stat_label(remove_stats_id)]
	
	description += "[/code]"
	for effect in on_hit_effects:
		description += "\nOn hit: %s" % ("Fire" if effect.kind == StatusEffect.Kind.FIRE else "Electricity")
	
	return description

func apply_passive_values() -> void:
	Global.player.stats.attack_effects.append_array(on_hit_effects)
	if add_value != 0:
		Global.player.stats.apply_stat_change(add_stats_id, add_value)
	if remove_value != 0:
		Global.player.stats.apply_stat_change(remove_stats_id, -remove_value)

func _format_value(value: float, stat_id: String) -> String:
	return ItemWeapon.format_number(value) + ("%" if stat_id in ["damage_percent", "attack_speed", "life_steal", "block_chance", "critical_chance", "pickup_range", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "fire_tick_speed"] else "")

func _stat_label(stat_id: String) -> String:
	return {"damage_percent": "Damage", "melee_damage": "Melee damage", "ranged_damage": "Ranged damage", "attack_speed": "Attack speed"}.get(stat_id, stat_id.replace("_", " "))
