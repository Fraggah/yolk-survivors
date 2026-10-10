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
	$HBoxContainer/VBoxContainer/Label.add_theme_color_override("font_color", UITheme.palette.hud_text)
	reroll_button = Button.new()
	reroll_button.name = "UpgradeRerollButton"
	reroll_button.custom_minimum_size = Vector2(350, 60)
	reroll_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	$HBoxContainer/VBoxContainer.add_child(reroll_button)
	var content := HBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	reroll_button.add_child(content)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	reroll_label = Label.new()
	reroll_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reroll_label.add_theme_font_size_override("font_size", 40)
	content.add_child(reroll_label)
	var icon := TextureRect.new()
	icon.texture = preload("res://assets/sprites/Yolk/yolk.png")
	icon.custom_minimum_size = Vector2(40, 40)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(icon)
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
	if try_reroll(): SoundManager.play_sound(SoundManager.Sound.UI_CLICK)

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	reroll_label.text = "refresh %d" % get_reroll_cost()
	reroll_button.disabled = Global.coins < get_reroll_cost()
	reroll_label.add_theme_color_override("font_color", UITheme.palette.disabled_text if reroll_button.disabled else UITheme.palette.text)

@onready var item_container: HBoxContainer = %ItemContainer


func load_upgrades(current_wave: int) -> void:
	offer_level = current_wave
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()
	
	var config := Global.UPGRADE_PROBABILITY_CONFIG
	var selected_upgrades := Global.select_items_for_offer(upgrades, current_wave, config)
	
	for upgrade: ItemUpgrade in selected_upgrades:
		var upgraded_instance := UPGRADE_CARD_SCENE.instantiate()
		item_container.add_child(upgraded_instance)
		upgraded_instance.item = upgrade
