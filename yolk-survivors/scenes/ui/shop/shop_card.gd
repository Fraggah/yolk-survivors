extends Panel
class_name ShopCard

signal on_item_purchased(item: ItemBase)
var purchase_handler: Callable
var shop_wave := 1
var purchase_in_progress := false

@export var shop_item: ItemBase: set = _set_shop_item

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_type: Label = %ItemType
@onready var item_description: RichTextLabel = %ItemDescription
@onready var item_cost: Label = %ItemCost

func _set_shop_item(value: ItemBase) -> void:
	shop_item = value
	item_icon.texture = shop_item.item_icon
	item_name.text = shop_item.item_name
	item_type.text = ItemBase.ItemType.keys()[shop_item.item_type]
	if shop_item is ItemWeapon:
		item_description.text = (shop_item as ItemWeapon).get_description(Global.player.stats if is_instance_valid(Global.player) else null)
	else:
		item_description.text = shop_item.get_description()
	item_cost.text = str(shop_item.get_shop_price(shop_wave))
	
	var style := Global.get_tier_style(shop_item.item_tier)
	add_theme_stylebox_override("panel", style)


func _on_custom_button_pressed() -> void:
	if purchase_in_progress: return
	purchase_in_progress = true
	if purchase_handler.is_valid() and purchase_handler.call(shop_item):
		on_item_purchased.emit(shop_item)
	purchase_in_progress = false
