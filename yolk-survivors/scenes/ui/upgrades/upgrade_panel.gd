extends Panel
class_name UpgradePanel

const UPGRADE_CARD_SCENE = preload("res://scenes/ui/upgrades/upgrade_card.tscn")

@export var upgrades: Array[ItemUpgrade]

@onready var item_container: HBoxContainer = %ItemContainer


func load_upgrades(current_wave: int) -> void:
	print("AAAAAAAAAAAAAAAA")
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			child.queue_free()
	
	var config := Global.UPGRADE_PROBABILITY_CONFIG
	var selected_upgrades := Global.select_items_for_offer(upgrades, current_wave, config)
	
	print(selected_upgrades)
	for upgrade: ItemUpgrade in selected_upgrades:
		var upgraded_instance := UPGRADE_CARD_SCENE.instantiate()
		item_container.add_child(upgraded_instance)
		upgraded_instance.item = upgrade
