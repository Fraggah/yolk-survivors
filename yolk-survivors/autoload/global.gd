extends Node

@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_create_block_text(unit: Node2D)
@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_create_damage_text(unit: Node2D, info: HitboxComponent)
@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_create_heal_text(unit: Node2D, value: float)

@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_upgrade_selected
@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_level_selected(level: int)
@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_enemy_died(enemy: Enemy)
@warning_ignore("unused_signal") # Emitted by other nodes through Global.
signal on_player_died

const GAME_ENTITY_SCALE := 1.5
const STARTING_COINS := 0

const FLASH_MATERIAL = preload("res://effects/flash_material.tres")
const FLOATING_TEXT_SCENE = preload("res://scenes/ui/floating_text/floating_text.tscn")

const COMMON_STYLE = preload("res://styles/common_style.tres")
const EPIC_STYLE = preload("res://styles/epic_style.tres")
const LEGENDARY_STYLE = preload("res://styles/legendary_style.tres")
const RARE_STYLE = preload("res://styles/rare_style.tres")

const COINS_SCENE = preload("res://scenes/coins/coins.tscn")
const ITEM_CARD_SCENE = preload("res://scenes/ui/shop/item_card.tscn")
const SPAWN_EFFECT_SCENE = preload("res://scenes/effects/spawn_effect.tscn")
const FRIED_SCENE = preload("res://scenes/units/fried.tscn")

const UPGRADE_PROBABILITY_CONFIG = {
	"rare" : { "start_wave": 2, "base_mult": .06 },
	"epic" : { "start_wave": 4, "base_mult": .02 },
	"legendary" : { "start_wave": 7, "base_mult": .0023 },
}

const SHOP_PROBABILITY_CONFIG = {
	"rare" : { "start_wave": 2, "base_mult": .1 },
	"epic" : { "start_wave": 4, "base_mult": .05 },
	"legendary" : { "start_wave": 7, "base_mult": .005 },
}

const TIER_COLORS: Dictionary[UpgradeTier, Color] = {
	UpgradeTier.RARE: Color(.4, .857, .41),
	UpgradeTier.EPIC: Color(.478, .251, .71),
	UpgradeTier.LEGENDARY: Color(.906, .212, .212)
}

enum UpgradeTier {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var available_players: Dictionary[String, PackedScene] = {
	"Well Rounded": preload("res://scenes/units/players/player_well_rounded.tscn"),
	"Tiny Egg": preload("res://scenes/units/players/player_tiny_egg.tscn"),
	"Hardboiled": preload("res://scenes/units/players/player_hardboiled.tscn"),
	"Mutant": preload("res://scenes/units/players/player_mutant.tscn"),
	"Vampire": preload("res://scenes/units/players/player_vampire.tscn"),
	"Gambler": preload("res://scenes/units/players/player_gambler.tscn"),
	"Scrapper": preload("res://scenes/units/players/player_scrapper.tscn"),
	"Glass Egg": preload("res://scenes/units/players/player_glass_egg.tscn"),
	"Hoarder": preload("res://scenes/units/players/player_hoarder.tscn"),
	"Berserker": preload("res://scenes/units/players/player_berserker.tscn"),
}

var coins: int = STARTING_COINS
# Unspent pickups from the previous wave, redeemed only by real pickups.
var yolk_reserve: int = 0
var player: Player
var game_paused: bool

var main_player_selected: UnitStats
var main_weapon_selected: ItemWeapon

var selected_weapon: ItemWeapon
var equipped_weapons: Array[ItemWeapon]

var level_reached := 0
var level_selected := 0

func collect_yolk(base_value: int) -> int:
	var base := maxi(0, base_value)
	var bonus := mini(base, yolk_reserve)
	yolk_reserve -= bonus
	coins += base + bonus
	return bonus

func get_harvesting_coins() -> void:
	if is_instance_valid(player):
		coins += int(player.stats.harvesting)
	

func get_selected_player() -> Player:
	var player_path: PackedScene = available_players[main_player_selected.name]
	var player_instance := player_path.instantiate() as Player
	# Keep roster resources immutable; upgrades affect only this run's copy.
	player_instance.stats = main_player_selected.duplicate() as UnitStats
	player = player_instance
	return player


func get_chance_succes(chance: float) -> bool:
	var random = randf_range(0, 1)
	if random < chance:
		return true
	return false

func get_tier_style(tier: UpgradeTier) -> StyleBoxFlat:
	match tier:
		UpgradeTier.COMMON:
			return COMMON_STYLE
		UpgradeTier.RARE:
			return RARE_STYLE
		UpgradeTier.EPIC:
			return EPIC_STYLE
		_:
			return LEGENDARY_STYLE

func calculate_tier_probability(current_wave: int, config: Dictionary) -> Array[float]:
	var common_chance := .0
	var rare_chance := .0
	var epic_chance := .0
	var legendary_chance := .0
	
	# RARE
	if current_wave >= config.rare.start_wave:
		rare_chance = clampf((current_wave - 1) * config.rare.base_mult, 0.0, 1.0)
	# EPIC
	if current_wave >= config.epic.start_wave:
		epic_chance = clampf((current_wave - 3) * config.epic.base_mult, 0.0, 1.0)
	# LEGENDARY
	if current_wave >= config.legendary.start_wave:
		legendary_chance = clampf((current_wave - 6) * config.legendary.base_mult, 0.0, 1.0)
	
	# LUCK
	# Player -> Luck 10 -> 10% chance -> 1.1 Mult
	var luck_factor := 1.0 + (Global.player.stats.luck / 100)
	rare_chance *= luck_factor
	epic_chance *= luck_factor
	legendary_chance *= luck_factor
	
	# Normalize probabilities
	var total_non_common_chance := rare_chance + epic_chance + legendary_chance
	if total_non_common_chance > 1.0:
		var scale_down := 1.0 / total_non_common_chance
		rare_chance *= scale_down
		epic_chance *= scale_down
		legendary_chance *= scale_down
		total_non_common_chance = 1.0
	
	common_chance = 1.0 - total_non_common_chance
	
	print("Wave: %d, Luck: %.1f => Chances C:%.2f R:%.2f E:%.2f L:%.2f" %
	[current_wave, Global.player.stats.luck, common_chance, rare_chance, epic_chance, legendary_chance])
	
	return [
		max(.0, common_chance),
		max(.0, rare_chance),
		max(.0, epic_chance),
		max(.0, legendary_chance)
	]

func select_items_for_offer(item_pool: Array, current_wave: int, config: Dictionary, offer_count: int = 4, excluded_keys: Array = []) -> Array:
	var chances: Array[float] = calculate_tier_probability(current_wave, config)
	var remaining := item_pool.filter(func(item: ItemBase):
		return item != null and not excluded_keys.has(item.get_offer_key()))
	var offers: Array = []
	while offers.size() < offer_count and not remaining.is_empty():
		var roll := randf()
		var tier := 0
		if roll < chances[3]: tier = 3
		elif roll < chances[3] + chances[2]: tier = 2
		elif roll < chances[3] + chances[2] + chances[1]: tier = 1
		var candidates: Array = []
		while candidates.is_empty() and tier >= 0:
			candidates = remaining.filter(func(item: ItemBase): return item.item_tier == tier)
			tier -= 1
		if candidates.is_empty():
			candidates = remaining.filter(func(item: ItemBase): return chances[item.item_tier] > 0.0)
		if candidates.is_empty(): break
		var chosen: ItemBase = candidates.pick_random()
		offers.append(chosen)
		remaining = remaining.filter(func(item: ItemBase): return item.get_offer_key() != chosen.get_offer_key())
	return offers
