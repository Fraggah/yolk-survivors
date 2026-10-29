extends Panel
class_name ShopCard

signal on_item_purchased(item: ItemBase)
var preview_stats: UnitStats
var purchase_handler: Callable
var shop_wave := 1
var title_maximum := 20
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
		sale_badge = preload("res://scenes/ui/shop/sale_badge.tscn").instantiate()
		add_child(sale_badge)
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
	title_maximum=item_name.get_theme_font_size("font_size")
	item_name.resized.connect(_fit_item_title)
	UITheme.palette_changed.connect(_refresh_palette)
	lock_button=$MarginContainer/Control/Actions/LockButton
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
	
	var colors := Global.get_tier_style(shop_item.item_tier)
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color=colors.bg_color
	style.border_color=colors.border_color
	set_meta("ui_tier", int(shop_item.item_tier))
	add_theme_stylebox_override("panel", style)
	load("res://scenes/ui/rarity_marker.gd").apply(self, int(shop_item.item_tier))
	_refresh_sale()


func _fit_item_title() -> void:
	if not is_instance_valid(item_name) or item_name.size.x<=0: return
	var font: Font=item_name.get_theme_font("font")
	var text: String=item_name.text.to_upper() if item_name.uppercase else item_name.text
	var maximum: int=title_maximum
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
