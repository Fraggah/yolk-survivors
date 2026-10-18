extends RefCounted

# Layout only: the future player slots do not introduce multiplayer state.
var menu: Control
var body: Control
var right_players: GridContainer
var back: Button
var weapon_scroll: ScrollContainer

func setup(panel: Control) -> void:
	menu = panel
	body = Control.new()
	body.name = "RosterLayout"
	menu.add_child(body)
	back = menu.heading.get_node("CustomButtonExit")
	for node in [menu.heading, back, menu.player_panel, menu.weapon_panel, menu.players_container, menu.weapons_container]:
		node.reparent(body)
		node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		node.custom_minimum_size = Vector2.ZERO
	menu.get_node("MarginContainer").hide()
	right_players = GridContainer.new()
	right_players.name = "RightPlayersContainer"
	body.add_child(right_players)
	right_players.columns = 3
	menu.players_container.columns = 3
	menu.weapons_container.columns = 8
	var cards = menu.players_container.get_children()
	for i in range(15, cards.size()): cards[i].reparent(right_players)
	if menu.selection_mode == menu.SelectionMode.CHARACTER:
		_add_placeholders(menu.players_container, maxi(0, 15 - menu.players_container.get_child_count()))
		_add_placeholders(right_players, maxi(0, 15 - right_players.get_child_count()))
	else:
		_add_placeholders(menu.weapons_container, maxi(0, 40 - menu.weapons_container.get_child_count()))
		weapon_scroll = ScrollContainer.new()
		weapon_scroll.name = "WeaponRosterScroll"
		weapon_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		weapon_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		weapon_scroll.follow_focus = true
		body.add_child(weapon_scroll)
		menu.weapons_container.reparent(weapon_scroll)
		menu.weapons_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_players.visible = menu.selection_mode == menu.SelectionMode.CHARACTER
	menu.resized.connect(refresh)
	menu.player_panel.resized.connect(refresh_player_detail)
	menu.player_description.resized.connect(fit_descriptions)
	menu.weapon_description.resized.connect(fit_descriptions)
	refresh()

func _add_placeholders(grid: GridContainer, count: int) -> void:
	for i in count:
		var slot := Panel.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.modulate.a = 0.45
		slot.add_theme_stylebox_override("panel", UITheme.box(UITheme.palette.button, UITheme.palette.muted, 16, 2))
		var label := Label.new()
		label.text = "?"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 24)
		slot.add_child(label)
		grid.add_child(slot)

func content_rect() -> Rect2:
	var margin := menu.size.x * 0.025
	return Rect2(margin, 120, menu.size.x - margin * 2, maxf(300, menu.size.y - 250))

func player_slot_rects(count: int, weapon_mode: bool = false) -> Array[Rect2]:
	var area := content_rect()
	var column := Rect2(area.position + Vector2(area.size.x * 0.36, 0), Vector2(area.size.x * 0.28, area.size.y))
	if weapon_mode:
		var roster := weapon_roster_rect()
		column = Rect2(Vector2(area.position.x, roster.position.y), Vector2(area.size.x * 0.21, roster.size.y))
	var result: Array[Rect2] = []
	count = clampi(count, 1, 4)
	var height := (column.size.y - (count - 1) * 12) / count
	for i in count: result.append(Rect2(column.position + Vector2(0, i * (height + 12)), Vector2(column.size.x, height)))
	return result

func weapon_roster_rect() -> Rect2:
	var area := content_rect()
	var gap := clampf(menu.size.x * 0.009, 8, 18)
	var available := Rect2(area.position + Vector2(area.size.x * 0.45, 0), Vector2(area.size.x * 0.55, area.size.y))
	return _grid_rect(available, 8, 5, gap)

func refresh() -> void:
	if not is_instance_valid(menu) or menu.transitioning: return
	body.size = menu.size
	var area := content_rect()
	var gap := clampf(menu.size.x * 0.009, 8, 18)
	var back_width := clampf(menu.size.x * 0.115, 140, 220)
	menu.heading.position = Vector2(area.position.x + back_width + 16, 25)
	menu.heading.size = Vector2(area.size.x - (back_width + 16) * 2, 70)
	menu.heading.add_theme_font_size_override("font_size", clampi(int(menu.size.y * 0.045), 30, 48))
	back.position = Vector2(area.position.x, 30)
	back.size = Vector2(back_width, 60)
	var character: bool = menu.selection_mode == menu.SelectionMode.CHARACTER
	_place(menu.player_panel, player_slot_rects(1, not character)[0])
	if character:
		_grid(menu.players_container, Rect2(area.position, Vector2(area.size.x * 0.33, area.size.y)), 3, 5, gap)
		_grid(right_players, Rect2(area.position + Vector2(area.size.x * 0.67, 0), Vector2(area.size.x * 0.33, area.size.y)), 3, 5, gap)
	else:
		var roster := weapon_roster_rect()
		_place(menu.weapon_panel, Rect2(Vector2(area.position.x + area.size.x * 0.225, roster.position.y), Vector2(area.size.x * 0.21, roster.size.y)))
		_place(weapon_scroll,roster)
		var side := floorf((roster.size.x-18.0-gap*7.0)/8.0)
		var rows := ceili(menu.weapons_container.get_child_count()/8.0)
		menu.weapons_container.add_theme_constant_override("h_separation",int(gap))
		menu.weapons_container.add_theme_constant_override("v_separation",int(gap))
		for card in menu.weapons_container.get_children(): card.custom_minimum_size = Vector2.ONE*side
		menu.weapons_container.custom_minimum_size = Vector2(side*8+gap*7,side*rows+gap*(rows-1))
	_detail(menu.player_panel, menu.player_icon, menu.player_name, menu.player_title, menu.player_description)
	_detail(menu.weapon_panel, menu.weapon_icon, menu.weapon_name, menu.weapon_title, menu.weapon_description)
	fit_descriptions.call_deferred()

func fit_descriptions() -> void:
	for description in [menu.player_description, menu.weapon_description]:
		for font_size in range(20, 13, -1):
			for key in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]: description.add_theme_font_size_override(key, font_size)
			if description.get_content_height() <= description.size.y: break

func refresh_player_detail() -> void:
	_detail(menu.player_panel, menu.player_icon, menu.player_name, menu.player_title, menu.player_description)
	fit_descriptions.call_deferred()

func _place(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size

func _grid(grid: GridContainer, area: Rect2, columns: int, rows: int, gap: float) -> void:
	var rect := _grid_rect(area, columns, rows, gap)
	var side := (rect.size.x - gap * (columns - 1)) / columns
	grid.add_theme_constant_override("h_separation", int(gap))
	grid.add_theme_constant_override("v_separation", int(gap))
	for card in grid.get_children(): card.custom_minimum_size = Vector2.ONE * side
	_place(grid, rect)

func _grid_rect(area: Rect2, columns: int, rows: int, gap: float) -> Rect2:
	var side := floorf(minf((area.size.x - gap * (columns - 1)) / columns, (area.size.y - gap * (rows - 1)) / rows))
	var extent := Vector2(side * columns + gap * (columns - 1), side * rows + gap * (rows - 1))
	return Rect2(area.position + (area.size - extent) * 0.5, extent)

func _detail(panel: Control, icon: TextureRect, title: Label, subtitle: Label, description: RichTextLabel) -> void:
	var margin: MarginContainer = panel.get_node("MarginContainer")
	for key in ["margin_left", "margin_right", "margin_top", "margin_bottom"]: margin.add_theme_constant_override(key, 18)
	var width := panel.size.x - 36
	var height := panel.size.y - 36
	var portrait := minf(180, height * 0.25)
	for node in [icon, title, subtitle, description]:
		node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		node.custom_minimum_size = Vector2.ZERO
	icon.position = Vector2((width - portrait) * 0.5, 0)
	icon.size = Vector2.ONE * portrait
	title.position = Vector2(0, portrait + 12)
	title.size = Vector2(width, 65)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", clampi(int(width * 0.095), 22, 32))
	subtitle.position = Vector2(0, portrait + 80)
	subtitle.size = Vector2(width, 50)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 20)
	description.position = Vector2(0, portrait + 140)
	description.size = Vector2(width, maxf(80, height - portrait - 140))
	description.scroll_active = false
	if height < 520:
		# Preserve readable descriptions when cards follow the shorter roster.
		portrait = minf(80, width * 0.3)
		icon.position = Vector2.ZERO
		icon.size = Vector2.ONE * portrait
		title.position = Vector2(portrait + 12, 0)
		title.size = Vector2(width - portrait - 12, 60)
		title.add_theme_font_size_override("font_size", 22)
		subtitle.position = Vector2(portrait + 12, 62)
		subtitle.size = Vector2(width - portrait - 12, 50)
		subtitle.add_theme_font_size_override("font_size", 16)
		description.position = Vector2(0, 120)
		description.size = Vector2(width, maxf(80, height - 120))
	for key in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]: description.add_theme_font_size_override(key, 20)
