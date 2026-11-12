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
@export var base_movement_speed := 300.0
@export var luck := 1.0
@export var initial_luck := 1.0
@export var block_chance := 0.0
@export var initial_block_chance := 0.0
@export var experience_gain := 0.0
@export var experience_reward := 1
@export var coin_drop := 1
## Each positive point restores 0.1 HP per second in small pulses.
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
## Flat Effects damage, multiplied by each attack scaling coefficient.
@export var effects := 0.0
@export var chili_power := 0.0
@export var explosive_damage := 0.0
## Item-only percentage bonus to crowd-control strength.
@export var crowd_control := 0.0
## Item-only potency bonus affecting Slow intensity, not other control states.
@export var slow_strength := 0.0
## Flat bonus to ordinary weapon push, separate from crowd control.
@export var knockback := 0.0
## Item-only percentage bonus to fire tick frequency.
@export var fire_tick_speed := 0.0
## Flat seconds removed by items, separate from percentage tick frequency.
@export var fire_interval_reduction := 0.0
@export var fire_duration_reduction := 0.0
@export var attack_effects: Array[Resource] = []
## Percentage modifier of a collectible's base attraction distance.
@export var weapon_range := 0.0
@export var pickup_range := 0.0
@export var harvesting := .0

func reset_player_stats() -> void:
	_temporary_stat_bonuses.clear()
	conditional_push_multiplier = 1.0
	chili_crit_enabled = false
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
	chili_power = 0
	explosive_damage = 0
	crowd_control = 0
	slow_strength = 0
	knockback = 0
	fire_tick_speed = 0
	fire_interval_reduction = 0
	fire_duration_reduction = 0
	attack_effects = []
	experience_gain = 0
	weapon_range = 0
	pickup_range = 0
	harvesting = 0
	piercing = 0
	bounces = 0

# Per-run bookkeeping. Character resources themselves are never initialized/mutated.
var energy_shakes := 0.0
var infernal_reduction_multiplier := 1.0
var infernal_reduction := false
## Runtime conditional effect; multiplies base weapon push plus flat item gains.
var conditional_push_multiplier := 1.0
## Run-local unlock granted by Pimienta, separate from critical chance.
var chili_crit_enabled := false
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

func get_crowd_control_multiplier() -> float:
	return maxf(0.0, 1.0 + crowd_control / 100.0)

func get_push_multiplier() -> float:
	return final_multiplier("knockback") * conditional_push_multiplier

func get_push_force(base_force: float) -> float:
	return maxf(0.0, base_force + unmodified_stat("knockback")) * get_push_multiplier()

func effective_slow(factor: float) -> float:
	return 1.0 - clampf((1.0 - factor) * maxf(0.0, 1.0 + unmodified_stat("slow_strength") / 100.0) * final_multiplier("slow_strength") * get_crowd_control_multiplier(), 0.0, 1.0)

var _passives_initialized := false
var _base_stat_values: Dictionary = {}
var _stat_gains: Dictionary = {}
var _temporary_stat_bonuses: Dictionary = {}

func set_temporary_stat_bonus(source_key: String, stat_id: String, amount: float) -> void:
	if not CharacterPassive.STAT_LABELS.has(stat_id): return
	var previous: Dictionary = _temporary_stat_bonuses.get(source_key, {})
	if previous.get("stat", "") == stat_id and is_equal_approx(float(previous.get("amount", 0.0)), amount): return
	if previous.is_empty() and is_zero_approx(amount): return
	initialize_character_passives()
	if is_zero_approx(amount): _temporary_stat_bonuses.erase(source_key)
	else: _temporary_stat_bonuses[source_key] = {"stat":stat_id, "amount":amount}
	_recalculate_character_stats()
	stats_changed.emit()

func initialize_character_passives() -> void:
	if _passives_initialized: return
	for stat_id in CharacterPassive.STAT_LABELS:
		_base_stat_values[stat_id] = float(get(stat_id))
		_stat_gains[stat_id] = 0.0
	_passives_initialized = true
	_recalculate_character_stats()

func get_passive_preview() -> UnitStats:
	var preview := duplicate() as UnitStats
	preview.character_passives = character_passives.duplicate()
	preview.energy_shakes = energy_shakes
	preview.infernal_reduction_multiplier = infernal_reduction_multiplier
	preview.infernal_reduction = infernal_reduction
	if _passives_initialized:
		preview._passives_initialized = true
		preview._base_stat_values = _base_stat_values.duplicate()
		preview._stat_gains = _stat_gains.duplicate()
		preview._temporary_stat_bonuses = _temporary_stat_bonuses.duplicate(true)
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
		for bonus in _temporary_stat_bonuses.values():
			if bonus.stat == stat_id: source_values[stat_id] += bonus.amount
		set(stat_id, source_values[stat_id])
	# All conversions read the same snapshot, so order and circular definitions
	# cannot recursively create stats or accumulate the same bonus twice.
	for passive in character_passives:
		if not passive or not passive.is_valid() or passive.effect != CharacterPassive.Effect.STAT_CONVERSION: continue
		var bonus := float(source_values[passive.source_stat]) / passive.source_amount * passive.bonus_amount
		if bonus > 0.0: bonus *= get_stat_gain_multiplier(passive.target_stat)
		set(passive.target_stat, float(get(passive.target_stat)) + bonus)

	if energy_shakes > 0:
		var speed_bonus := ((1.0 + speed / 100.0) * final_multiplier("speed") - 1.0) * 100.0
		attack_speed += maxf(0.0, speed_bonus) * 2.0 * energy_shakes
	if infernal_reduction:
		effects += (melee_damage + ranged_damage) * infernal_reduction_multiplier
		melee_damage = 0.0
		ranged_damage = 0.0
	_apply_final_modifiers()

func _apply_final_modifiers() -> void:
	_before_final.clear()
	for stat_id in final_stat_modifiers:
		if not CharacterPassive.STAT_LABELS.has(stat_id): continue
		var original := float(get(stat_id))
		_before_final[stat_id] = original
		var factor := final_multiplier(stat_id)
		if stat_id in ["speed", "area_of_effect", "critical_multiplier", "fire_tick_speed", "crowd_control", "slow_strength"]:
			set(stat_id, ((1.0 + original / 100.0) * factor - 1.0) * 100.0)
		elif stat_id == "attack_speed":
			var rate := (1.0 + original / 100.0 if original >= 0.0 else 1.0 / (1.0 + absf(original) / 100.0)) * factor
			set(stat_id, (rate - 1.0) * 100.0 if rate >= 1.0 else -(1.0 / maxf(0.0001, rate) - 1.0) * 100.0)
		else:
			set(stat_id, original * factor)

func get_player_movement_speed() -> float:
	return base_movement_speed * maxf(0.0, 1.0 + speed / 100.0)

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

func get_block_chance() -> float:
	return clampf(block_chance, 0.0, 70.0)

func get_pickup_distance(base_distance: float) -> float:
	return maxf(1.0, base_distance * (1.0 + pickup_range / 100.0))

func get_area_radius_multiplier() -> float:
	return sqrt(maxf(0.0, 1.0 + area_of_effect / 100.0))

func get_effect_damage(base_damage: float, coefficient: float = 1.0) -> float:
	return maxf(0.0, base_damage + effects * coefficient)

func get_damage_percent_multiplier(chili: bool = false, explosive: bool = false) -> float:
	var percent := damage_percent
	if chili: percent += chili_power
	if explosive: percent += explosive_damage
	return maxf(0.0, 1.0 + percent / 100.0)

const BURNING_EFFECTS_SCALING := 0.25

func get_burning_damage() -> float:
	return maxf(0.1, effects * BURNING_EFFECTS_SCALING)

func get_fire_interval(_base_interval: float = 0.5) -> float:
	return maxf(0.05, maxf(0.05, StatusEffect.BASE_FIRE_INTERVAL - fire_interval_reduction) / maxf(0.05, 1.0 + fire_tick_speed / 100.0))

func get_fire_duration(base_duration: float) -> float:
	return maxf(0.0, base_duration * effect_duration_multiplier() - fire_duration_reduction)

func adjust_owned_item_gains(deltas: Dictionary) -> void:
	# Deltas already include character gain bonuses. Removing them must be exact.
	initialize_character_passives()
	for stat_id in deltas:
		if _stat_gains.has(stat_id): _stat_gains[stat_id] += float(deltas[stat_id])
	_recalculate_character_stats()
	stats_changed.emit()

func primary_display_value(stat_id: String) -> float:
	return get_block_chance() if stat_id == "block_chance" else float(get(stat_id))

func halve_primary_stat(stat_id: String) -> bool:
	if not stat_id in load("res://scenes/ui/stats/stats_container.gd").PRIMARY: return false
	var original := primary_display_value(stat_id)
	if original <= 0.0: return false
	var target := original * 0.5
	# Solve the one-time loss through conversions/final modifiers, including
	# capped block chance and nonlinear attack speed, without halving future gains.
	var preview := get_passive_preview()
	var initial: float = preview._stat_gains[stat_id]
	var low := 0.0
	var high := maxf(1.0, absf(float(get(stat_id))))
	for index in 40:
		preview._stat_gains[stat_id] = initial - high
		preview._recalculate_character_stats()
		if preview.primary_display_value(stat_id) <= target: break
		high *= 2.0
	if preview.primary_display_value(stat_id) > target: return false
	for index in 40:
		var middle := (low + high) * 0.5
		preview._stat_gains[stat_id] = initial - middle
		preview._recalculate_character_stats()
		if preview.primary_display_value(stat_id) > target: low = middle
		else: high = middle
	adjust_owned_item_gains({stat_id: -(low + high) * 0.5})
	return true
