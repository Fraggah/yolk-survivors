extends Resource
class_name UnitStats

enum UnitType {
	Player,
	Enemy
}

signal stats_changed

@export var unlock_id: String
@export var name: String
@export var type: UnitType
@export var icon: Texture2D
# Optional character equipment, independent from the player-selected weapon.
@export var starting_weapon: ItemWeapon
@export var character_passives: Array[CharacterPassive] = []
@export var health := 1.0
@export var initial_health := 1.0
# Per-wave growth is consumed only by the enemy spawner.
@export var health_increase_per_wave := 1.0
# Enemy contact damage remains independent from player weapon bonuses.
@export var damage := 1.0
@export var damage_percent := 0.0
@export var melee_damage := 0.0
@export var ranged_damage := 0.0
@export var attack_speed := 0.0
@export_range(0, 100, 1) var piercing := 0
@export_range(0, 100, 1) var bounces := 0
@export var initial_damage := 1.0
@export var damage_increase_per_wave := 1.0
@export var speed := 300.0
@export var luck := 1.0
@export var initial_luck := 1.0
@export var block_chance := 0.0
@export var initial_block_chance := 0.0
@export var experience_reward := 1
@export var coin_drop := 1
@export var hp_regen := .0
@export var life_steal := .0
@export var armor := 0.0
## Percentage points, added to the weapon's critical probability.
@export var critical_chance := 0.0
## Percentage bonuses; area_of_effect scales actual area, not radius.
@export var area_of_effect := 0.0
@export var critical_multiplier := 0.0
## Percentage of incoming damage PREVENTED on a successful block. Higher is better.
@export_range(0.0, 100.0, 0.1) var block_effectiveness := 50.0
@export var effects := 0.0
## Item-only percentage bonus to fire tick frequency.
@export var fire_tick_speed := 0.0
@export var attack_effects: Array[Resource] = []
## Percentage modifier of a collectible's base attraction distance.
@export var pickup_range := 0.0
@export var harvesting := .0

func reset_player_stats() -> void:
	health = initial_health
	damage = initial_damage
	luck = initial_luck
	block_chance = initial_block_chance
	hp_regen = 0
	life_steal = 0
	armor = 0
	critical_chance = 0
	area_of_effect = 0
	critical_multiplier = 0
	block_effectiveness = 50
	effects = 0
	fire_tick_speed = 0
	attack_effects = []
	pickup_range = 0
	harvesting = 0
	piercing = 0
	bounces = 0

# Per-run bookkeeping. Character resources themselves are never initialized/mutated.
var final_stat_modifiers: Dictionary = {}
var _before_final: Dictionary = {}

func final_multiplier(stat_id: String) -> float:
	return maxf(0.0, 1.0 + float(final_stat_modifiers.get(stat_id, 0.0)) / 100.0)

func unmodified_stat(stat_id: String) -> float:
	return float(_before_final.get(stat_id, get(stat_id))) if final_stat_modifiers.has(stat_id) else float(get(stat_id))

func set_final_modifiers(modifiers: Dictionary) -> void:
	initialize_character_passives()
	final_stat_modifiers = modifiers.duplicate()
	_recalculate_character_stats()
	stats_changed.emit()

func effect_duration_multiplier() -> float:
	return final_multiplier("effect_duration")

func effective_slow(factor: float) -> float:
	return 1.0 - clampf((1.0 - factor) * final_multiplier("slow_strength"), 0.0, 1.0)

var _passives_initialized := false
var _base_stat_values: Dictionary = {}
var _stat_gains: Dictionary = {}

func initialize_character_passives() -> void:
	if _passives_initialized: return
	for stat_id in CharacterPassive.STAT_LABELS:
		_base_stat_values[stat_id] = float(get(stat_id))
		_stat_gains[stat_id] = 0.0
	_passives_initialized = true
	_recalculate_character_stats()

func get_passive_preview() -> UnitStats:
	var preview := duplicate() as UnitStats
	if _passives_initialized:
		preview._passives_initialized = true
		preview._base_stat_values = _base_stat_values.duplicate()
		preview._stat_gains = _stat_gains.duplicate()
		preview.final_stat_modifiers = final_stat_modifiers.duplicate()
		preview._before_final = _before_final.duplicate()
	else:
		preview.initialize_character_passives()
	return preview

func get_stat_gain_multiplier(stat_id: String) -> float:
	var percent := 0.0
	for passive in character_passives:
		if passive and passive.is_valid() and passive.effect == CharacterPassive.Effect.STAT_GAIN_BONUS and passive.target_stat == stat_id:
			percent += passive.gain_bonus_percent
	return maxf(0.0, 1.0 + percent / 100.0)

func apply_stat_change(stat_id: String, amount: float) -> void:
	if not CharacterPassive.STAT_LABELS.has(stat_id): return
	initialize_character_passives()
	# Amplify gains, not penalties or initial base values.
	_stat_gains[stat_id] += amount * get_stat_gain_multiplier(stat_id) if amount > 0.0 else amount
	_recalculate_character_stats()
	stats_changed.emit()

func _recalculate_character_stats() -> void:
	var source_values: Dictionary = {}
	for stat_id in _base_stat_values:
		source_values[stat_id] = _base_stat_values[stat_id] + _stat_gains[stat_id]
		set(stat_id, source_values[stat_id])
	# All conversions read the same snapshot, so order and circular definitions
	# cannot recursively create stats or accumulate the same bonus twice.
	for passive in character_passives:
		if not passive or not passive.is_valid() or passive.effect != CharacterPassive.Effect.STAT_CONVERSION: continue
		var bonus := float(source_values[passive.source_stat]) / passive.source_amount * passive.bonus_amount
		if bonus > 0.0: bonus *= get_stat_gain_multiplier(passive.target_stat)
		set(passive.target_stat, float(get(passive.target_stat)) + bonus)

	_apply_final_modifiers()

func _apply_final_modifiers() -> void:
	_before_final.clear()
	for stat_id in final_stat_modifiers:
		if not CharacterPassive.STAT_LABELS.has(stat_id): continue
		var original := float(get(stat_id))
		_before_final[stat_id] = original
		var factor := final_multiplier(stat_id)
		if stat_id in ["damage_percent", "area_of_effect", "critical_multiplier", "fire_tick_speed"]:
			set(stat_id, ((1.0 + original / 100.0) * factor - 1.0) * 100.0)
		elif stat_id == "attack_speed":
			var rate := (1.0 + original / 100.0 if original >= 0.0 else 1.0 / (1.0 + absf(original) / 100.0)) * factor
			set(stat_id, (rate - 1.0) * 100.0 if rate >= 1.0 else -(1.0 / maxf(0.0001, rate) - 1.0) * 100.0)
		else:
			set(stat_id, original * factor)

func can_use_weapon(weapon: ItemWeapon) -> bool:
	if weapon == null: return false
	if weapon.selection_only: return true
	for passive in character_passives:
		if passive == null: continue
		if passive.effect == CharacterPassive.Effect.FORBID_MELEE and weapon.has_tag(ItemWeapon.Tag.MELEE): return false
		if passive.effect == CharacterPassive.Effect.FORBID_RANGED and weapon.has_tag(ItemWeapon.Tag.RANGED): return false
	return true

func get_incoming_damage_multiplier() -> float:
	# Diminishing returns for protection; negative armor increases damage.
	return 1.0 / (1.0 + armor * 0.06) if armor >= 0.0 else 1.0 + absf(armor) * 0.06

func get_pickup_distance(base_distance: float) -> float:
	return maxf(1.0, base_distance * (1.0 + pickup_range / 100.0))

func get_area_radius_multiplier() -> float:
	return sqrt(maxf(0.0, 1.0 + area_of_effect / 100.0))

func get_effect_multiplier() -> float:
	return maxf(0.0, 1.0 + effects / 100.0)

func get_fire_interval(base_interval: float) -> float:
	return maxf(0.05, base_interval / maxf(0.05, 1.0 + fire_tick_speed / 100.0))
