extends CanvasLayer

var pending: Array[Dictionary] = []
var active := false
var elapsed := 0.0
var was_paused := false
var revealed := false
var screen: Control
var stage: Control
var icon: TextureRect
var name_label: Label
var requirement_label: Label
var details: RichTextLabel
var details_panel: Panel
var continue_button: Button
var sparks: CPUParticles2D
var current: Dictionary

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	screen = Control.new()
	screen.name = "UnlockScreen"
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.06,0.04,0.03,0.86)
	screen.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage = Control.new()
	stage.size = Vector2(1920,1080)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(stage)
	var title := _label("UNLOCKED!",Vector2(410,95),Vector2(1100,90),62)
	stage.add_child(title)
	icon = TextureRect.new()
	icon.size = Vector2(320,320)
	icon.pivot_offset = icon.size*0.5
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(icon)
	name_label = _label("",Vector2(560,650),Vector2(800,75),48)
	stage.add_child(name_label)
	requirement_label = _label("",Vector2(500,740),Vector2(920,105),28)
	requirement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage.add_child(requirement_label)
	details_panel = Panel.new()
	details_panel.position = Vector2(1000,245)
	details_panel.size = Vector2(640,520)
	details_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	details_panel.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,UITheme.palette.outline,24,3))
	stage.add_child(details_panel)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.position = Vector2(26,24)
	details.size = Vector2(588,472)
	details.add_theme_font_size_override("normal_font_size",28)
	details.add_theme_color_override("default_color",UITheme.palette.text)
	details_panel.add_child(details)
	continue_button = Button.new()
	continue_button.text = "CONTINUE"
	continue_button.position = Vector2(710,885)
	continue_button.size = Vector2(500,90)
	continue_button.add_theme_font_size_override("font_size",40)
	stage.add_child(continue_button)
	continue_button.pressed.connect(_continue)
	sparks = CPUParticles2D.new()
	sparks.emitting = false
	sparks.one_shot = true
	sparks.amount = 48
	sparks.lifetime = 0.65
	sparks.explosiveness = 1.0
	sparks.spread = 20
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_DIRECTED_POINTS
	var burst_points := PackedVector2Array()
	var burst_normals := PackedVector2Array()
	for i in 48:
		var normal := Vector2.from_angle(TAU*i/48.0)
		burst_points.append(normal*210.0)
		burst_normals.append(normal)
	sparks.emission_points = burst_points
	sparks.emission_normals = burst_normals
	sparks.initial_velocity_min = 180
	sparks.initial_velocity_max = 450
	sparks.gravity = Vector2.ZERO
	sparks.scale_amount_min = 4
	sparks.scale_amount_max = 9
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("fff7e6"),Color("f6bf48"),Color(0.96,0.7,0.2,0)])
	sparks.color_ramp = gradient
	stage.add_child(sparks)
	stage.move_child(sparks,1)
	Progression.unlock_earned.connect(_on_unlock_earned)
	MenuInput.menus.push_front(screen)
	screen.hide()

func _label(text: String, at: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size = dimensions
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",UITheme.palette.hud_text)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _on_unlock_earned(reward: String) -> void:
	if Progression.get_meta("suppress_unlock_presentation",false): return
	var arena = get_parent()
	for achievement in Progression.achievements:
		if achievement.reward_label != reward: continue
		for id in achievement.reward_characters:
			for character in arena.selection_panel.player_list:
				if character.unlock_id == id: enqueue(character,achievement.requirement)
		for id in achievement.reward_weapons:
			for weapon in arena.shop_panel.shop_items:
				if weapon is ItemWeapon and weapon.unlock_id == id and weapon.item_tier == 0:
					enqueue(weapon,achievement.requirement)
		return

func enqueue(resource: Resource, requirement: String) -> void:
	pending.append({"resource":resource,"requirement":requirement})

func _begin_next() -> void:
	current = pending.pop_front()
	elapsed = 0
	revealed = false
	active = true
	SoundManager.play_sound(SoundManager.Sound.UNLOCK_SEQUENCE_START)
	var arena = get_parent()
	arena.unlock_modal_active = true
	Global.game_paused = true
	arena.coocking_player.stream_paused = true
	var resource: Resource = current.resource
	icon.texture = resource.icon if resource is UnitStats else resource.item_icon
	if resource is UnitStats:
		var character_scene: PackedScene = Global.available_players.get(resource.name)
		if character_scene:
			var visual := character_scene.instantiate()
			icon.texture = visual.get_node("Visuals/Sprite").texture
			visual.free()
	if icon.texture:
		var used := icon.texture.get_image().get_used_rect()
		if used.has_area():
			var cropped := AtlasTexture.new()
			cropped.atlas = icon.texture
			cropped.region = used
			icon.texture = cropped
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/locked_silhouette.gdshader")
	material.set_shader_parameter("silhouette_color",UITheme.palette.hud_text.darkened(0.8))
	icon.material = material
	name_label.text = ""
	requirement_label.text = ""
	details_panel.hide()
	details_panel.modulate.a = 0
	continue_button.hide()
	continue_button.disabled = true
	sparks.emitting = false
	screen.show()

func _process(delta: float) -> void:
	if not active:
		if pending.is_empty() or get_parent().defeat_in_progress: return
		was_paused = Global.game_paused
		_begin_next()
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := minf(viewport_size.x/1920.0,viewport_size.y/1080.0)
	stage.scale = Vector2.ONE*factor
	stage.position = (viewport_size-stage.size*factor)*0.5
	elapsed += delta/maxf(0.01,Engine.time_scale)
	var slide := smoothstep(0,1,clampf((elapsed-2.1)/0.7,0,1))
	icon.position = Vector2(800,260).lerp(Vector2(360,285),slide)
	name_label.position.x = lerpf(560,120,slide)
	requirement_label.position.x = lerpf(500,60,slide)
	if elapsed < 1.25:
		icon.scale = Vector2.ONE * lerpf(0.8,1.15,minf(1,elapsed/1.25))
		icon.rotation = sin(elapsed*65.0)*0.045 if elapsed > 0.65 else 0.0
	else:
		if not revealed:
			revealed = true
			icon.material = null
			sparks.position = icon.position+icon.size*0.5
			sparks.restart()
			sparks.emitting = true
			SoundManager.play_sound(SoundManager.Sound.UNLOCK_REVEAL)
			var resource: Resource = current.resource
			name_label.text = resource.name if resource is UnitStats else resource.item_name
			requirement_label.text = current.requirement
			if resource is UnitStats:
				details.text = _character_details(resource)
			else:
				details.text = UITheme.rich_text(resource.get_description())
		var bounce := sin((elapsed-1.25)*22.0)*exp(-(elapsed-1.25)*5.0)*0.22
		icon.scale = Vector2(1.22+bounce,1.22-bounce)
		icon.rotation = 0
	if elapsed >= 2.1:
		details_panel.show()
		details_panel.modulate.a = slide
	if elapsed >= 3.0 and continue_button.disabled:
		SoundManager.play_sound(SoundManager.Sound.UNLOCK_SEQUENCE_END)
		continue_button.disabled = false
		continue_button.show()
		if MenuInput.gamepad_active: continue_button.grab_focus()

func _continue() -> void:
	if not active or elapsed < 3.0: return
	if not pending.is_empty():
		_begin_next()
		return
	active = false
	screen.hide()
	var arena = get_parent()
	arena.unlock_modal_active = false
	Global.game_paused = was_paused or not arena.wave_active
	arena.coocking_player.stream_paused = Global.game_paused

func _character_details(resource: UnitStats) -> String:
	var preview := resource.get_passive_preview()
	var lines: PackedStringArray = ["[b]CHARACTER[/b]"]
	for stat in get_parent().selection_panel.DISPLAY_STATS:
		var value: float = preview.get(stat[0])
		if is_zero_approx(value) and stat[0] not in ["health","speed"]: continue
		lines.append("%s: %s%s" % [stat[1],ItemWeapon.format_number(value),"%" if stat[2] else ""])
	lines.append("\n[b]PASSIVES[/b]")
	for passive in resource.character_passives:
		if passive: lines.append("- " + passive.get_description())
	if resource.character_passives.is_empty(): lines.append("None")
	return "\n".join(lines)
