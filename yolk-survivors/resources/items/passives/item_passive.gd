extends ItemBase
class_name ItemPassive

const STAT_SLOT_COUNT := 7

@export_group("Stat 1")
@export var add_value: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id: String = "none"
@export_group("Stat 2")
@export var add_value_2: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_2: String = "none"
@export_group("Stat 3")
@export var add_value_3: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_3: String = "none"
@export_group("Stat 4")
@export var add_value_4: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_4: String = "none"
@export_group("Stat 5")
@export var add_value_5: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_5: String = "none"
@export_group("Stat 6")
@export var add_value_6: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_6: String = "none"
@export_group("Stat 7")
@export var add_value_7: float = 0.0
@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_7: String = "none"
@export_group("On hit")
@export var on_hit_effects: Array[StatusEffect] = []

func get_stat_changes() -> Array[Dictionary]:
	var changes: Array[Dictionary] = []
	for index in range(1, STAT_SLOT_COUNT + 1):
		var suffix := "" if index == 1 else "_%d" % index
		var stat_id: String = get("add_stats_id" + suffix)
		var value: float = get("add_value" + suffix)
		if value != 0.0 and CharacterPassive.STAT_LABELS.has(stat_id):
			changes.append({"stat_id": stat_id, "value": value})
	return changes

func get_description() -> String:
	var lines: PackedStringArray = []
	for change in get_stat_changes():
		var positive: bool = change.value > 0.0
		lines.append("[color=%s]%s%s %s[/color]" % ["green" if positive else "red", "+" if positive else "-", _format_value(absf(change.value), change.stat_id), _stat_label(change.stat_id)])
	var description := "[code]" + "\n".join(lines) + "[/code]"
	for effect in on_hit_effects:
		description += "\nOn hit: %s" % ("Fire" if effect.kind == StatusEffect.Kind.FIRE else "Electricity")
	return description

func apply_stat_values() -> void:
	for change in get_stat_changes():
		Global.player.stats.apply_stat_change(change.stat_id, change.value)

func apply_passive_values() -> void:
	Global.player.stats.attack_effects.append_array(on_hit_effects)
	apply_stat_values()

func _format_value(value: float, stat_id: String) -> String:
	return ItemWeapon.format_number(value) + ("%" if stat_id in ["damage_percent", "attack_speed", "life_steal", "block_chance", "critical_chance", "pickup_range", "area_of_effect", "critical_multiplier", "block_effectiveness", "chili_power", "explosive_damage", "fire_tick_speed", "crowd_control", "experience_gain", "slow_strength"] else "")

func _stat_label(stat_id: String) -> String:
	return {"damage_percent": "Damage", "melee_damage": "Melee damage", "ranged_damage": "Ranged damage", "attack_speed": "Attack speed"}.get(stat_id, stat_id.replace("_", " "))
