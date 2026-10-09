extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func luminance(color: Color) -> float:
	var linear := color.srgb_to_linear()
	return linear.r * 0.2126 + linear.g * 0.7152 + linear.b * 0.0722

func contrast(a: Color, b: Color) -> float:
	return (maxf(luminance(a), luminance(b)) + 0.05) / (minf(luminance(a), luminance(b)) + 0.05)

func verify() -> void:
	load("res://tests/progression_fixture.gd").prepare(root)
	var themes = root.get_node("UITheme")
	var arena = load("res://scenes/arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena._on_start_panel_on_play_pressed()
	for frame in 4: await process_frame
	var button = arena.selection_panel.get_node("MarginContainer/VBoxContainer/Label/CustomButtonExit")
	var initial_rect: Rect2 = button.get_rect()
	for id in themes.PALETTES:
		themes.set_palette(id)
		for frame in 3: await process_frame
		assert(contrast(themes.palette.text, themes.palette.surface) >= 4.5, id + " text contrast")
		assert(contrast(themes.palette.positive, themes.palette.surface) >= 4.5, id + " stat contrast")
		for fill in [themes.palette.button, themes.palette.primary, themes.palette.danger]:
			assert(contrast(themes.palette.text, fill) >= 3.0, id + " large button text contrast")
		var borders: Array = []
		for tier in 4:
			assert(not borders.has(themes.tier_style(tier).border_color))
			borders.append(themes.tier_style(tier).border_color)
		for variation in ["Button", "PrimaryButton", "DangerButton"]:
			var normal = themes.ui_theme.get_stylebox("normal", variation)
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
				assert(themes.ui_theme.has_stylebox(state, variation), "Missing button state")
				var style = themes.ui_theme.get_stylebox(state, variation)
				assert(style.corner_radius_top_left == normal.corner_radius_top_left)
				assert(style.content_margin_left == normal.content_margin_left and style.content_margin_top == normal.content_margin_top)
		assert(button.get_rect().is_equal_approx(initial_rect), "Changing palette must not change layout")
		var card = arena.selection_panel.players_container.get_child(4)
		card.grab_focus()
		assert(card.get_theme_stylebox("focus").border_color == themes.palette.focus)
		assert(card.get_theme_stylebox("normal").bg_color == card.get_theme_stylebox("hover").bg_color, "Controller focus must change the actual base fill")
		card.button_pressed = true
		assert(card.get_theme_stylebox("pressed").bg_color == card.get_theme_stylebox("hover_pressed").bg_color, "Focused selected slot must preserve pressed hover")
		card.button_pressed = false
		button.grab_focus()
		assert(not card.has_theme_stylebox_override("focus"), "Leaving focus must restore the shared focus style")
		assert(card.get_theme_stylebox("pressed").border_width_left >= 3)
		assert(card.locked == false)
		assert(arena.selection_panel.player_icon.material == null)
		# Deferred styling must tolerate UI controls removed in the same frame.
		var transient := Label.new()
		arena.selection_panel.add_child(transient)
		transient.free()
		await process_frame
	themes.set_palette("cream")
	print("PASS: three palettes, readable contrast, six complete states, stable margins/layout, distinct rarity, controller focus and deferred deletion")
	arena.queue_free()
	await process_frame
	quit()
