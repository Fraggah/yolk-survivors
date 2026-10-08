extends Resource
class_name ItemBase

const ECONOMY_RULES = preload("res://resources/economy_rules.gd")

enum ItemType {
	WEAPON,
	UPGRADE,
	PASSIVE
}

@export var item_name: String
@export var item_icon: Texture2D
@export var item_tier: Global.UpgradeTier
@export var item_type: ItemType
@export var item_cost: int

func get_shop_price(completed_wave: int) -> int:
	return ECONOMY_RULES.shop_price(item_cost, completed_wave)

func get_sell_price(completed_wave: int) -> int:
	return ECONOMY_RULES.sell_price(item_cost, completed_wave)

func get_description() -> String:
	return ""

func get_offer_key() -> String:
	return "%s:%s" % [item_type, item_name]
