extends Button
class_name ItemCard

signal on_item_card_selected(card: ItemCard)

@export var item: ItemBase: set  = _set_item

@onready var item_icon: TextureRect = $ItemIcon

func _ready() -> void:
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _set_item(value: ItemBase) -> void:
	item = value
	if not is_node_ready(): await ready
	item_icon.texture = item.item_icon
	
	var style := Global.get_tier_style(item.item_tier)
	toggle_mode = item.item_type == ItemBase.ItemType.WEAPON
	SlotSelectionStyle.apply(self, style)


func _on_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if item.item_type == ItemBase.ItemType.WEAPON:
		Global.selected_weapon = item as ItemWeapon
		on_item_card_selected.emit(self)
