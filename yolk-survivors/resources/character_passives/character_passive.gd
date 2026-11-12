extends Resource
class_name CharacterPassive

enum Effect { STAT_CONVERSION, STAT_GAIN_BONUS, FORBID_MELEE, FORBID_RANGED }

const STAT_LABELS := {
	"health": "Health", "damage_percent": "Damage %", "melee_damage": "Melee damage",
	"ranged_damage": "Ranged damage", "attack_speed": "Attack speed %", "speed": "Speed",
	"luck": "Luck", "block_chance": "Block chance %", "hp_regen": "HP regen",
	"life_steal": "Life Steal", "harvesting": "Harvesting",
	"armor": "Armor", "critical_chance": "Critical chance %", "pickup_range": "Pickup range %",
	"piercing": "Piercing", "bounces": "Bounces", "area_of_effect": "Area of effect %", "critical_multiplier": "Critical multiplier %", "block_effectiveness": "Block Power %", "effects": "Effects", "chili_power": "Chili Power %", "explosive_damage": "Explosive damage %", "fire_tick_speed": "Fire tick speed %", "experience_gain": "Experience gain %", "slow_strength": "Slow potency %", "weapon_range": "Range", "knockback": "Push", "crowd_control": "Crowd control %"
}

## Optional player-facing explanation. Leave blank to show the generated description.
@export_multiline var display_description := ""
@export var effect: Effect = Effect.STAT_CONVERSION
@export_enum("chili_power", "explosive_damage", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "fire_tick_speed", "crowd_control", "experience_gain", "knockback", "weapon_range", "slow_strength") var target_stat: String = "melee_damage"
@export_enum("chili_power", "explosive_damage", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "fire_tick_speed", "crowd_control", "experience_gain", "knockback", "weapon_range", "slow_strength") var source_stat: String = "speed"
@export var source_amount := 1.0
@export var bonus_amount := 1.0
@export var gain_bonus_percent := 25.0

func is_valid() -> bool:
	if effect == Effect.STAT_GAIN_BONUS: return STAT_LABELS.has(target_stat)
	if effect == Effect.STAT_CONVERSION:
		return STAT_LABELS.has(target_stat) and STAT_LABELS.has(source_stat) and source_amount > 0.0
	return true

func get_description() -> String:
	var custom_description := display_description.strip_edges()
	if not custom_description.is_empty():
		return custom_description
	match effect:
		Effect.STAT_CONVERSION:
			return "%s%s per %s" % [
				"+" if bonus_amount >= 0.0 else "-",
				_format_conversion_stat(target_stat, absf(bonus_amount)),
				_format_conversion_stat(source_stat, source_amount),
			]
		Effect.STAT_GAIN_BONUS:
			var stat_name := str(STAT_LABELS.get(target_stat, target_stat)).trim_suffix(" %").capitalize()
			return "%s bonuses are %s%% stronger." % [stat_name, ItemWeapon.format_number(gain_bonus_percent)]
		Effect.FORBID_MELEE: return "Cannot use melee weapons"
		Effect.FORBID_RANGED: return "Cannot use ranged weapons"
	return ""

static func _format_conversion_stat(stat_id: String, amount: float) -> String:
	var label := str(STAT_LABELS.get(stat_id, stat_id))
	var percent := "%" if label.ends_with(" %") else ""
	return "%s%s %s" % [percent, ItemWeapon.format_number(amount), label.trim_suffix(" %").capitalize()]
