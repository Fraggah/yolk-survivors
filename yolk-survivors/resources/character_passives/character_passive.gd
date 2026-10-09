extends Resource
class_name CharacterPassive

enum Effect { STAT_CONVERSION, STAT_GAIN_BONUS, FORBID_MELEE, FORBID_RANGED }

const STAT_LABELS := {
	"health": "Health", "damage_percent": "Damage %", "melee_damage": "Melee damage",
	"ranged_damage": "Ranged damage", "attack_speed": "Attack speed %", "speed": "Speed",
	"luck": "Luck", "block_chance": "Block chance %", "hp_regen": "HP regen",
	"life_steal": "Life steal %", "harvesting": "Harvesting"
}

@export var effect: Effect = Effect.STAT_CONVERSION
@export_enum("health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting") var target_stat: String = "melee_damage"
@export_enum("health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting") var source_stat: String = "speed"
@export var source_amount := 1.0
@export var bonus_amount := 1.0
@export var gain_bonus_percent := 25.0

func is_valid() -> bool:
	if effect == Effect.STAT_GAIN_BONUS: return STAT_LABELS.has(target_stat)
	if effect == Effect.STAT_CONVERSION:
		return STAT_LABELS.has(target_stat) and STAT_LABELS.has(source_stat) and source_amount > 0.0
	return true

func get_description() -> String:
	match effect:
		Effect.STAT_CONVERSION:
			return "+%s %s per %s %s" % [ItemWeapon.format_number(bonus_amount), STAT_LABELS.get(target_stat, target_stat), ItemWeapon.format_number(source_amount), STAT_LABELS.get(source_stat, source_stat)]
		Effect.STAT_GAIN_BONUS:
			return "+%s%% %s gains" % [ItemWeapon.format_number(gain_bonus_percent), STAT_LABELS.get(target_stat, target_stat)]
		Effect.FORBID_MELEE: return "Cannot use melee weapons"
		Effect.FORBID_RANGED: return "Cannot use ranged weapons"
	return ""
