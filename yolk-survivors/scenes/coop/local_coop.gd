extends Node
## First playable local-coop path. Solo keeps its existing UI and run flow.
const Session = preload("res://resources/coop_player_session.gd")
const RewardPanelScene = preload("res://scenes/coop/coop_reward_panel.tscn")
const UpgradePanelScene = preload("res://scenes/coop/coop_upgrade_panel.tscn")
const PanelScene = preload("res://scenes/coop/coop_player_panel.tscn")
const LobbySlot = preload("res://scenes/coop/lobby_slot.tscn")
const LobbyPlayer = preload("res://scenes/coop/lobby_player.tscn")
const Bias = preload("res://resources/shop_weapon_bias.gd")
const ShopRarity = preload("res://resources/shop_rarity.gd")
const UpgradeRarity = preload("res://resources/upgrade_rarity.gd")
const COLORS := [Color("16778b"),Color("ae4d53"),Color("4967a4"),Color("936719")]
const MAX_PLAYERS := 4
const MAX_SHOP_WEAPONS := 2
var selection_flow: Node
var arena
var sessions: Array = []
var active := false
var mode := ""
var paused := false
var repeat_times: Dictionary = {}
var panels: Array[Control] = []
var reward_queues: Array = []
var distribution_cursor := 0
var transitioning := false
var corpses: Array[Node2D] = []
@onready var screen: Panel = $UI/Screen
@onready var content: VBoxContainer = $UI/Screen/Margin/Content
@onready var lobby: HBoxContainer = $UI/Screen/Margin/Content/Lobby
@onready var grids: Container = $UI/Screen/Margin/Content/Panels
@onready var title: Label = $UI/Screen/Margin/Content/Title
@onready var hint: Label = $UI/Screen/Margin/Content/Hint
@onready var hud: Control = $UI/HUD

func _ready() -> void:
	arena=get_parent()
	content.get_node("Back").pressed.connect(stop)
	Input.joy_connection_changed.connect(_connection_changed)
	grids.visibility_changed.connect(_sync_shop_chrome)

func _sync_shop_chrome() -> void:
	title.visible=not grids.visible
	hint.visible=not grids.visible
	content.get_node("Back").visible=not grids.visible
	screen.theme_type_variation=&"OverlayPanel" if mode in ["upgrades","rewards"] else &"ScreenPanel"

func handles_input() -> bool:
	return active or screen.visible or (selection_flow != null and selection_flow.handles_input())

func open() -> void:
	mode="characters"
	sessions.clear()
	arena.start_panel.hide()
	screen.show()
	lobby.show()
	grids.hide()
	hud.hide()
	Global.game_paused=true
	_refresh_lobby()

func join(device: int):
	for session in sessions:
		if session.device==device: return session
	if not mode in ["characters","weapons"] or sessions.size()>=MAX_PLAYERS: return null
	var session=Session.new()
	session.slot=sessions.size()
	session.device=device
	session.character=arena.selection_panel.player_list[0]
	session.weapon=arena.weapon_selection_panel.weapons_list[0]
	for item in arena.weapon_selection_panel.weapons_list:
		if Global.is_valid_starting_weapon(item) and session.character.can_use_weapon(item) and Progression.is_weapon_unlocked(item):
			session.weapon=item
			break
	sessions.append(session)
	for other in sessions: other.ready=false
	_refresh_lobby()
	return session

func _catalogue() -> Array:
	var result: Array=[]
	for item in (arena.selection_panel.player_list if mode=="characters" else arena.weapon_selection_panel.weapons_list):
		if mode=="characters" and Progression.is_character_unlocked(item): result.append(item)
		elif mode=="weapons" and Global.is_valid_starting_weapon(item) and Progression.is_weapon_unlocked(item): result.append(item)
	return result

func _clear(container: Node) -> void:
	for node in container.get_children():
		container.remove_child(node)
		node.queue_free()

func _refresh_lobby() -> void:
	if not screen.visible or not mode in ["characters","weapons"]: return
	title.text="ELEGIR PERSONAJES" if mode=="characters" else "ELEGIR ARMAS"
	hint.text="Enter / A: unirse o confirmar · WASD / stick: elegir · Esc / B: cancelar · prueba de 2 jugadores"
	var slots=_catalogue()
	var left=lobby.get_node("LeftSlots")
	var right=lobby.get_node("RightSlots")
	_clear(left); _clear(right); _clear(lobby.get_node("Players"))
	for i in slots.size():
		var item=slots[i]
		var button=LobbySlot.instantiate()
		button.icon=item.icon if mode=="characters" else item.item_icon
		button.expand_icon=true
		var owners=PackedStringArray()
		for session in sessions:
			if (session.character if mode=="characters" else session.weapon)==item: owners.append("P%d"%(session.slot+1))
		button.text=" ".join(owners)
		button.pressed.connect(_mouse_choose.bind(i))
		(left if i < ceili(slots.size()/2.0) else right).add_child(button)
	for session in sessions:
		var button=LobbyPlayer.instantiate()
		button.icon=session.character.icon if mode=="characters" else session.weapon.item_icon
		button.expand_icon=true
		button.text="P%d · %s\n%s%s"%[session.slot+1,session.character.name if mode=="characters" else session.weapon.item_name,"LISTO" if session.ready else "Elegir", " · teclado" if session.device<0 else " · mando %d"%session.device]
		button.add_theme_stylebox_override("normal",UITheme.box(UITheme.palette.surface,COLORS[session.slot]))
		button.pressed.connect(_mouse_confirm.bind(session.slot))
		lobby.get_node("Players").add_child(button)

func _mouse_choose(index: int) -> void:
	var session=_keyboard_session()
	if not session: session=join(-1)
	_choose_lobby(session,index)

func _mouse_confirm(slot: int) -> void:
	if sessions[slot].device<0: _confirm_lobby(sessions[slot])

func _choose_lobby(session, index: int) -> void:
	if session.ready: return
	var items=_catalogue()
	if items.is_empty(): return
	session.cursor=posmod(index,items.size())
	if mode=="characters":
		session.character=items[session.cursor]
	else:
		if not session.character.can_use_weapon(items[session.cursor]): return
		session.weapon=items[session.cursor]
	_refresh_lobby()

func _confirm_lobby(session) -> void:
	if mode=="weapons" and not session.character.can_use_weapon(session.weapon): return
	session.ready=not session.ready
	if sessions.size()>=2 and sessions.all(func(s): return s.ready):
		if mode=="characters":
			mode="weapons"
			for s in sessions:
				s.ready=false
				s.cursor=0
				for item in _catalogue():
					if s.character.can_use_weapon(item): s.weapon=item; break
		else:
			start_run()
			return
	_refresh_lobby()

func _keyboard_session():
	for session in sessions:
		if session.device<0: return session
	return null

func _input(event: InputEvent) -> void:
	if selection_flow and selection_flow.handles_input(): return
	if not handles_input(): return
	if event is InputEventKey and event.echo: return
	var device: int = event.device if event is InputEventJoypadButton or event is InputEventJoypadMotion else -1
	var session=null
	for s in sessions:
		if s.device==device: session=s; break
	var accept: bool = (event is InputEventKey and event.pressed and event.physical_keycode==KEY_ENTER) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_A)
	var cancel: bool = (event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_B)
	var pause: bool = event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_START
	if mode=="result" and (accept or cancel):
		stop()
		get_viewport().set_input_as_handled()
		return
	if not session and cancel and mode in ["characters","weapons"]:
		stop()
		return
	if not session and accept and mode in ["characters","weapons"]:
		join(device)
		get_viewport().set_input_as_handled()
		return
	if not session: return
	if mode in ["shop","upgrades","rewards"] and (event is InputEventKey or event is InputEventJoypadButton): panels[session.slot].mouse_navigation=false
	if mode=="shop" and cancel and panels[session.slot].context_target()!=null:
		panels[session.slot].close_weapon_actions()
		get_viewport().set_input_as_handled()
		return
	if mode=="shop" and cancel and panels[session.slot].page!="shop":
		panels[session.slot].set_page("shop")
		get_viewport().set_input_as_handled()
		return
	if active and mode=="combat":
		if paused and ((event is InputEventKey and event.pressed and event.physical_keycode==KEY_Q) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_BACK)):
			stop()
			return
		if pause or cancel:
			if not sessions.any(func(s): return s.disconnected):
				_set_paused(not paused)
		elif not paused and ((event is InputEventKey and event.pressed and event.physical_keycode==KEY_SPACE) or (event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_A)): session.dash_requested=true
		return
	if cancel and mode in ["characters","weapons"]:
		if session.ready: session.ready=false
		elif mode=="weapons":
			mode="characters"
			for s in sessions: s.ready=false
		else:
			sessions.erase(session)
			for i in sessions.size(): sessions[i].slot=i
		_refresh_lobby()
	elif mode=="shop" and ((event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_Y) or (event is InputEventKey and event.pressed and event.physical_keycode==KEY_TAB)):
		panels[session.slot].toggle_stats()
	elif accept:
		if mode in ["characters","weapons"]: _confirm_lobby(session)
		elif mode in ["shop","upgrades","rewards"]: activate(session,session.cursor)
	elif event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_X: toggle_lock(session)
	elif event is InputEventKey and event.pressed and event.physical_keycode==KEY_L: toggle_lock(session)
	if mode in ["characters","weapons","shop","upgrades","rewards"]: get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	hud.visible=active and mode=="combat" and not paused
	if active:
		arena.player_health_bar.hide()
		arena.experience_bar.hide()
		for i in MAX_PLAYERS:
			var widget=hud.get_node("P%d" % (i+1))
			widget.visible=i<sessions.size()
			if i>=sessions.size(): continue
			var session=sessions[i]
			var health=session.actor.health_component
			widget.get_node("PlayerLabel").text="P%d" % (i+1)
			widget.get_node("Wallet/Balance/Value").text=str(session.coins)
			widget.get_node("Wallet/Balance/Value").add_theme_color_override("font_color",UITheme.palette.hud_text)
			widget.get_node("Wallet/Reserve/Value").text=str(sessions.reduce(func(total,s): return total+s.reserve,0))
			widget.get_node("Wallet/Reserve/Value").add_theme_color_override("font_color",UITheme.palette.hud_text)
			widget.get_node("Health").update_bar(health.current_health/maxf(1.0,health.max_health),health.current_health)
			var xp=session.experience
			var bar=widget.get_node("Experience")
			bar.update_bar(float(xp.experience)/xp.required_experience(),xp.experience)
			bar.health_value.text="LV %d  %d / %d" % [xp.level,xp.experience,xp.required_experience()]
			bar.health_value.add_theme_font_size_override("font_size",22)
	if not screen.visible or not mode in ["characters","weapons","shop","upgrades","rewards"]: return
	for session in sessions:
		if session.disconnected or (mode=="upgrades" and session.experience.pending_levels.is_empty()) or (mode=="rewards" and session.rewards.is_empty()): continue
		if mode=="shop":
			var scroll_axis: float=Input.get_joy_axis(session.device,JOY_AXIS_RIGHT_Y) if session.device>=0 else float(Input.is_physical_key_pressed(KEY_PAGEDOWN))-float(Input.is_physical_key_pressed(KEY_PAGEUP))
			if absf(scroll_axis)>.2: panels[session.slot].scroll_detail(scroll_axis*delta*300)
		var movement: Vector2=session.poll_movement()
		var columns: int = 2 if mode in ["shop","upgrades","rewards"] else 4
		var step: int = (1 if movement.x>0 else -1) if absf(movement.x)>.5 else (columns if movement.y>0 else -columns) if absf(movement.y)>.5 else 0
		repeat_times[session.slot]=maxf(0,float(repeat_times.get(session.slot,0))-delta)
		if step==0: repeat_times[session.slot]=0; continue
		if repeat_times[session.slot]>0: continue
		repeat_times[session.slot]=.2
		if mode in ["shop","upgrades","rewards"]: panels[session.slot].move_selector(Vector2(signi(step),0) if absi(step)==1 else Vector2(0,signi(step)))
		else: _choose_lobby(session,session.cursor+step)

func _connection_changed(device: int, connected: bool) -> void:
	for session in sessions:
		if session.device!=device: continue
		session.disconnected=not connected
		if active:
			_set_paused(true)

func _set_paused(value: bool) -> void:
	paused=value
	Global.game_paused=value
	arena.music_player.stream_paused=value
	arena.coocking_player.stream_paused=value
	if mode=="combat":
		screen.visible=value
		lobby.hide(); grids.hide()
		title.text="PAUSA DEL EQUIPO"
		hint.text="Reconectá el mando y presioná Start / Esc para continuar." if sessions.any(func(s): return s.disconnected) else "Start / Esc: continuar · Select / Q: volver al menú"

func start_run(difficulty: int = 0) -> void:
	if active or sessions.is_empty(): return
	active=true
	mode="combat"
	paused=false
	transitioning=false
	distribution_cursor=0
	Global.coop_players.clear()
	arena.in_arena=true
	arena.defeat_in_progress=false
	arena.boss_test_mode=false
	arena.environment_controller.reset_stage_selection()
	Global.level_selected=arena.spawner.DIFFICULTY_RULES.normalize_level(difficulty)
	arena.spawner.reset_run(Global.level_selected)
	arena.level_panel.hide()
	arena.selection_panel.hide()
	arena.weapon_selection_panel.hide()
	arena.run_experience.reset()
	Weapon.damage_records.clear()
	Progression.end_run() # Prototype run does not write solo character victories.
	for session in sessions:
		var actor=Global.available_players[session.character.name].instantiate()
		actor.stats=session.character.duplicate()
		actor.stats.initialize_character_passives()
		actor.coop_session=session
		session.actor=actor
		session.coins=Global.STARTING_COINS
		session.reserve=0
		session.experience.reset()
		session.experience.level_gained.connect(_level_gained.bind(session))
		Global.coop_players.append(actor)
		arena.add_child(actor)
		actor.trail.default_color=COLORS[session.slot]
		actor.shadow.material=actor.shadow.material.duplicate()
		actor.shadow.material.set_shader_parameter("outline_color",COLORS[session.slot])
		actor.add_weapon(session.weapon)
		if Global.is_valid_starting_weapon(session.character.starting_weapon) and session.character.can_use_weapon(session.character.starting_weapon): actor.add_weapon(session.character.starting_weapon)
	Global.player=sessions[0].actor
	screen.hide()
	hud.show()
	Global.game_paused=false
	arena.spawner.start_wave()
	arena.wave_active=true
	arena.coocking_player.stream_paused=false
	arena.environment_controller._sync_debug_shop_visibility()
	_process(0.0)

func configure_players() -> void:
	if not active: return
	var area=arena.environment_controller.current
	for session in sessions:
		if not is_instance_valid(session.actor): continue
		session.actor.arena_environment=area
		session.actor.global_position=area.clamp_position(area.movement_bounds.get_center()+Vector2((session.slot-(sessions.size()-1)*.5)*120,0))
	arena.get_node("Camera2D").overview=true

func _level_gained(_level: int, session) -> void:
	var actor: Player=session.actor
	actor.passive_items.on_level_gained()
	var before: float=actor.stats.health
	actor.stats.apply_stat_change("health",1)
	actor.health_component.max_health=actor.stats.health
	actor.health_component.heal(maxf(0,actor.stats.health-before))

func collect_yolk(amount: int) -> int:
	if sessions.is_empty(): return 0
	var amounts: Array[int]=[]
	amounts.resize(sessions.size()); amounts.fill(maxi(0,amount)/sessions.size())
	for i in maxi(0,amount)%sessions.size():
		amounts[distribution_cursor]+=1
		distribution_cursor=(distribution_cursor+1)%sessions.size()
	var bonus:=0
	for i in sessions.size(): bonus+=sessions[i].collect(amounts[i])
	return bonus

func enemy_died(enemy: Enemy) -> void:
	if not arena.wave_active or enemy.get_meta("stage_hazard",false) or enemy.has_meta("kill_reward_processed"): return
	enemy.set_meta("kill_reward_processed",true)
	if not enemy.last_hit_grants_rewards: return
	for session in sessions: session.experience.add_experience(enemy.stats.experience_reward,session.actor.stats.experience_gain)
	if enemy.get_meta("incognito_reward",false):
		arena.play_incognito_death(enemy)
		if sessions.is_empty(): return
		var recipient=sessions.pick_random()
		var reserved=recipient.rewards.map(func(item): return {"item":item})
		var item=arena.incognito_rewards.loot.select_item(recipient.actor,reserved)
		if item: recipient.rewards.append(item)
	else: arena.spawn_coins(enemy)

func player_down(actor: Player) -> void:
	var corpse=preload("res://scenes/coop/player_corpse.tscn").instantiate()
	arena.add_child(corpse)
	corpse.global_position=actor.global_position
	corpses.append(corpse)
	SoundManager.play_sound(SoundManager.Sound.RUN_DEFEAT)
	actor.hide()
	actor.process_mode=Node.PROCESS_MODE_DISABLED
	for weapon in actor.current_weapons: weapon.weapon_behaviour.reset_attack()
	if not Global.live_players().is_empty(): return
	arena.wave_active=false
	Global.game_paused=true
	arena.clear_arena()
	arena._play_menu_music()
	mode="result"
	screen.show(); lobby.hide(); grids.hide()
	title.text="DERROTA DEL EQUIPO"
	hint.text="Todos los jugadores han caído."

func wave_completed() -> void:
	if transitioning or not active or mode!="combat": return
	transitioning=true
	arena.wave_active=false
	Global.game_paused=true
	Weapon.finish_damage_wave()
	var bank:=0
	for pickup in arena.gold_list:
		if is_instance_valid(pickup) and not pickup.awarded: bank+=maxi(0,pickup.value)
	for i in sessions.size(): sessions[i].reserve=bank/sessions.size()+(1 if i<bank%sessions.size() else 0)
	SoundManager.play_sound(SoundManager.Sound.WAVE_COMPLETE)
	arena.clear_arena(true,hud.get_node("P1/Wallet/Reserve/Icon"))
	arena.coocking_player.stream_paused=true
	await get_tree().create_timer(1.0).timeout
	if not active or mode!="combat":
		transitioning=false
		return
	arena.coins_bag.hide()
	_clear_corpses()
	if arena.spawner.wave_index>=arena.spawner.last_wave_number():
		mode="result"
		screen.show(); lobby.hide(); grids.hide()
		hud.hide()
		transitioning=false
		title.text="¡VICTORIA DEL EQUIPO!"
		hint.text="Cooperativo de prueba completado."
		arena._play_menu_music()
		return
	for session in sessions:
		session.coins+=int(session.actor.stats.harvesting)
		session.actor.passive_items.finish_wave()
	_show_post_wave_phase("rewards" if sessions.any(func(s): return not s.rewards.is_empty()) else "upgrades" if sessions.any(func(s): return not s.experience.pending_levels.is_empty()) else "shop")
	transitioning=false

func _show_post_wave_phase(phase: String) -> void:
	hud.hide()
	arena.coins_bag.hide()
	mode=phase
	screen.show(); lobby.hide(); grids.show()
	_clear(grids); panels.clear()
	for session in sessions:
		session.ready=false
		session.cursor=0
		session.rerolls=0
		session.offers.clear()
		session.locked=[false,false,false,false]
		if phase=="shop" and not session.saved_shop_offers.is_empty():
			session.offers.assign(session.saved_shop_offers)
			for i in 4: session.locked[i]=session.offers[i]!=null
			session.saved_shop_offers.clear()
		roll_offers(session)
	for slot in 4:
		var panel=(UpgradePanelScene if mode=="upgrades" else RewardPanelScene if mode=="rewards" else PanelScene).instantiate()
		grids.add_child(panel); panels.append(panel)
		panel.setup(sessions[slot] if slot<sessions.size() else null,self,slot)
		if slot<sessions.size(): _render_panel(sessions[slot])
	_sync_shop_chrome()
	if mode=="shop": tarena_music_shop()

func _advance_post_wave_phase() -> void:
	if mode=="rewards" and sessions.all(func(s): return s.rewards.is_empty()):
		_show_post_wave_phase("upgrades" if sessions.any(func(s): return not s.experience.pending_levels.is_empty()) else "shop")
	elif mode=="upgrades" and sessions.all(func(s): return s.experience.pending_levels.is_empty()):
		_show_post_wave_phase("shop")

func _activate_upgrade(session,index: int) -> void:
	if session.experience.pending_levels.is_empty(): return
	if index==4:
		var cost: int=ItemBase.ECONOMY_RULES.reroll_price(arena.spawner.wave_index,session.rerolls)
		if session.coins<cost:
			SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
			return
		session.coins-=cost; session.rerolls+=1
		SoundManager.play_sound(SoundManager.Sound.SHOP_REROLL)
	elif index>=0 and index<4:
		var item: ItemBase=session.offers[index]
		if not item is ItemUpgrade: return
		session.actor.stats.apply_stat_change(item.stat_id,item.value)
		session.experience.pending_levels.pop_front()
		SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	else: return
	session.offers.clear()
	session.cursor=0
	roll_offers(session)
	_render_panel(session)
	_advance_post_wave_phase()

func tarena_music_shop() -> void:
	arena.music_player.play_track(arena.music_player.shop_music,"shop")

func _mouse_activate(session, index: int) -> void:
	if session.device<0: activate(session,index)

func _mouse_hover(session, index: int) -> void:
	if session.device<0:
		session.cursor=index
		_render_panel(session)

func _pool(session) -> Array:
	var pool: Array=[]
	var held=Bias.equipped(session.actor)
	for item in arena.shop_panel.shop_items:
		if item is ItemWeapon:
			if Progression.is_weapon_unlocked(item) and session.actor.stats.can_use_weapon(item) and Bias.useful_tier(item,held,session.actor.get_weapon_limit()): pool.append(item)
		elif item is ItemPassive:
			# Consumable presentations and global changes are a separate follow-up.
			if item.get("effect_key")!=null and (session.actor.passive_items.is_consumable(item) or item.effect_key in ["liquidation","printer","grocery"]): continue
			if item.has_method("available_for") and not item.available_for(session.actor): continue
			pool.append(item)
	return pool

func roll_offers(session) -> void:
	if mode=="rewards":
		if session.rewards.is_empty():
			session.offers.assign([null,null,null,null]); return
		session.offers.assign([session.rewards[0],session.rewards[0],null,null])
		return
	var upgrade: bool=mode=="upgrades"
	if upgrade and session.experience.pending_levels.is_empty():
		session.offers.assign([null,null,null,null]); return
	var previous: Array=[]
	if not upgrade:
		for item in session.offers:
			if item: previous.append(item.get_offer_key())
	var old=session.offers.duplicate()
	session.offers.resize(4)
	var keys: Array=previous.duplicate()
	var weapons:=0
	if not upgrade:
		for i in 4:
			if session.locked[i] and i<old.size() and old[i]:
				session.offers[i]=old[i]
				if old[i] is ItemWeapon: weapons+=1
	var pool: Array=arena.upgrade_panel.upgrades if upgrade else _pool(session)
	var held=Bias.equipped(session.actor)
	var guarantee: bool=not upgrade and old.is_empty() and held.size()<3
	for i in 4:
		if not upgrade and session.locked[i] and i<old.size() and old[i]: continue
		var tier: int=UpgradeRarity.roll_tier(session.experience.pending_levels[0]) if upgrade else ShopRarity.roll_tier(arena.spawner.wave_index)
		var candidates=pool.filter(func(item): return item.item_tier==tier and not keys.has(item.get_offer_key()) and (upgrade or weapons<2 or not item is ItemWeapon))
		if guarantee and weapons<2:
			var matching=candidates.filter(func(item): return item is ItemWeapon and Bias.families(held).has(item.get_offer_key()))
			if not matching.is_empty(): candidates=matching; guarantee=false
		if candidates.is_empty(): candidates=pool.filter(func(item): return item.item_tier<=tier and not keys.has(item.get_offer_key()) and (upgrade or weapons<2 or not item is ItemWeapon))
		var item: ItemBase=null if candidates.is_empty() else candidates.pick_random() if upgrade else Bias.choose(candidates,held)
		session.offers[i]=item
		if item:
			keys.append(item.get_offer_key())
			if item is ItemWeapon: weapons+=1

func _refill_purchased_offer(session,index: int,purchased: ItemBase) -> void:
	var excluded: Array=[]
	var weapons:=0
	for i in session.offers.size():
		if i==index or not session.offers[i]: continue
		excluded.append(session.offers[i].get_offer_key())
		if session.offers[i] is ItemWeapon: weapons+=1
	var pool: Array=_pool(session).filter(func(item): return not excluded.has(item.get_offer_key()) and (weapons<MAX_SHOP_WEAPONS or not item is ItemWeapon))
	var different: Array=pool.filter(func(item): return item.get_offer_key()!=purchased.get_offer_key())
	if not different.is_empty(): pool=different
	var tier: int=ShopRarity.roll_tier(arena.spawner.wave_index)
	var candidates: Array=pool.filter(func(item): return item.item_tier==tier)
	if candidates.is_empty(): candidates=pool.filter(func(item): return item.item_tier<=tier)
	if candidates.is_empty(): candidates=pool
	# Never reroll the other three cards or their locks when replacing a purchase.
	session.offers[index]=Bias.choose(candidates,Bias.equipped(session.actor)) if not candidates.is_empty() else purchased

func toggle_lock(session,offer_index: int=-1) -> void:
	var index: int=offer_index if offer_index>=0 else session.cursor-200 if session.cursor>=200 and session.cursor<204 else session.cursor
	if mode!="shop" or session.disconnected or session.ready or index<0 or index>3 or not session.rewards.is_empty() or index>=session.offers.size() or not session.offers[index]: return
	if panels[session.slot].context_target()!=null: return
	session.locked[index]=not session.locked[index]
	SoundManager.play_sound(SoundManager.Sound.SHOP_LOCK if session.locked[index] else SoundManager.Sound.SHOP_UNLOCK)
	_render_panel(session)

func activate(session, index: int) -> void:
	if not mode in ["shop","upgrades","rewards"] or session.disconnected or transitioning: return
	if mode=="upgrades":
		_activate_upgrade(session,index)
		return
	if mode=="rewards" and session.rewards.is_empty(): return
	if index==301:
		panels[session.slot].set_page("shop")
		return
	if index==300:
		panels[session.slot].toggle_items()
		return
	if index>=200 and index<204:
		toggle_lock(session,index-200)
		return
	if index>=8:
		if index==100: panels[session.slot].close_weapon_actions()
		elif index==8: panels[session.slot].toggle_stats()
		else: panels[session.slot].activate_inventory(index)
		return
	if mode=="rewards":
		if index>1: return
		var reward: ItemPassive=session.rewards[0]
		if index==0:
			if session.actor.passive_items.is_consumable(reward) or not reward.available_for(session.actor): return
			reward.apply_passive_values(session.actor)
		else: session.coins+=reward.get_sell_price(arena.spawner.wave_index)
		SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT if index==0 else SoundManager.Sound.SHOP_SELL)
		session.rewards.pop_front()
		session.offers.clear()
		roll_offers(session)
		_render_panel(session)
		_advance_post_wave_phase()
		return
	if index==7:
		if not session.experience.pending_levels.is_empty(): return
		session.ready=not session.ready
		SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT if session.ready else SoundManager.Sound.UI_BACK)
	elif session.ready: return
	elif index<4:
		var item: ItemBase=session.offers[index]
		if not item: return
		var price: int=item.get_shop_price(arena.spawner.wave_index)
		if session.coins<price:
			SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
			return
		if item is ItemWeapon:
			if not receive_weapon(session,item):
				SoundManager.play_sound(SoundManager.Sound.SELECTION_INVALID)
				return
		else:
			if item.has_method("available_for") and not item.available_for(session.actor): return
			item.apply_passive_values(session.actor)
		session.coins-=price
		session.locked[index]=false
		_refill_purchased_offer(session,index,item)
		SoundManager.play_sound(SoundManager.Sound.SHOP_BUY)
	elif index==4:
		var cost: int=ItemBase.ECONOMY_RULES.reroll_price(arena.spawner.wave_index,session.rerolls)
		if session.coins<cost:
			SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
			return
		session.coins-=cost; session.rerolls+=1
		SoundManager.play_sound(SoundManager.Sound.SHOP_REROLL)
		roll_offers(session)
	elif index==5:
		if not session.experience.pending_levels.is_empty(): return
		var target: Weapon=panels[session.slot].context_target()
		if not target: return
		if combine(session,target): SoundManager.play_sound(SoundManager.Sound.SHOP_COMBINE)
		else: SoundManager.play_sound(SoundManager.Sound.SELECTION_INVALID)
		panels[session.slot].close_weapon_actions(false)
	elif index==6:
		if not session.experience.pending_levels.is_empty() or session.actor.current_weapons.is_empty(): return
		var target: Weapon=panels[session.slot].context_target()
		if not target: return
		session.coins+=target.data.get_sell_price(arena.spawner.wave_index)
		remove_weapon(session,target)
		SoundManager.play_sound(SoundManager.Sound.SHOP_SELL)
		panels[session.slot].close_weapon_actions(false)
	_render_panel(session)
	if sessions.all(func(s): return s.ready and s.experience.pending_levels.is_empty()): next_wave()

func remove_weapon(session, weapon: Weapon) -> void:
	session.actor.current_weapons.erase(weapon)
	weapon.queue_free()
	session.actor.refresh_equipment_modifiers()
	session.actor.weapons_container.update_weapons_position(session.actor.current_weapons)

func receive_weapon(session, item: ItemWeapon) -> bool:
	if session.actor.current_weapons.size()<session.actor.get_weapon_limit(): session.actor.add_weapon(item); return true
	if item.upgrade_to:
		for equipped in session.actor.current_weapons:
			if item.matches_for_upgrade(equipped.data):
				remove_weapon(session,equipped)
				session.actor.add_weapon(item.upgrade_to)
				return true
	return false

func can_combine(session,target: Weapon) -> bool:
	if not is_instance_valid(target) or not target.data.upgrade_to: return false
	for other in session.actor.current_weapons:
		if other!=target and target.data.matches_for_upgrade(other.data): return true
	return false

func combine(session,target: Weapon=null) -> bool:
	var held: Array=session.actor.current_weapons.duplicate()
	for first in held:
		if target!=null and first!=target: continue
		if not first.data.upgrade_to: continue
		for second in held:
			if second!=first and first.data.matches_for_upgrade(second.data):
				var upgraded=first.data.upgrade_to
				remove_weapon(session,first); remove_weapon(session,second)
				session.actor.add_weapon(upgraded)
				return true
	return false

func _render_panel(session) -> void:
	if session.slot>=panels.size(): return
	if mode=="rewards" and session.rewards.is_empty():
		panels[session.slot].show_waiting()
	else: panels[session.slot].present()

func _clear_corpses() -> void:
	for corpse in corpses:
		if is_instance_valid(corpse): corpse.queue_free()
	corpses.clear()

func next_wave() -> void:
	if transitioning: return
	transitioning=true
	mode="combat"
	paused=false
	screen.hide()
	for session in sessions:
		session.saved_shop_offers.clear()
		for i in 4:
			session.saved_shop_offers.append(session.offers[i] if i<session.offers.size() and session.locked[i] else null)
		if session.saved_shop_offers.all(func(item): return item==null): session.saved_shop_offers.clear()
		session.actor.process_mode=Node.PROCESS_MODE_INHERIT
		session.actor.show()
		session.actor.prepare_for_new_wave()
		session.ready=false
		session.dash_requested=false
	Global.game_paused=false
	Weapon.begin_damage_wave()
	arena.spawner.wave_index+=1
	arena.spawner.start_wave()
	arena.wave_active=true
	arena.coocking_player.stream_paused=false
	transitioning=false

func stop() -> void:
	_clear_corpses()
	if active:
		arena.wave_active=false
		arena.clear_arena()
		for session in sessions:
			if is_instance_valid(session.actor): session.actor.queue_free()
	Global.coop_players.clear()
	if active: Global.player=null
	active=false
	if selection_flow: selection_flow.disable()
	mode=""
	paused=false
	sessions.clear()
	screen.hide(); hud.hide()
	arena.in_arena=false
	arena.coocking_player.stream_paused=true
	arena.coins_bag.show()
	if is_instance_valid(arena.environment_controller.debug_stage_selector): arena.environment_controller.debug_stage_selector.show()
	Global.game_paused=true
	arena._play_menu_music()
	arena.start_panel.show()
