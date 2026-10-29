extends Node
## Selection only. Uses the normal rosters, their transition, and one difficulty menu.
@export_range(0.2, 2.0, 0.05) var join_hold_seconds := 0.65
@export_multiline var solo_notice_text: String = "Para jugar solo, desactivá Coop Game.\nO esperá a que se una otro jugador."
const Rows = preload("res://scenes/coop/selection_player_rows.tscn")
const Markers = preload("res://scenes/coop/selection_roster_markers.tscn")
var arena
var coop
var enabled := false
var mode := "characters"
var transitioning := false
var holds: Dictionary = {}
var accept_latches: Dictionary = {}
var repeat_times: Dictionary = {}
var character_rows: Control
var weapon_character_rows: Control
var weapon_rows: Control
var switch: Button

func setup(context) -> void:
	arena=context
	coop=arena.coop
	coop.selection_flow=self
	switch=arena.selection_panel.get_node("CoopGame")
	character_rows=_install_rows(arena.selection_panel.player_panel)
	weapon_character_rows=_install_rows(arena.weapon_selection_panel.player_panel)
	weapon_rows=_install_rows(arena.weapon_selection_panel.weapon_panel)
	switch.toggled.connect(_switch_toggled)
	for panel in [arena.selection_panel,arena.weapon_selection_panel]:
		panel.visibility_changed.connect(refresh)
		panel.resized.connect(refresh)
	for card in _roster_cards(false)+_roster_cards(true):
		var markers=card.get_node("CoopMarkers")
		for i in 4: markers.get_child(i).add_theme_color_override("font_color",coop.COLORS[i])
		card.mouse_entered.connect(_mouse_preview.bind(card))
	Input.joy_connection_changed.connect(_device_changed)
	UITheme.palette_changed.connect(_refresh_palette)
	refresh()

func _install_rows(panel: Control) -> Control:
	var rows=panel.get_node("CoopRows")
	rows.hide()
	for i in 4: rows.get_node("Rows").get_child(i).get_node("Margin/Content/Header/Confirm").pressed.connect(_mouse_confirm.bind(i))
	return rows

func _switch_toggled(value: bool) -> void:
	if value: enable(MenuInput.last_device)
	else: disable()

func enable(device: int) -> void:
	if coop.active or enabled: return
	enabled=true
	MenuInput.gamepad_active=true
	Input.mouse_mode=Input.MOUSE_MODE_HIDDEN
	mode="characters"
	coop.mode=mode
	coop.sessions.clear()
	holds.clear(); accept_latches.clear(); repeat_times.clear()
	if not switch.button_pressed:
		switch.set_pressed_no_signal(true)
		switch.sync_state()
	var focus=get_viewport().gui_get_focus_owner()
	if focus: focus.release_focus()
	MenuInput._sync_coop_mouse_lock()
	_join_device(device)
	var event: InputEvent=MenuInput.last_input_event
	if _is_accept(event) and event.is_pressed(): accept_latches[device]=true
	refresh()

func disable() -> void:
	if coop and coop.active: return
	enabled=false
	MenuInput._sync_coop_mouse_lock()
	MenuInput._set_gamepad_active(not MenuInput.connected_gamepads.is_empty())
	Input.mouse_mode=Input.MOUSE_MODE_HIDDEN if MenuInput.gamepad_active else Input.MOUSE_MODE_VISIBLE
	transitioning=false
	holds.clear(); accept_latches.clear(); repeat_times.clear()
	if coop and not coop.sessions.is_empty():
		Global.main_player_selected=coop.sessions[0].character
		Global.main_weapon_selected=coop.sessions[0].weapon
		coop.sessions.clear()
	if coop: coop.mode=""
	if is_instance_valid(switch):
		if switch.button_pressed:
			switch.set_pressed_no_signal(false)
			switch.sync_state()
	refresh()
	if arena and arena.selection_panel.is_visible_in_tree(): arena.selection_panel._refresh_selection_info()

func handles_input() -> bool:
	return enabled and not coop.active and (arena.selection_panel.is_visible_in_tree() or arena.weapon_selection_panel.is_visible_in_tree() or arena.level_panel.is_visible_in_tree())

func handles_panel(panel) -> bool:
	return enabled and not coop.active and panel in [arena.selection_panel,arena.weapon_selection_panel]

func _session(device: int):
	for session in coop.sessions:
		if session.device==device: return session
	return null

func _join_device(device: int):
	if mode!="characters" or coop.sessions.size()>=4 or _session(device): return null
	var readiness: Array=[]
	for other in coop.sessions: readiness.append(other.ready)
	var session=coop.join(device)
	if not session: return null
	for i in readiness.size(): coop.sessions[i].ready=readiness[i]
	var choices=_choices(false)
	session.character=Global.main_player_selected if device==coop.sessions[0].device and Global.main_player_selected and choices.has(Global.main_player_selected) else choices[0]
	session.cursor=choices.find(session.character)
	_set_default_weapon(session)
	session.ready=false
	refresh()
	return session

func _choices(weapons: bool) -> Array:
	var result: Array=[]
	for item in arena.weapon_selection_panel.weapons_list if weapons else arena.selection_panel.player_list:
		if weapons:
			if Global.is_valid_starting_weapon(item) and Progression.is_weapon_unlocked(item): result.append(item)
		elif Progression.is_character_unlocked(item): result.append(item)
	return result

func _set_default_weapon(session) -> void:
	var spatula=preload("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")
	if _choices(true).has(spatula) and session.character.can_use_weapon(spatula):
		session.weapon=spatula
		return
	if Global.is_valid_starting_weapon(session.weapon) and session.character.can_use_weapon(session.weapon) and Progression.is_weapon_unlocked(session.weapon): return
	for weapon in _choices(true):
		if session.character.can_use_weapon(weapon): session.weapon=weapon; return

func choose_character(player: UnitStats, commit: bool = false) -> void:
	var session=_session(-1)
	if not session or mode!="characters" or session.ready or transitioning or not Progression.is_character_unlocked(player): return
	session.character=player
	session.cursor=_choices(false).find(player)
	_set_default_weapon(session)
	refresh()
	if commit: confirm(session)

func choose_weapon(weapon: ItemWeapon, commit: bool = false) -> void:
	var session=_session(-1)
	if not session or mode!="weapons" or session.ready or transitioning: return
	if not Global.is_valid_starting_weapon(weapon) or not Progression.is_weapon_unlocked(weapon):
		SoundManager.play_sound(SoundManager.Sound.SELECTION_INVALID)
		return
	session.weapon=weapon
	session.cursor=_choices(true).find(weapon)
	refresh()
	if commit: confirm(session)

func _mouse_confirm(slot: int) -> void:
	if enabled: return
	if slot<coop.sessions.size() and coop.sessions[slot].device<0: confirm(coop.sessions[slot])

func confirm(session) -> void:
	if transitioning or session.disconnected or not handles_input(): return
	if mode=="weapons" and (not Global.is_valid_starting_weapon(session.weapon) or not Progression.is_weapon_unlocked(session.weapon) or not session.character.can_use_weapon(session.weapon)):
		SoundManager.play_sound(SoundManager.Sound.SELECTION_INVALID)
		return
	session.ready=not session.ready
	SoundManager.play_sound(SoundManager.Sound.SELECTION_ACCEPT)
	refresh()
	if coop.sessions.size()>=2 and holds.is_empty() and coop.sessions.all(func(s): return s.ready and not s.disconnected):
		if mode=="characters": _to_weapons()
		else: _to_difficulty()

func _to_weapons() -> void:
	if coop.sessions.size()<2: return
	transitioning=true
	holds.clear()
	await arena.selection_panel.animate_character_to_weapons()
	if not enabled or not is_instance_valid(arena): return
	mode="weapons"
	coop.mode=mode
	for session in coop.sessions:
		session.ready=false
		session.cursor=_choices(true).find(session.weapon)
	arena.selection_panel.hide()
	arena.weapon_selection_panel.show()
	arena.weapon_selection_panel.reveal_weapon_roster()
	transitioning=false
	refresh()

func _to_difficulty() -> void:
	if coop.sessions.size()<2: return
	mode="difficulty"
	coop.mode=mode
	holds.clear()
	arena.weapon_selection_panel.hide()
	arena.level_panel.show()
	_focus_difficulty.call_deferred()
	Global.main_player_selected=coop.sessions[0].character
	Global.main_weapon_selected=coop.sessions[0].weapon

func back_to_weapons() -> void:
	mode="weapons"
	coop.mode=mode
	for session in coop.sessions: session.ready=false
	arena.level_panel.hide()
	arena.weapon_selection_panel.show()
	refresh()

func back_to_characters() -> void:
	if transitioning: return
	mode="characters"
	coop.mode=mode
	for session in coop.sessions:
		session.ready=false
		session.cursor=_choices(false).find(session.character)
	arena.weapon_selection_panel.hide()
	arena.selection_panel.show()
	refresh()

func start_difficulty(level: int) -> void:
	if not enabled or mode!="difficulty" or coop.sessions.size()<2: return
	coop.start_run(level)

func refresh() -> void:
	if not arena or not is_instance_valid(character_rows): return
	for pair in [[character_rows,arena.selection_panel.player_panel],[weapon_character_rows,arena.weapon_selection_panel.player_panel],[weapon_rows,arena.weapon_selection_panel.weapon_panel]]:
		pair[0].visible=enabled
		pair[1].get_node("MarginContainer").visible=not enabled
	switch.visible=arena.selection_panel.selection_mode==arena.selection_panel.SelectionMode.CHARACTER
	for rows in [character_rows,weapon_character_rows,weapon_rows]:
		for i in 4: _render_card(rows.get_node("Rows").get_child(i),i,rows==weapon_rows,rows==weapon_character_rows)
	for weapons in [false,true]:
		for card in _roster_cards(weapons):
			var markers=card.get_node_or_null("CoopMarkers")
			if not markers: continue
			markers.visible=enabled
			if enabled:
				card.focus_mode=Control.FOCUS_NONE
				card.mouse_filter=Control.MOUSE_FILTER_IGNORE
				card.set_pressed_no_signal(false)
				card.modulate.a=1.0
			else:
				card.mouse_filter=Control.MOUSE_FILTER_STOP
			for i in 4:
				var selected: bool=enabled and i<coop.sessions.size() and card.get_meta("selection_data")== (coop.sessions[i].weapon if weapons else coop.sessions[i].character)
				markers.get_child(i).visible=selected
				var incompatible: bool=selected and weapons and not coop.sessions[i].character.can_use_weapon(card.get_meta("selection_data"))
				markers.get_child(i).text="P%d%s"%[i+1," ✕" if incompatible else ""]
			var colors: Array[Color]=[]
			for i in 4:
				if markers.get_child(i).visible: colors.append(coop.COLORS[i])
			card.set_coop_highlights(colors)

func _refresh_palette() -> void:
	for card in _roster_cards(false)+_roster_cards(true): card.set_coop_highlights(card.coop_highlights,true)
	refresh()

func _mouse_preview(card: Control) -> void:
	if enabled: return
	if not handles_input() or transitioning: return
	var item=card.get_meta("selection_data")
	if mode=="characters" and item is UnitStats: choose_character(item)
	elif mode=="weapons" and item is ItemWeapon: choose_weapon(item)

func _render_card(card: Control, slot: int, weapons: bool, character_in_weapons: bool) -> void:
	var content=card.get_node("Margin/Content")
	var icon: TextureRect=content.get_node("Header/Icon")
	var name_label: Label=content.get_node("Header/Name")
	var confirm_button: Button=content.get_node("Header/Confirm")
	var description: RichTextLabel=content.get_node("Description")
	var progress: ProgressBar=content.get_node("Hold")
	progress.add_theme_stylebox_override("background",UITheme.box(UITheme.palette.surface.lerp(coop.COLORS[slot],0.2),coop.COLORS[slot],8,1))
	progress.add_theme_stylebox_override("fill",UITheme.box(coop.COLORS[slot],Color.TRANSPARENT,8,0))
	var solo_notice: PanelContainer=content.get_node("SoloNotice")
	solo_notice.get_node("Margin/Message").text=solo_notice_text
	var joined: bool=slot<coop.sessions.size()
	solo_notice.visible=enabled and mode=="characters" and coop.sessions.size()==1 and joined and coop.sessions[slot].ready
	if solo_notice.visible: solo_notice.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.inset,UITheme.palette.accent,10,2))
	icon.visible=joined
	confirm_button.visible=joined and not character_in_weapons
	progress.visible=not joined and not weapons and not character_in_weapons
	card.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,coop.COLORS[slot] if joined else UITheme.palette.outline))
	if not joined:
		name_label.text="P%d"%(slot+1)
		description.text="Hold A / X or Enter to join" if mode=="characters" else "Sin jugador"
		var held:=0.0
		if slot==coop.sessions.size():
			for value in holds.values(): held=maxf(held,float(value)/join_hold_seconds)
		progress.value=held
		return
	var session=coop.sessions[slot]
	icon.texture=session.weapon.item_icon if weapons else session.character.icon
	name_label.text="P%d · %s"%[slot+1,session.weapon.item_name if weapons else session.character.name]
	confirm_button.text="✓" if session.ready else "Ready"
	var incompatible: bool=weapons and not session.character.can_use_weapon(session.weapon)
	confirm_button.disabled=session.disconnected or transitioning or incompatible
	if session.disconnected:
		description.text="Mando desconectado"
	elif character_in_weapons:
		description.text="Personaje de P%d"%(slot+1)
	elif session.ready:
		description.text="Personaje confirmado" if solo_notice.visible else "LISTO · esperando al equipo"
	elif incompatible:
		description.text="✕ No compatible con este personaje"
	elif weapons:
		var stats: UnitStats=session.character.get_passive_preview()
		description.text=UITheme.rich_text("Damage: %s\nCooldown: %s s\nRange: %s"%[session.weapon.get_damage_description(stats),ItemWeapon.format_number(session.weapon.get_effective_cooldown(stats)),ItemWeapon.format_number(session.weapon.get_effective_range(stats))])
	else:
		var lines=arena.selection_panel.get_character_description(session.character).split("\n")
		description.text="\n".join(lines.slice(0,4))

func _roster_cards(weapons: bool) -> Array:
	var result: Array=[]
	var nodes=arena.weapon_selection_panel.weapons_container.get_children() if weapons else arena.selection_panel.get_player_cards()
	for node in nodes:
		if node.has_meta("selection_data"): result.append(node)
	return result

func _is_accept(event: InputEvent) -> bool:
	return event != null and ((event is InputEventJoypadButton and event.button_index==JOY_BUTTON_A) or (event is InputEventKey and event.physical_keycode in [KEY_ENTER,KEY_SPACE]))

func _input(event: InputEvent) -> void:
	if not arena or coop.active: return
	if event is InputEventKey and event.echo: return
	var device: int=event.device if event is InputEventJoypadButton or event is InputEventJoypadMotion else -1
	if arena.selection_panel.is_visible_in_tree() and not transitioning:
		if (event is InputEventKey and event.pressed and event.physical_keycode==KEY_TAB) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_Y):
			MenuInput.last_device=device
			MenuInput.last_input_event=event
			switch.button_pressed=not enabled
			get_viewport().set_input_as_handled()
			return
	if not handles_input(): return
	if mode=="difficulty":
		get_viewport().set_input_as_handled()
		if coop.sessions.is_empty() or device!=coop.sessions[0].device: return
		if _is_accept(event) and event.is_pressed():
			var focused=get_viewport().gui_get_focus_owner()
			if focused is Button and arena.level_panel.is_ancestor_of(focused): focused.pressed.emit()
		elif (event is InputEventKey and event.is_pressed() and event.physical_keycode==KEY_ESCAPE) or (event is InputEventJoypadButton and event.is_pressed() and event.button_index==JOY_BUTTON_B):
			back_to_weapons()
		return
	if _is_accept(event):
		if not event.is_pressed():
			holds.erase(device)
			accept_latches.erase(device)
		elif not transitioning and not accept_latches.has(device):
			var session=_session(device)
			if session:
				accept_latches[device]=true
				confirm(session)
			elif mode=="characters" and coop.sessions.size()<4: holds[device]=0.0
		get_viewport().set_input_as_handled()
		return
	var cancel: bool=(event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_B)
	if cancel:
		var session=_session(device)
		if session and not transitioning:
			if session.ready: session.ready=false; refresh()
			elif mode=="weapons": back_to_characters()
			elif session.slot>0:
				coop.sessions.erase(session)
				for i in coop.sessions.size(): coop.sessions[i].slot=i
				refresh()
			else:
				disable()
				arena.selection_panel.hide()
				arena.start_panel.show()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey:
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not handles_input() or transitioning: return
	if mode=="difficulty":
		var session=coop.sessions[0]
		var direction: Vector2=session.poll_movement()
		repeat_times[session.device]=maxf(0,float(repeat_times.get(session.device,0))-delta)
		if direction.length()<0.5:
			repeat_times[session.device]=0.0
		elif repeat_times[session.device]<=0:
			repeat_times[session.device]=0.18
			MenuInput.move_focus(Vector2(signf(direction.x),0) if absf(direction.x)>absf(direction.y) else Vector2(0,signf(direction.y)))
		MenuInput._sync_focus_visual()
		return
	advance_holds(delta)
	for session in coop.sessions:
		if session.ready or session.disconnected: continue
		var direction: Vector2=session.poll_movement()
		var columns: int=8 if mode=="weapons" else 3
		var step: int=(1 if direction.x>0 else -1) if absf(direction.x)>.5 else (columns if direction.y>0 else -columns) if absf(direction.y)>.5 else 0
		repeat_times[session.device]=maxf(0,float(repeat_times.get(session.device,0))-delta)
		if step==0: repeat_times[session.device]=0.0; continue
		if repeat_times[session.device]>0: continue
		repeat_times[session.device]=0.18
		move_cursor(session,step)

func move_cursor(session, step: int) -> void:
	if step==0 or session.ready or session.disconnected or transitioning: return
	var weapons: bool=mode=="weapons"
	var direction:=Vector2(signi(step),0) if absi(step)<(8 if weapons else 3) else Vector2(0,signi(step))
	var before=session.weapon if weapons else session.character
	var cards:=_roster_cards(weapons)
	var origin: Control=null
	for card in cards:
		if card.get_meta("selection_data")==before: origin=card; break
	if not origin: return
	var choices:=_choices(weapons)
	var selected: Control=null
	var best_score:=INF
	for card in cards:
		var candidate_data=card.get_meta("selection_data")
		if card==origin or not choices.has(candidate_data): continue
		var offset: Vector2=card.get_global_rect().get_center()-origin.get_global_rect().get_center()
		var forward:=offset.dot(direction)
		if forward<=1: continue
		var sideways:=absf(offset.cross(direction))
		# Prefer the same visual row/column, including gaps for locked cards.
		var score:=forward+sideways*4.0
		if score<best_score:
			best_score=score
			selected=card
	if not selected: return
	var item=selected.get_meta("selection_data")
	session.cursor=choices.find(item)
	if weapons:
		session.weapon=item
		arena.weapon_selection_panel.roster_layout.weapon_scroll.ensure_control_visible(selected)
	else:
		session.character=item
		_set_default_weapon(session)
	SoundManager.play_sound(SoundManager.Sound.SELECTION_HOVER)
	refresh()

func advance_holds(delta: float) -> void:
	if mode!="characters": holds.clear(); return
	for device in holds.keys():
		holds[device]+=maxf(0,delta)
		if holds[device]>=join_hold_seconds:
			holds.erase(device)
			_join_device(device)
			accept_latches[device]=true
	if not holds.is_empty(): refresh()

func _device_changed(device: int, connected: bool) -> void:
	if not enabled or coop.active: return
	if not connected: holds.erase(device); accept_latches.erase(device)
	var session=_session(device)
	if session: session.disconnected=not connected; session.ready=false
	refresh()

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		holds.clear()
		accept_latches.clear()

func _focus_difficulty() -> void:
	if not enabled or mode!="difficulty": return
	MenuInput.gamepad_active=true
	MenuInput._controls(arena.level_panel)
	arena.level_panel.buttons[0].grab_focus()
	arena.level_panel._show_difficulty(0)
	MenuInput._sync_focus_visual()
