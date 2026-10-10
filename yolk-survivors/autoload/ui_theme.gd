extends Node

signal palette_changed

const PALETTES := {
	"cream": preload("res://resources/ui/palettes/cream.tres"),
	"sage": preload("res://resources/ui/palettes/sage.tres"),
	"cocoa": preload("res://resources/ui/palettes/cocoa.tres")
}
const FONT = preload("res://assets/font/Bake Soda.otf")
var palette: Resource = PALETTES.cream
var ui_theme := Theme.new()
var tier_styles: Array[StyleBoxFlat] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	palette = PALETTES.get(ProjectSettings.get_setting("yolk/ui/palette", "cream"), PALETTES.cream)
	_rebuild()
	get_tree().node_added.connect(_on_node_added)

func set_palette(id: String) -> void:
	if not PALETTES.has(id): return
	palette = PALETTES[id]
	_rebuild()
	apply_tree(get_tree().root)
	palette_changed.emit()

func color_hex(role: String) -> String:
	return "#" + (palette.get(role) as Color).to_html(false)

func rich_text(text: String) -> String:
	return text.replace("[color=green]", "[color=%s]" % color_hex("positive")).replace("[color=#ff6969]", "[color=%s]" % color_hex("negative")).replace("[color=#ffe395]", "[color=%s]" % color_hex("accent"))

func box(fill: Color, edge: Color, radius: int = -1, border: int = -1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(palette.border_width if border < 0 else border)
	style.set_corner_radius_all(palette.radius if radius < 0 else radius)
	# Margins never vary with state: hovering/pressing cannot move text or icons.
	style.set_content_margin_all(0)
	return style

func focus_style() -> StyleBoxFlat:
	return box(Color.TRANSPARENT, palette.focus, -1, palette.focus_width)

func _bind_button_focus(button: Button) -> void:
	if not button.has_meta("ui_focus_bound"):
		button.set_meta("ui_focus_bound", true)
		button.focus_entered.connect(_update_button_focus.bind(button))
		button.focus_exited.connect(_clear_button_focus.bind(button))
		button.button_down.connect(_button_focus_down.bind(button))
		button.button_up.connect(_button_focus_up.bind(button))
		button.toggled.connect(_button_focus_toggled.bind(button))
	_update_button_focus(button)

func _update_button_focus(button: Button) -> void:
	if not button.has_focus() or button.disabled:
		_clear_button_focus(button)
		return
	if button.has_theme_stylebox_override("focus") and button.get_theme_stylebox("normal") == button.get_theme_stylebox("hover") and button.get_theme_stylebox("pressed") == button.get_theme_stylebox("hover_pressed"):
		return
	# Godot draws the base button over the focus background. Apply hover to
	# the base states themselves, then keep focus as a transparent outline.
	for state in ["normal", "pressed"]:
		var key: String = "ui_focus_saved_" + state
		if not button.has_meta(key):
			button.set_meta(key, [button.has_theme_stylebox_override(state), button.get_theme_stylebox(state)])
		button.add_theme_stylebox_override(state, button.get_theme_stylebox("hover" if state == "normal" else "hover_pressed"))
	button.add_theme_stylebox_override("focus", focus_style())

func _clear_button_focus(button: Button) -> void:
	for state in ["normal", "pressed"]:
		var key: String = "ui_focus_saved_" + state
		if button.has_meta(key):
			var saved: Array = button.get_meta(key)
			if saved[0]: button.add_theme_stylebox_override(state, saved[1])
			else: button.remove_theme_stylebox_override(state)
			button.remove_meta(key)
	button.remove_theme_stylebox_override("focus")
	button.set_meta("ui_focus_down", false)

func _button_focus_down(button: Button) -> void:
	button.set_meta("ui_focus_down", true)
	_update_button_focus(button)

func _button_focus_up(button: Button) -> void:
	button.set_meta("ui_focus_down", false)
	_update_button_focus(button)

func _button_focus_toggled(_pressed: bool, button: Button) -> void:
	_update_button_focus(button)

func tier_style(tier: int) -> StyleBoxFlat:
	return tier_styles[clampi(tier, 0, 3)]

func selected_tier_style(_tier: int) -> StyleBoxFlat:
	return box(palette.surface.lerp(palette.button, 0.15), palette.focus, -1, 3)

func _button_styles(base: Color, edge: Color) -> Dictionary:
	return {
		"normal": box(base, edge),
		"hover": box(palette.hover_surface, palette.focus, -1, palette.focus_width),
		"pressed": box(base.lerp(palette.outline, 0.12), palette.focus, -1, 3),
		"hover_pressed": box(palette.hover_selected, palette.focus, -1, palette.focus_width),
		"disabled": box(palette.disabled, palette.disabled_text.lerp(palette.disabled, 0.6)),
		"focus": focus_style()
	}

func style_slot(button: Button, tier: int = 0) -> void:
	_clear_button_focus(button)
	button.set_meta("ui_tier", tier)
	button.theme = ui_theme
	var states := _button_styles(palette.surface, palette.rarity(tier))
	states.normal.set_border_width_all(3)
	for state in states:
		button.add_theme_stylebox_override(state, states[state])
	_bind_button_focus(button)

func _rebuild() -> void:
	ui_theme = Theme.new()
	ui_theme.default_font = FONT
	ui_theme.default_font_size = 24
	ui_theme.set_type_variation("HudLabel", "Label")
	ui_theme.set_color("font_color", "HudLabel", palette.hud_text)
	ui_theme.set_color("font_outline_color", "HudLabel", palette.outline)
	ui_theme.set_constant("outline_size", "HudLabel", 4)
	for type_name in ["Label", "RichTextLabel", "Button", "CheckButton"]:
		ui_theme.set_color("font_color", type_name, palette.text)
		ui_theme.set_color("default_color", type_name, palette.text)
		ui_theme.set_color("font_outline_color", type_name, Color.TRANSPARENT)
	for type_name in ["Button", "PrimaryButton", "DangerButton"]:
		if type_name != "Button": ui_theme.set_type_variation(type_name, "Button")
		var fill: Color = palette.primary if type_name == "PrimaryButton" else (palette.danger if type_name == "DangerButton" else palette.button)
		var states := _button_styles(fill, palette.outline)
		for state in states: ui_theme.set_stylebox(state, type_name, states[state])
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
			ui_theme.set_color(state, type_name, palette.text)
		ui_theme.set_color("font_disabled_color", type_name, palette.disabled_text)
	for type_name in ["Panel", "PanelContainer"]:
		ui_theme.set_stylebox("panel", type_name, box(palette.surface, palette.outline))
	ui_theme.set_type_variation("ScreenPanel", "Panel")
	ui_theme.set_stylebox("panel", "ScreenPanel", box(palette.background, Color.TRANSPARENT, 0, 0))
	ui_theme.set_type_variation("InsetPanel", "Panel")
	ui_theme.set_stylebox("panel", "InsetPanel", box(palette.inset, Color.TRANSPARENT, 8, 0))
	ui_theme.set_type_variation("OverlayPanel", "Panel")
	ui_theme.set_stylebox("panel", "OverlayPanel", box(Color(0.05, 0.04, 0.03, 0.65), Color.TRANSPARENT, 0, 0))
	for state in ["slider", "grabber_area", "grabber_area_highlight"]:
		var track := box(palette.inset if state == "slider" else palette.primary, palette.focus if state == "grabber_area_highlight" else palette.outline, 6, 2)
		track.content_margin_top = 6
		track.content_margin_bottom = 6
		ui_theme.set_stylebox(state, "HSlider", track)
	ui_theme.set_stylebox("focus", "HSlider", focus_style())
	for icon_name in ["grabber", "grabber_highlight", "grabber_disabled"]:
		var image := Image.new()
		var fill: Color = palette.disabled if icon_name == "grabber_disabled" else palette.primary
		image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28"><circle cx="14" cy="14" r="11" fill="#%s" stroke="#%s" stroke-width="3"/></svg>' % [fill.to_html(false), palette.outline.to_html(false)])
		ui_theme.set_icon(icon_name, "HSlider", ImageTexture.create_from_image(image))
	for scrollbar in ["VScrollBar", "HScrollBar"]:
		ui_theme.set_stylebox("scroll", scrollbar, box(palette.inset, Color.TRANSPARENT, 6, 0))
		for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
			ui_theme.set_stylebox(state, scrollbar, box(palette.button, palette.outline, 6, 1))
	tier_styles.clear()
	for tier in 4: tier_styles.append(box(palette.surface, palette.rarity(tier), -1, 3))

func _on_node_added(node: Node) -> void:
	if node is Control: apply_control.call_deferred(node)

func apply_tree(node: Node) -> void:
	if node is Control: apply_control(node)
	for child in node.get_children(): apply_tree(child)

func apply_control(node) -> void:
	if not is_instance_valid(node) or node.is_queued_for_deletion(): return
	# Only UI controls. World-space effects retain their gameplay colors.
	var ui: bool = node.scene_file_path.begins_with("res://scenes/ui/")
	var ancestor: Node = node
	while ancestor:
		if ancestor.scene_file_path.begins_with("res://scenes/ui/floating_text/"): return
		if ancestor.name == "GameUI" or ancestor.scene_file_path.begins_with("res://scenes/ui/"): ui = true
		ancestor = ancestor.get_parent()
	if not ui: return
	if node is Button: _clear_button_focus(node)
	node.theme = ui_theme
	if node is Button and node.has_meta("ui_tier"): style_slot(node, node.get_meta("ui_tier"))
	if node is Button: _bind_button_focus(node)
	if node is Button and node.get("portrait") is TextureRect:
		var portrait: TextureRect = node.get("portrait")
		if portrait.material is ShaderMaterial: portrait.material.set_shader_parameter("silhouette_color", palette.muted)
	if node is Panel and node.has_meta("ui_tier"): node.add_theme_stylebox_override("panel", tier_style(node.get_meta("ui_tier")))
	if node is Label and node.label_settings:
		var settings: LabelSettings = node.label_settings.duplicate()
		settings.font_color = palette.text
		settings.outline_color = Color.TRANSPARENT
		# HUD remains readable over the arena regardless of menu palette.
		if node.name in ["WaveIndexLabel", "WaveTimerLabel", "Instructions"]: settings.font_color = palette.hud_text
		node.label_settings = settings
	if node is Label and node.has_meta("ui_color") and node.label_settings:
		node.label_settings.font_color = palette.hud_text if node.get_meta("ui_color") == "hud" else palette.get(node.get_meta("ui_color"))
	if node is Label and node.has_meta("ui_color"):
		node.add_theme_color_override("font_color", palette.hud_text if node.get_meta("ui_color") == "hud" else palette.get(node.get_meta("ui_color")))
	if node is Label and node.name in ["CoinsLabel", "ReserveLabel"] and node.get_parent().get_parent().get_parent().name == "GameUI":
		node.add_theme_color_override("font_color", palette.hud_text)
