extends Panel
class_name PausePanel

signal on_return_pressed
signal on_exit_pressed

var weapons_grid: GridContainer

func _ready() -> void:
	var layout := $VBoxContainer
	layout.custom_minimum_size = Vector2(1100, 750)
	layout.offset_left = -550
	layout.offset_right = 550
	layout.offset_top = -375
	layout.offset_bottom = 375
	$Instructions.hide()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 40)
	layout.add_child(row)
	var stats := preload("res://scenes/ui/stats/stats_container.tscn").instantiate()
	row.add_child(stats)
	var equipment := VBoxContainer.new()
	equipment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment.add_theme_constant_override("separation", 24)
	row.add_child(equipment)
	var title := Label.new()
	title.text = "WEAPONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	equipment.add_child(title)
	weapons_grid = GridContainer.new()
	weapons_grid.columns = 3
	weapons_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	weapons_grid.add_theme_constant_override("h_separation", 16)
	weapons_grid.add_theme_constant_override("v_separation", 16)
	equipment.add_child(weapons_grid)
	$VBoxContainer/ReturnButton.reparent(equipment)
	$VBoxContainer/ExitButton.reparent(equipment)
	visibility_changed.connect(_refresh_weapons)
	UITheme.palette_changed.connect(_refresh_weapons)

func _refresh_weapons() -> void:
	for child in weapons_grid.get_children():
		weapons_grid.remove_child(child)
		child.queue_free()
	if not visible or not is_instance_valid(Global.player): return
	for weapon: Weapon in Global.player.current_weapons:
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(110, 110)
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_theme_stylebox_override("panel", UITheme.box(UITheme.palette.surface, UITheme.palette.rarity(weapon.data.item_tier), 16, 3))
		weapons_grid.add_child(tile)
		var content := Control.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(content)
		var icon := TextureRect.new()
		icon.texture = weapon.data.item_icon
		ItemBase.scale_icon(icon, weapon.data.icon_scale)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		load("res://scenes/ui/rarity_marker.gd").apply(content, weapon.data.item_tier, true)

func _on_return_button_pressed() -> void:
	on_return_pressed.emit()

func _on_exit_button_pressed() -> void:
	on_exit_pressed.emit()
