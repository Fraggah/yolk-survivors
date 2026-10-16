extends Button
class_name ItemCard

signal on_item_card_selected(card: ItemCard)
var weapon_instance: Weapon

@export var item: ItemBase: set  = _set_item

var quantity := 1:
	set(value):
		quantity = maxi(1, value)
		if is_node_ready() and item: _refresh_marker()

@onready var item_icon: TextureRect = $ItemIcon

func _ready() -> void:
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UITheme.palette_changed.connect(func():
		if item: _refresh_marker()
	)

func _set_item(value: ItemBase) -> void:
	item = value
	if not is_node_ready(): await ready
	item_icon.texture = item.item_icon
	ItemBase.scale_icon(item_icon, item.icon_scale)
	
	toggle_mode = item.item_type == ItemBase.ItemType.WEAPON
	UITheme.style_slot(self, int(item.item_tier))
	_refresh_marker()


func _on_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if item.item_type == ItemBase.ItemType.WEAPON:
		Global.selected_weapon = item as ItemWeapon
		on_item_card_selected.emit(self)

func _refresh_marker() -> void:
	load("res://scenes/ui/rarity_marker.gd").apply(self, int(item.item_tier), true)
	if item.item_type == ItemBase.ItemType.PASSIVE:
		var marker := get_node("RarityMarker") as Panel
		marker.visible = quantity > 1
		var label := marker.get_node("Text") as Label
		label.text = str(quantity)
		label.add_theme_color_override("font_color", UITheme.palette.text)
