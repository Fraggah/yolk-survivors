extends Panel
class_name UpgradeCard

@export var item: ItemUpgrade: set = _set_data

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription

func _set_data(value: ItemUpgrade) -> void:
	item = value
	item_icon.texture = item.item_icon
	item_name.text = item.item_name
	item_description.text = item.description
