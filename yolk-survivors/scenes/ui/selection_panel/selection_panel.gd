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

@onready var players_container: GridContainer = %PlayersContainer
@onready var weapons_container: GridContainer = %WeaponsContainer

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

var preview_player: UnitStats
var preview_weapon: ItemWeapon
const SILHOUETTE = preload("res://shaders/locked_silhouette.gdshader")

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
	Progression.progress_changed.connect(_on_progress_changed)
	UITheme.palette_changed.connect(_on_progress_changed)
	_update_card_locks()
	visibility_changed.connect(_refresh_selection_info)
	_refresh_selection_info()

func _refresh_selection_info() -> void:
	if not is_visible_in_tree(): return
	_update_card_locks()
	_update_weapon_availability()
	_update_selected_slots()
	show_player_info(Global.main_player_selected != null)
	show_weapon_info(Global.main_weapon_selected != null)
	if Global.main_player_selected: _show_player_preview(Global.main_player_selected)
	if Global.main_weapon_selected: _show_weapon_preview(Global.main_weapon_selected)

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
		card.focus_entered.connect(_show_player_preview.bind(player))
		card.focus_exited.connect(_restore_selected_player_preview)
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
		card.mouse_entered.connect(_show_weapon_preview.bind(weapon))
		card.mouse_exited.connect(_restore_selected_weapon_preview)
		card.focus_entered.connect(_show_weapon_preview.bind(weapon))
		card.focus_exited.connect(_restore_selected_weapon_preview)
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
	if not Progression.is_character_unlocked(player):
		_update_selected_slots()
		return
	Global.main_player_selected = player
	_update_weapon_availability()
	_update_selected_slots()
	_show_player_preview(player)
	if selection_mode == SelectionMode.CHARACTER and is_visible_in_tree():
		_complete_selection()

func _show_player_preview(player: UnitStats) -> void:
	preview_player = player
	show_player_info(true)
	player_icon.texture = player.icon
	player_name.text = player.name
	var unlocked := Progression.is_character_unlocked(player)
	player_title.text = "Player" if unlocked else "Locked"
	_set_portrait_lock(player_icon, not unlocked)
	player_description.text = get_character_description(player) if unlocked else Progression.requirement_for(player.unlock_id, true)

func _restore_selected_player_preview() -> void:
	if Global.main_player_selected:
		_show_player_preview(Global.main_player_selected)
	else:
		show_player_info(false)
		preview_player = null

func _on_weapon_selected(weapon: ItemWeapon) -> void:
	if not Global.is_valid_starting_weapon(weapon) or not Progression.is_weapon_unlocked(weapon) or not Global.main_player_selected or not Global.main_player_selected.can_use_weapon(weapon):
		_update_selected_slots()
		return
	Global.main_weapon_selected = weapon
	_update_selected_slots()
	_show_weapon_preview(weapon)
	if selection_mode == SelectionMode.WEAPON and is_visible_in_tree():
		_complete_selection()

func _show_weapon_preview(weapon: ItemWeapon) -> void:
	preview_weapon = weapon
	show_weapon_info(true)
	weapon_icon.texture = weapon.item_icon
	weapon_name.text = weapon.item_name
	weapon_title.text = "Melee weapon" if weapon.type == ItemWeapon.Type.MELEE else "Ranged weapon"
	var unlocked := Progression.is_weapon_unlocked(weapon)
	_set_portrait_lock(weapon_icon, not unlocked)
	if not unlocked:
		weapon_title.text = "Locked"
		weapon_description.text = Progression.requirement_for(weapon.unlock_id, false)
	else:
		weapon_description.text = UITheme.rich_text(weapon.get_description(Global.main_player_selected.get_passive_preview() if Global.main_player_selected else null))
		if Global.main_player_selected and not Global.main_player_selected.can_use_weapon(weapon):
			weapon_title.text = "Cannot equip"



func _restore_selected_weapon_preview() -> void:
	if Global.main_weapon_selected:
		_show_weapon_preview(Global.main_weapon_selected)
	else:
		show_weapon_info(false)
		preview_weapon = null

func _update_weapon_availability() -> void:
	if Global.main_player_selected and Global.main_weapon_selected and (not Progression.is_weapon_unlocked(Global.main_weapon_selected) or not Global.main_player_selected.can_use_weapon(Global.main_weapon_selected)):
		Global.main_weapon_selected = null
	for card in weapons_container.get_children():
		if not card.has_meta("selection_data"): continue
		var allowed := Global.main_player_selected != null and Global.main_player_selected.can_use_weapon(card.get_meta("selection_data"))
		card.disabled = false # Locked cards remain inspectable with a controller.
		card.toggle_mode = allowed and not card.locked
		card.modulate.a = 0.4 if not allowed else 1.0

func _set_portrait_lock(portrait: TextureRect, locked: bool) -> void:
	if locked:
		var silhouette := ShaderMaterial.new()
		silhouette.shader = SILHOUETTE
		silhouette.set_shader_parameter("silhouette_color", UITheme.palette.muted)
		portrait.material = silhouette
	else:
		portrait.material = null

func _update_card_locks() -> void:
	for card in players_container.get_children():
		if card.has_meta("selection_data"):
			card.set_locked(not Progression.is_character_unlocked(card.get_meta("selection_data")))
	for card in weapons_container.get_children():
		if card.has_meta("selection_data"):
			card.set_locked(not Progression.is_weapon_unlocked(card.get_meta("selection_data")))

func _on_progress_changed() -> void:
	if not is_visible_in_tree(): return
	_update_card_locks()
	_update_weapon_availability()
	if preview_player: _show_player_preview(preview_player)
	if preview_weapon: _show_weapon_preview(preview_weapon)

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
			var color := UITheme.color_hex("positive" if difference > 0.0 else "negative")
			var suffix := "%" if stat[2] else ""
			lines.append("%s: [color=%s]%s%s%s[/color]" % [stat[1], color, sign_text, ItemWeapon.format_number(difference), suffix])
	if lines.is_empty(): lines.append("Balanced base stats.")
	if Global.is_valid_starting_weapon(player.starting_weapon):
		lines.append("\nStarting weapon: %s" % player.starting_weapon.item_name)
	lines.append("\n[color=%s]PASSIVES[/color]" % UITheme.color_hex("accent"))
	var passive_lines: PackedStringArray = []
	for passive in player.character_passives:
		if passive and passive.is_valid(): passive_lines.append("[color=%s]- %s[/color]" % [UITheme.color_hex("accent"), passive.get_description()])
	if passive_lines.is_empty(): passive_lines.append("No character passives.")
	lines.append_array(passive_lines)
	return UITheme.rich_text("\n".join(lines))

func _complete_selection() -> void:
	hide()
	on_selection_completed.emit()


func _on_custom_button_exit_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	on_level_select_exited.emit()
