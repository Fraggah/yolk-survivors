extends Panel
class_name ShopCard

signal on_item_purchased(item: ItemBase)
var purchase_handler: Callable
var shop_wave := 1
var locked := false
var lock_button: Button
var purchase_in_progress := false

@export var shop_item: ItemBase: set = _set_shop_item

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_type: Label = %ItemType
@onready var item_description: RichTextLabel = %ItemDescription
@onready var item_cost: Label = %ItemCost

func _ready() -> void:
	UITheme.palette_changed.connect(_refresh_palette)
	lock_button = Button.new()
	lock_button.name = "LockButton"
	lock_button.toggle_mode = true
	lock_button.text = "LOCK"
	lock_button.add_theme_font_size_override("font_size", 24)
	var actions := VBoxContainer.new()
	actions.name = "Actions"
	$MarginContainer/Control.add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -122.0
	actions.add_theme_constant_override("separation", 8)
	var buy_button: Button = $MarginContainer/Control/CustomButton
	buy_button.reparent(actions)
	buy_button.custom_minimum_size = Vector2(0, 70)
	buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(lock_button)
	lock_button.custom_minimum_size = Vector2(0, 44)
	lock_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	lock_button.tooltip_text = "Keep this offer and its price through refreshes and waves."
	lock_button.toggled.connect(_on_lock_toggled)


func _on_lock_toggled(value: bool) -> void:
	locked = value
	lock_button.text = "LOCKED" if locked else "LOCK"
	UITheme.style_offer_lock(lock_button, locked)
	SoundManager.play_sound(SoundManager.Sound.SHOP_LOCK if value else SoundManager.Sound.SHOP_UNLOCK)

func set_locked(value: bool) -> void:
	locked = value
	lock_button.set_pressed_no_signal(value)
	lock_button.text = "LOCKED" if value else "LOCK"
	UITheme.style_offer_lock(lock_button, value)

func _refresh_palette() -> void:
	if shop_item: _set_shop_item(shop_item)

func _set_shop_item(value: ItemBase) -> void:
	shop_item = value
	item_icon.texture = shop_item.item_icon
	item_name.text = shop_item.item_name
	item_name.add_theme_font_size_override("font_size", 16 if shop_item.item_name.length() >= 20 else 20)
	item_type.text = ItemBase.ItemType.keys()[shop_item.item_type]
	if shop_item is ItemWeapon:
		item_description.text = UITheme.rich_text((shop_item as ItemWeapon).get_description(Global.player.stats if is_instance_valid(Global.player) else null))
	else:
		item_description.text = UITheme.rich_text(shop_item.get_description())
	item_cost.text = str(shop_item.get_shop_price(shop_wave))
	
	var style := Global.get_tier_style(shop_item.item_tier)
	set_meta("ui_tier", int(shop_item.item_tier))
	add_theme_stylebox_override("panel", style)
	load("res://scenes/ui/rarity_marker.gd").apply(self, int(shop_item.item_tier))


func _on_custom_button_pressed() -> void:
	if purchase_in_progress: return
	purchase_in_progress = true
	if purchase_handler.is_valid() and purchase_handler.call(shop_item):
		on_item_purchased.emit(shop_item)
	purchase_in_progress = false
