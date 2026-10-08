extends Panel
class_name SelectionPanel

signal on_selection_completed
signal on_level_select_exited

const SELECTION_CARD = preload("res://scenes/ui/selection_panel/selection_card.tscn")

@export var player_list: Array[UnitStats]
@export var weapons_list: Array[ItemWeapon]

@onready var players_container: HBoxContainer = %PlayersContainer
@onready var weapons_container: HBoxContainer = %WeaponsContainer

@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_title: Label = %PlayerTitle
@onready var player_description: RichTextLabel = %PlayerDescription
@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_name: Label = %WeaponName
@onready var weapon_title: Label = %WeaponTitle
@onready var weapon_description: RichTextLabel = %WeaponDescription
@onready var weapon_label: Label = $WeaponLabel
@onready var player_label: Label = $PlayerLabel
var player_group := ButtonGroup.new()
var weapon_group := ButtonGroup.new()

func _ready() -> void:
	for child in players_container.get_children(): child.queue_free()
	for child in weapons_container.get_children(): child.queue_free()
	
	load_players()
	load_weapons()
	show_player_info(false)
	show_weapon_info(false)
	visibility_changed.connect(_refresh_selection_info)
	_refresh_selection_info()

func _refresh_selection_info() -> void:
	if not is_visible_in_tree(): return
	_update_selected_slots()
	show_player_info(Global.main_player_selected != null)
	show_weapon_info(Global.main_weapon_selected != null)
	if Global.main_player_selected: _on_player_selected(Global.main_player_selected)
	if Global.main_weapon_selected: _on_weapon_selected(Global.main_weapon_selected)

func show_weapon_info(value: bool) -> void:
	weapon_icon.visible = value
	weapon_name.visible = value
	weapon_title.visible = value
	weapon_description.visible = value

func load_players() -> void:
	if player_list.is_empty(): return
	
	for player: UnitStats in player_list:
		var card := SELECTION_CARD.instantiate() as SelectionCard
		card.pressed.connect(_on_player_selected.bind(player))
		card.button_group = player_group
		card.set_meta("selection_data", player)
		players_container.add_child(card)
		card.set_icon(player.icon)

func load_weapons() -> void:
	if weapons_list.is_empty(): return
	
	for weapon: ItemWeapon in weapons_list:
		var card := SELECTION_CARD.instantiate() as SelectionCard
		card.pressed.connect(_on_weapon_selected.bind(weapon))
		card.button_group = weapon_group
		card.set_meta("selection_data", weapon)
		weapons_container.add_child(card)
		card.set_icon(weapon.item_icon)

func show_player_info(value: bool) -> void:
	player_icon.visible = value
	player_name.visible = value
	player_title.visible = value
	player_description.visible = value

func _on_player_selected(player: UnitStats) -> void:
	Global.main_player_selected = player
	_update_selected_slots()
	show_player_info(true)
	
	player_icon.texture = player.icon
	player_name.text = player.name
	var stat_lines: PackedStringArray = [
		"Health: [color=green]%s[/color]" % player.health,
		"Damage: [color=green]%s%%[/color]" % player.damage_percent,
		"Melee damage: [color=green]%s[/color]" % player.melee_damage,
		"Ranged damage: [color=green]%s[/color]" % player.ranged_damage,
		"Attack speed: [color=green]%s%%[/color]" % player.attack_speed,
		"Speed: [color=green]%s[/color]" % player.speed,
		"Luck: [color=green]%s[/color]" % player.luck,
		"Block chance: [color=green]%s%%[/color]" % player.block_chance,
		"HP regen / 3 s: [color=green]%s[/color]" % player.hp_regen,
		"Life steal: [color=green]%s%%[/color]" % player.life_steal,
		"Harvesting: [color=green]%s[/color]" % player.harvesting
	]
	player_description.text = "\n".join(stat_lines)
	if Global.main_weapon_selected:
		_on_weapon_selected(Global.main_weapon_selected)

func _on_weapon_selected(weapon: ItemWeapon) -> void:
	Global.main_weapon_selected = weapon
	_update_selected_slots()
	show_weapon_info(true)
	weapon_icon.texture = weapon.item_icon
	weapon_name.text = weapon.item_name
	weapon_title.text = "Melee weapon" if weapon.type == ItemWeapon.Type.MELEE else "Ranged weapon"
	weapon_description.text = weapon.get_description(Global.main_player_selected)


func _update_selected_slots() -> void:
	for card in players_container.get_children():
		if not card.has_meta("selection_data"): continue
		card.set_pressed_no_signal(card.get_meta("selection_data", null) == Global.main_player_selected and Global.main_player_selected != null)
	for card in weapons_container.get_children():
		if not card.has_meta("selection_data"): continue
		card.set_pressed_no_signal(card.get_meta("selection_data", null) == Global.main_weapon_selected and Global.main_weapon_selected != null)

func _on_custom_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if not Global.main_player_selected: 
		player_label.modulate.a = 1
		player_label.show()
		var tween := create_tween()
		tween.tween_property(player_label, "modulate:a", 0, 1)
		await tween.finished
		player_label.hide()
		
	if not Global.main_weapon_selected: 
		weapon_label.modulate.a = 1
		weapon_label.show()
		var tween := create_tween()
		tween.tween_property(weapon_label, "modulate:a", 0, 1)
		await tween.finished
		weapon_label.hide()
		
	if not Global.main_player_selected or not Global.main_weapon_selected: return

	on_selection_completed.emit()
	hide()


func _on_custom_button_exit_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	on_level_select_exited.emit()
