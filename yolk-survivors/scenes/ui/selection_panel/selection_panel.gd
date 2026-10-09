extends Panel
class_name SelectionPanel

signal on_selection_completed
signal on_level_select_exited

const SELECTION_CARD = preload("res://scenes/ui/selection_panel/selection_card.tscn")

enum SelectionMode { CHARACTER, WEAPON }

@export var selection_mode: SelectionMode = SelectionMode.CHARACTER
# Well Rounded is the actual neutral player baseline, not UnitStats' enemy defaults.
@export var base_player_stats: UnitStats

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
@onready var heading: Label = $MarginContainer/VBoxContainer/Label
@onready var confirm_button: Button = $MarginContainer/VBoxContainer/Label/CustomButton
@onready var player_panel: Panel = $MarginContainer/VBoxContainer/Control/Panel
@onready var weapon_panel: Panel = $MarginContainer/VBoxContainer/Control/WeaponPanel

const DISPLAY_STATS := [
	["health", "Health", false], ["damage_percent", "Damage", true],
	["melee_damage", "Melee damage", false], ["ranged_damage", "Ranged damage", false],
	["attack_speed", "Attack speed", true], ["speed", "Speed", false],
	["luck", "Luck", false], ["block_chance", "Block chance", true],
	["hp_regen", "HP regen / 3 s", false], ["life_steal", "Life steal", true],
	["harvesting", "Harvesting", false]
]

var player_group := ButtonGroup.new()
var weapon_group := ButtonGroup.new()

func _ready() -> void:
	for child in players_container.get_children(): child.queue_free()
	for child in weapons_container.get_children(): child.queue_free()
	
	if selection_mode == SelectionMode.CHARACTER:
		load_players()
		player_panel.offset_left = -190.0
		player_panel.offset_right = 190.0
	else:
		load_weapons()
	players_container.visible = selection_mode == SelectionMode.CHARACTER
	weapons_container.visible = selection_mode == SelectionMode.WEAPON
	weapon_panel.visible = selection_mode == SelectionMode.WEAPON
	heading.text = "Select Player" if selection_mode == SelectionMode.CHARACTER else "Select Weapon"
	show_player_info(false)
	show_weapon_info(false)
	visibility_changed.connect(_refresh_selection_info)
	_refresh_selection_info()

func _refresh_selection_info() -> void:
	if not is_visible_in_tree(): return
	_update_confirm_button()
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
		card.mouse_entered.connect(_show_player_preview.bind(player))
		card.mouse_exited.connect(_restore_selected_player_preview)
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
	_show_player_preview(player)
	_update_confirm_button()
	if Global.main_weapon_selected:
		_on_weapon_selected(Global.main_weapon_selected)

func _show_player_preview(player: UnitStats) -> void:
	show_player_info(true)
	player_icon.texture = player.icon
	player_name.text = player.name
	player_description.text = get_character_description(player)

func _restore_selected_player_preview() -> void:
	if Global.main_player_selected:
		_show_player_preview(Global.main_player_selected)
	else:
		show_player_info(false)

func _on_weapon_selected(weapon: ItemWeapon) -> void:
	if not Global.is_valid_starting_weapon(weapon): return
	Global.main_weapon_selected = weapon
	_update_confirm_button()
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

func get_character_description(player: UnitStats) -> String:
	var lines: PackedStringArray = []
	if base_player_stats:
		for stat in DISPLAY_STATS:
			var difference := float(player.get(stat[0])) - float(base_player_stats.get(stat[0]))
			if is_zero_approx(difference): continue
			var sign_text := "+" if difference > 0.0 else ""
			var color := "green" if difference > 0.0 else "#ff6969"
			var suffix := "%" if stat[2] else ""
			lines.append("%s: [color=%s]%s%s%s[/color]" % [stat[1], color, sign_text, ItemWeapon.format_number(difference), suffix])
	if lines.is_empty(): lines.append("Balanced base stats.")
	if Global.is_valid_starting_weapon(player.starting_weapon):
		lines.append("\nStarting weapon: %s" % player.starting_weapon.item_name)
		lines.append("Plus the weapon you choose.")
	return "\n".join(lines)

func _update_confirm_button() -> void:
	confirm_button.disabled = not Global.main_player_selected
	if selection_mode == SelectionMode.WEAPON:
		confirm_button.disabled = confirm_button.disabled or not Global.is_valid_starting_weapon(Global.main_weapon_selected)

func _on_custom_button_pressed() -> void:
	_update_confirm_button()
	if confirm_button.disabled: return
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	hide()
	on_selection_completed.emit()


func _on_custom_button_exit_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	on_level_select_exited.emit()
