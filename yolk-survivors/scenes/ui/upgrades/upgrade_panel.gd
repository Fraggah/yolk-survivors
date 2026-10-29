extends Panel
class_name UpgradePanel

const UPGRADE_CARD_SCENE = preload("res://scenes/ui/upgrades/upgrade_card.tscn")

@export var upgrades: Array[ItemUpgrade]

var offer_level := 1
var completed_wave := 1
var reroll_count := 0
var reroll_button: Button
var reroll_label: Label

func _ready() -> void:
	for stat in ["area_of_effect", "critical_multiplier", "block_effectiveness", "effects"]:
		for tier in range(1,5):
			var item = load("res://resources/items/upgrades/data/%s/upgrade_%s_%s.tres" % [stat, stat, tier])
			if not upgrades.has(item): upgrades.append(item)
	# This stat is explicitly item-only, even if a resource is accidentally added in the editor.
	upgrades = upgrades.filter(func(item): return item.stat_id != "fire_tick_speed")
	$HBoxContainer/VBoxContainer/Label.add_theme_color_override("font_color", UITheme.palette.hud_text)
	reroll_button=$HBoxContainer/VBoxContainer/UpgradeRerollButton
	reroll_label=reroll_button.get_node("Content/Cost")
	reroll_button.pressed.connect(_on_reroll_pressed)

func begin_wave_rewards(wave: int) -> void:
	completed_wave = maxi(1, wave)
	reroll_count = 0

func get_reroll_cost() -> int:
	return ItemBase.ECONOMY_RULES.reroll_price(completed_wave, reroll_count)

func try_reroll() -> bool:
	if not is_visible_in_tree() or Global.coins < get_reroll_cost(): return false
	Global.coins -= get_reroll_cost()
	reroll_count += 1
	load_upgrades(offer_level)
	return true

func _on_reroll_pressed() -> void:
	if try_reroll(): SoundManager.play_sound(SoundManager.Sound.SHOP_REROLL)

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	reroll_label.text = "refresh %d" % get_reroll_cost()
	reroll_button.disabled = Global.coins < get_reroll_cost()
	reroll_label.add_theme_color_override("font_color", UITheme.palette.disabled_text if reroll_button.disabled else UITheme.palette.text)

@onready var item_container: HBoxContainer = %ItemContainer


func load_upgrades(character_level: int) -> void:
	offer_level = maxi(1, character_level)
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()

	var config := Global.UPGRADE_PROBABILITY_CONFIG
	var selected_upgrades := Global.select_items_for_offer(upgrades, offer_level, config)

	for upgrade: ItemUpgrade in selected_upgrades:
		var upgraded_instance := UPGRADE_CARD_SCENE.instantiate()
		item_container.add_child(upgraded_instance)
		upgraded_instance.item = upgrade
