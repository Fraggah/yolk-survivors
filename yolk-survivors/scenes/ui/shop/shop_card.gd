extends Panel
class_name ShopCard

signal on_item_purchased(item: ItemBase)
@export var text_scale := 1.0
@export var body_text_scale := 1.0
@export var action_buy_height := 70.0
@export var action_lock_height := 44.0
@export var price_icon_size := 40.0
@export var price_text_scale := 1.0
@export var price_icon_right := false
var preview_stats: UnitStats
var purchase_handler: Callable
var shop_wave := 1
var locked := false
var lock_button: Button
var purchase_in_progress := false
var sale_discount_percent := 0
var sale_two_for_one := false
var sale_badge: Control

func has_sale() -> bool:
	return sale_discount_percent > 0 or sale_two_for_one

func get_effective_price() -> int:
	var base := shop_item.get_shop_price(shop_wave)
	return maxi(1, floori(base * (100 - sale_discount_percent) / 100.0))

func set_sale(discount: int = 0, two_for_one: bool = false) -> void:
	sale_two_for_one = two_for_one
	sale_discount_percent = 0 if two_for_one else clampi(discount, 0, 90)
	_refresh_sale()

func _refresh_sale() -> void:
	if not is_node_ready() or shop_item == null: return
	item_cost.text = str(get_effective_price())
	if sale_badge == null and has_sale():
		sale_badge = load("res://scenes/ui/shop/sale_badge.gd").new()
		sale_badge.name = "SaleBadge"
		add_child(sale_badge)
		sale_badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		sale_badge.offset_left = -94
		sale_badge.offset_right = 14
		sale_badge.offset_top = -18
		sale_badge.offset_bottom = 66
		sale_badge.pivot_offset = Vector2(54, 42)
		sale_badge.rotation = deg_to_rad(-8)
		sale_badge.z_index = 5
	if sale_badge:
		sale_badge.visible = has_sale()
		sale_badge.set_caption("2×1" if sale_two_for_one else "−%d%%" % sale_discount_percent)

@export var shop_item: ItemBase: set = _set_shop_item

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_type: Label = %ItemType
@onready var item_description: RichTextLabel = %ItemDescription
@onready var item_cost: Label = %ItemCost

func _ready() -> void:
	item_name.resized.connect(_fit_item_title)
	item_type.add_theme_font_size_override("font_size",roundi(20*text_scale*body_text_scale))
	item_cost.add_theme_font_size_override("font_size",roundi(40*text_scale*price_text_scale))
	for key in ["normal_font_size","bold_font_size","italics_font_size","bold_italics_font_size","mono_font_size"]:
		item_description.add_theme_font_size_override(key,roundi(20*text_scale*body_text_scale))
	$MarginContainer/Control/CustomButton/HBoxContainer/TextureRect.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	$MarginContainer/Control/CustomButton/HBoxContainer/TextureRect.custom_minimum_size=Vector2.ONE*price_icon_size
	if price_icon_right:
		var row=$MarginContainer/Control/CustomButton/HBoxContainer
		row.move_child(row.get_node("TextureRect"),row.get_child_count()-1)
	UITheme.palette_changed.connect(_refresh_palette)
	lock_button = Button.new()
	lock_button.name = "LockButton"
	lock_button.toggle_mode = true
	lock_button.text = "LOCK"
	lock_button.add_theme_font_size_override("font_size", roundi(24*text_scale))
	var actions := VBoxContainer.new()
	actions.name = "Actions"
	$MarginContainer/Control.add_child(actions)
	actions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	actions.offset_top = -(action_buy_height+action_lock_height+8.0)
	actions.add_theme_constant_override("separation", 8)
	var buy_button: Button = $MarginContainer/Control/CustomButton
	buy_button.reparent(actions)
	buy_button.custom_minimum_size = Vector2(0, action_buy_height)
	buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(lock_button)
	lock_button.custom_minimum_size = Vector2(0, action_lock_height)
	lock_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	lock_button.tooltip_text = "Keep this item through refreshes and waves. Sales survive refreshes while locked, but end when leaving the shop."
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
	if shop_item:
		var saved_discount := sale_discount_percent
		var saved_double := sale_two_for_one
		_set_shop_item(shop_item)
		set_sale(saved_discount, saved_double)

func _set_shop_item(value: ItemBase) -> void:
	sale_discount_percent = 0
	sale_two_for_one = false
	shop_item = value
	item_icon.texture = shop_item.item_icon
	ItemBase.scale_icon(item_icon, shop_item.icon_scale)
	item_name.text = shop_item.item_name.replace("\n"," ")
	_fit_item_title()
	item_type.text = ItemBase.ItemType.keys()[shop_item.item_type]
	if shop_item is ItemWeapon:
		item_description.text = UITheme.rich_text((shop_item as ItemWeapon).get_description(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null))
	else:
		item_description.text = UITheme.rich_text(shop_item.get_description())
	item_cost.text = str(shop_item.get_shop_price(shop_wave))
	
	var style := Global.get_tier_style(shop_item.item_tier)
	set_meta("ui_tier", int(shop_item.item_tier))
	add_theme_stylebox_override("panel", style)
	load("res://scenes/ui/rarity_marker.gd").apply(self, int(shop_item.item_tier))
	_refresh_sale()


func _fit_item_title() -> void:
	if not is_instance_valid(item_name) or item_name.size.x<=0: return
	var font: Font=item_name.get_theme_font("font")
	var text: String=item_name.text.to_upper() if item_name.uppercase else item_name.text
	var maximum: int=roundi(20*text_scale)
	var measured: float=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,maximum).x
	var fitted: int=maximum if measured<=item_name.size.x else maxi(1,floori(maximum*item_name.size.x/measured))
	while fitted>1 and font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,fitted).x>item_name.size.x:
		fitted-=1
	if item_name.get_theme_font_size("font_size")!=fitted:
		item_name.add_theme_font_size_override("font_size",fitted)

func _on_custom_button_pressed() -> void:
	if purchase_in_progress: return
	purchase_in_progress = true
	if purchase_handler.is_valid() and purchase_handler.call(shop_item):
		on_item_purchased.emit(shop_item)
	purchase_in_progress = false
