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
## Menu-only multiplier. 1 = current size; does not change the in-game sprite.
@export_range(0.25, 2.0, 0.05) var icon_scale := 1.0
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

static func scale_icon(target: TextureRect, factor: float) -> void:
	target.set_meta("item_icon_scale", clampf(factor, 0.25, 2.0))
	var callback := _refresh_icon_scale.bind(target)
	if not target.resized.is_connected(callback): target.resized.connect(callback)
	_refresh_icon_scale(target)
	# Containers may reset Control scale during initial layout.
	_refresh_icon_scale.call_deferred(target)

static func _refresh_icon_scale(target) -> void:
	if not is_instance_valid(target): return
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2.ONE * float(target.get_meta("item_icon_scale", 1.0))
