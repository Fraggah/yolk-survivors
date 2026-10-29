extends Panel
class_name PausePanel

signal on_return_pressed
signal on_exit_pressed

var bound_player: Player
@onready var stats: StatsContainer=$VBoxContainer/Row/Stats
@onready var weapons_grid: GridContainer=$VBoxContainer/Row/Equipment/Weapons
@onready var return_button: Button=$VBoxContainer/Row/Equipment/ReturnButton
func bind_player(player: Player = null, slot: int = -1) -> void:
	bound_player=player
	stats.bound_player=player
	stats.independent_navigation=slot>=0
	$VBoxContainer/Label.text="PAUSA · P%d" % (slot+1) if slot>=0 else "Game Paused"
	_refresh_weapons()

func _ready() -> void:
	visibility_changed.connect(_refresh_weapons)
	UITheme.palette_changed.connect(_refresh_weapons)

func _refresh_weapons() -> void:
	for child in weapons_grid.get_children():
		weapons_grid.remove_child(child)
		child.queue_free()
	var player: Player=bound_player if is_instance_valid(bound_player) else Global.player
	if not visible or not is_instance_valid(player): return
	for weapon: Weapon in player.current_weapons:
		var tile=preload("res://scenes/ui/pause_panel/pause_weapon_slot.tscn").instantiate()
		weapons_grid.add_child(tile)
		var style=tile.get_theme_stylebox("panel").duplicate()
		style.border_color=UITheme.palette.rarity(weapon.data.item_tier)
		tile.add_theme_stylebox_override("panel",style)
		var content=tile.get_node("Content")
		var icon=content.get_node("Icon")
		icon.texture=weapon.data.item_icon
		ItemBase.scale_icon(icon,weapon.data.icon_scale)
		load("res://scenes/ui/rarity_marker.gd").apply(content,weapon.data.item_tier,true)

func _on_return_button_pressed() -> void:
	on_return_pressed.emit()

func _on_exit_button_pressed() -> void:
	on_exit_pressed.emit()
