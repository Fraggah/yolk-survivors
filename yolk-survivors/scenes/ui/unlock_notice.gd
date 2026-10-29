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
var icon_start: Vector2
var name_start: Vector2
var requirement_start: Vector2
var current: Dictionary

func _ready() -> void:
	continue_button=get_node("UnlockScreen/Viewport/Stage/Button6")
	details=get_node("UnlockScreen/Viewport/Stage/Panel5/RichTextLabel0")
	details_panel=get_node("UnlockScreen/Viewport/Stage/Panel5")
	icon=get_node("UnlockScreen/Viewport/Stage/TextureRect2")
	name_label=get_node("UnlockScreen/Viewport/Stage/Label3")
	requirement_label=get_node("UnlockScreen/Viewport/Stage/Label4")
	screen=get_node("UnlockScreen")
	sparks=get_node("UnlockScreen/Viewport/Stage/CPUParticles2D1")
	stage=get_node("UnlockScreen/Viewport/Stage")
	icon_start=icon.position
	name_start=name_label.position
	requirement_start=requirement_label.position
	Progression.unlock_earned.connect(_on_unlock_earned)
	MenuInput.menus.push_front(screen)

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
	var silhouette_material := ShaderMaterial.new()
	silhouette_material.shader = preload("res://shaders/locked_silhouette.gdshader")
	silhouette_material.set_shader_parameter("silhouette_color",UITheme.palette.hud_text.darkened(0.8))
	icon.material = silhouette_material
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
	elapsed += delta/maxf(0.01,Engine.time_scale)
	var slide := smoothstep(0,1,clampf((elapsed-2.1)/0.7,0,1))
	icon.position = icon_start.lerp(stage.get_node("IconEnd").position,slide)
	name_label.position = name_start.lerp(stage.get_node("NameEnd").position,slide)
	requirement_label.position = requirement_start.lerp(stage.get_node("RequirementEnd").position,slide)
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
