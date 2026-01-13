extends Panel
class_name UpgradePanel

const UPGRADE_CARD_SCENE = preload("res://scenes/ui/upgrades/upgrade_card.tscn")

@export var upgrades: Array[ItemUpgrade]

@onready var item_container: HBoxContainer = %ItemContainer

func _ready() -> void:
	load_upgrades()

func load_upgrades() -> void:
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			child.queue_free()
	
	for i in 4:
		var upgrade := upgrades.pick_random() as ItemUpgrade
		var upgraded_instance := UPGRADE_CARD_SCENE.instantiate()
		item_container.add_child(upgraded_instance)
		upgraded_instance.item = upgrade
