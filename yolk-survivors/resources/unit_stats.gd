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
@export var harvesting := .0

func reset_player_stats() -> void:
	health = initial_health
	damage = initial_damage
	luck = initial_luck
	block_chance = initial_block_chance
	hp_regen = 0
	life_steal = 0
	harvesting = 0

# Per-run bookkeeping. Character resources themselves are never initialized/mutated.
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

func can_use_weapon(weapon: ItemWeapon) -> bool:
	if weapon == null: return false
	for passive in character_passives:
		if passive == null: continue
		if passive.effect == CharacterPassive.Effect.FORBID_MELEE and weapon.type == ItemWeapon.Type.MELEE: return false
		if passive.effect == CharacterPassive.Effect.FORBID_RANGED and weapon.type == ItemWeapon.Type.RANGE: return false
	return true
