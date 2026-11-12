extends PanelContainer
## Solo shop components, with independent ownership and a shared ready barrier.
const InventorySlot=preload("res://scenes/coop/coop_inventory_slot.tscn")
var session
var owner_coop
var controls: Array[Button]=[]
var offers: Array=[]
var lock_buttons: Array[Button]=[]
var inventory: Array=[]
var inventory_signature: Array=[]
var context_weapon: Weapon
var context_origin:=0
var page := "shop"
var slot_index := 0
var mouse_navigation := false
var hovered_control := -1
var initial_style_pending := true
@onready var content=$Margin/Content
@onready var view=$Margin/Content/ShopViewport/ShopView
@onready var stats=$Margin/Content/ShopViewport/ShopView/Stats
@onready var stats_secondary=$Margin/Content/ShopViewport/ShopView/StatsSecondary

func setup(player_session, controller, slot: int) -> void:
	session=player_session
	owner_coop=controller
	slot_index=slot
	UITheme.palette_changed.connect(_refresh_panel_style)
	$Margin.visible=session!=null
	$Empty.visible=session==null
	_refresh_panel_style()
	if not session: return
	for sheet in [stats,stats_secondary]:
		sheet.bound_player=session.actor
		sheet.independent_navigation=true
		sheet.tabs.hide()
		sheet.hint.hide()
	for i in 4:
		var card=view.get_node("Cards/Offer%d"%i)
		offers.append(card)
		card.preview_stats=session.actor.stats
		var button=card.get_node("MarginContainer/Control/Actions").get_child(0)
		# The session controller performs purchases, never the solo global wallet.
		button.pressed.disconnect(card._on_custom_button_pressed)
		_register(button,i)
		card.mouse_entered.connect(_hover.bind(i))
		card.mouse_exited.connect(_unhover.bind(i))
		card.lock_button.tooltip_text=""
		card.lock_button.focus_mode=Control.FOCUS_NONE
		card.lock_button.toggled.disconnect(card._on_lock_toggled)
		lock_buttons.append(card.lock_button)
		card.lock_button.mouse_entered.connect(_hover.bind(200+i))
		card.lock_button.mouse_exited.connect(_unhover.bind(200+i))
		card.lock_button.toggled.connect(func(_value):
			if session.device<0 and not MenuInput.coop_mouse_blocked(): owner_coop.toggle_lock(session,i)
			else: card.set_locked(session.locked[i]))
	_register(view.get_node("Refresh"),4)
	_register(view.get_node("WeaponActions/Margin/Content/Combine"),5)
	_register(view.get_node("WeaponActions/Margin/Content/Sell"),6)
	_register(view.get_node("Ready"),7)
	var close: Button=view.get_node("WeaponActions/Margin/Content/Close")
	close.set_meta("sfx_manual",true)
	close.pressed.connect(func():
		if session.device<0 and not MenuInput.coop_mouse_blocked(): close_weapon_actions())
	close.mouse_entered.connect(_hover.bind(100))
	close.mouse_exited.connect(_unhover.bind(100))
	_register(view.get_node("StatsButton"),8)
	var items: Button=view.get_node("ItemsButton")
	items.set_meta("sfx_manual",true)
	items.mouse_entered.connect(_hover.bind(300))
	items.mouse_exited.connect(_unhover.bind(300))
	items.pressed.connect(func():
		if session.device<0 and not MenuInput.coop_mouse_blocked() and context_target()==null:
			select(300)
			owner_coop.activate(session,300))
	var shop: Button=view.get_node("ShopButton")
	shop.set_meta("sfx_manual",true)
	shop.mouse_entered.connect(_hover.bind(301))
	shop.mouse_exited.connect(_unhover.bind(301))
	shop.pressed.connect(func():
		if session.device<0 and not MenuInput.coop_mouse_blocked() and context_target()==null:
			select(301)
			owner_coop.activate(session,301))
	for sheet in [stats,stats_secondary]:
		for stat in sheet.stat_rows:
			var target=sheet.stat_rows[stat].get_node("StatHelpTarget")
			target.focus_mode=Control.FOCUS_NONE
			if session.device>=0: target.mouse_filter=Control.MOUSE_FILTER_IGNORE
		sheet.stat_help.top_level=false
		sheet.stat_help.scale=Vector2.ONE
	_apply_page()
	_show_initial_selection.call_deferred()

func _show_initial_selection() -> void:
	if not is_inside_tree(): return
	await get_tree().process_frame
	if not is_inside_tree() or is_queued_for_deletion() or not initial_style_pending: return
	initial_style_pending=false
	mouse_navigation=false
	hovered_control=-1
	present()

func _register(button: Button,index: int) -> void:
	button.set_meta("sfx_manual",true)
	controls.append(button)
	button.focus_mode=Control.FOCUS_NONE
	button.mouse_entered.connect(_hover.bind(index))
	button.mouse_exited.connect(_unhover.bind(index))
	button.pressed.connect(func():
		if session.device<0 and not MenuInput.coop_mouse_blocked():
			if context_target()!=null and index not in [5,6]: return
			select(index)
			owner_coop.activate(session,index))

func _hover(index: int) -> void:
	if MenuInput.coop_mouse_blocked(): return
	if session.device<0 and not MenuInput.coop_mouse_blocked():
		mouse_navigation=true
		hovered_control=index
		select(index)

func _unhover(index: int) -> void:
	if MenuInput.coop_mouse_blocked(): return
	if session.device<0 and hovered_control==index:
		hovered_control=-1
		owner_coop._render_panel(session)

func _highlighted(index: int) -> bool:
	return session.cursor==index and (not mouse_navigation or hovered_control==index)

func select(index: int) -> void:
	if context_target()!=null and index not in [5,6,100]: return
	if session.cursor!=index: SoundManager.play_sound(SoundManager.Sound.UI_HOVER)
	session.cursor=index
	owner_coop._render_panel(session)
	if index>=9 and index<controls.size():
		var scroll=controls[index].get_parent().get_parent() as ScrollContainer
		if scroll: scroll.ensure_control_visible(controls[index])

func toggle_stats() -> void:
	set_page("stats")

func toggle_items() -> void:
	set_page("items")

func set_page(next: String) -> void:
	if context_target()!=null or next==page: return
	page=next
	session.cursor=0 if page=="shop" else 301
	SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT)
	present()

func _apply_page() -> void:
	var reward: bool=owner_coop.mode=="rewards"
	view.get_node("Cards").visible=page=="shop"
	view.get_node("Inventory").visible=page!="stats" and not reward
	view.get_node("Inventory/PassivesPanel").visible=page=="items"
	view.get_node("Inventory/WeaponsPanel").visible=page=="shop"
	stats.visible=page=="stats"
	stats_secondary.visible=page=="stats"
	if page=="stats":
		stats.show_primary()
		stats_secondary.show_secondary(true)
	view.get_node("Refresh").visible=page=="shop" and not reward
	view.get_node("ItemsButton").visible=not reward
	view.get_node("StatsButton").visible=not reward
	view.get_node("Ready").visible=not reward
	view.get_node("ShopButton").visible=not reward
	view.get_node("ShopButton").disabled=page=="shop" or session.disconnected
	view.get_node("ItemsButton").disabled=page=="items" or session.disconnected
	view.get_node("StatsButton").disabled=page=="stats" or session.disconnected

func move_selector(direction: Vector2) -> void:
	initial_style_pending=false
	mouse_navigation=false
	if context_target()!=null:
		var options: Array=[5,6,100] if owner_coop.can_combine(session,context_weapon) else [6,100]
		var current: int=options.find(session.cursor)
		select(options[posmod(current+(1 if direction.x>0 or direction.y>0 else -1),options.size())])
		return
	if controls.is_empty(): return
	var targets: Dictionary={}
	for i in controls.size(): targets[i]=controls[i]
	for i in lock_buttons.size(): targets[200+i]=lock_buttons[i]
	targets[300]=view.get_node("ItemsButton")
	targets[301]=view.get_node("ShopButton")
	var origin: Button=targets.get(session.cursor,controls[0])
	var selected: int=-1
	var score:=INF
	for index in targets:
		var button: Button=targets[index]
		if button==origin or button.disabled or not button.is_visible_in_tree(): continue
		var offset=button.get_global_rect().get_center()-origin.get_global_rect().get_center()
		var forward=offset.dot(direction)
		if forward<=1: continue
		var candidate=forward+absf(offset.cross(direction))*4
		if candidate<score: score=candidate; selected=index
	if selected>=0: select(selected)
	else: present()

func _inventory() -> void:
	var entries: Array=[]
	for weapon in session.actor.current_weapons: entries.append({"item":weapon.data,"count":1,"weapon":true,"instance":weapon})
	for record in session.actor.passive_items.owned_records:
		var found=false
		for entry in entries:
			if not entry.weapon and entry.item==record.item: entry.count+=1; found=true; break
		if not found: entries.append({"item":record.item,"count":1,"weapon":false,"instance":null})
	var signature: Array=[]
	for entry in entries: signature.append([entry.item,entry.count,entry.instance])
	signature.append(["limit",session.actor.get_weapon_limit()])
	if signature==inventory_signature: return
	inventory_signature=signature
	inventory=entries
	controls.resize(9)
	for section in ["Weapons","Passives"]:
		var row=view.get_node("Inventory/"+section+"Panel/Scroll/"+section)
		for child in row.get_children(): row.remove_child(child); child.queue_free()
	for i in inventory.size():
		var entry=inventory[i]
		var button=InventorySlot.instantiate()
		button.independent_selection=true
		button.quantity=entry.count
		view.get_node("Inventory/WeaponsPanel/Scroll/Weapons" if entry.weapon else "Inventory/PassivesPanel/Scroll/Passives").add_child(button)
		button.item=entry.item
		button.toggle_mode=false # Co-op selection is owned by the player cursor, not a latched mouse press.
		_register(button,9+i)
	for i in maxi(0,session.actor.get_weapon_limit()-session.actor.current_weapons.size()):
		var empty=preload("res://scenes/coop/empty_inventory_slot.tscn").instantiate()
		view.get_node("Inventory/WeaponsPanel/Scroll/Weapons").add_child(empty)
	if session.cursor>=9 and session.cursor<100: session.cursor=mini(session.cursor,controls.size()-1)

func present() -> void:
	if not session: return
	_inventory()
	_apply_page()
	var upgrades: bool=owner_coop.mode=="upgrades"
	var reward: bool=not session.rewards.is_empty()
	view.get_node("Balance").text=str(session.coins)
	for i in 4:
		var card=offers[i]
		var item=session.offers[i] if i<session.offers.size() else null
		card.visible=item!=null
		if not item: continue
		card.preview_stats=session.actor.stats
		card.shop_wave=owner_coop.arena.spawner.wave_index
		card.shop_item=item
		card.lock_button.remove_theme_stylebox_override("normal")
		card.lock_button.remove_theme_stylebox_override("pressed")
		card.set_locked(session.locked[i])
		card.lock_button.visible=not upgrades and not reward
		card.lock_button.disabled=session.ready or session.disconnected
		controls[i].disabled=session.ready or session.disconnected
		card.item_cost.text="CONSERVAR" if reward and i==0 else "VENDER %d"%item.get_sell_price(card.shop_wave) if reward else "ELEGIR" if upgrades else str(item.get_shop_price(card.shop_wave))
		card.set_price_unaffordable(not reward and not upgrades and session.coins < item.get_shop_price(card.shop_wave))
		if item is ItemUpgrade: card.item_description.text="%s %s"%[ItemWeapon.format_number(item.value),item.stat_id]
	for i in 4:
		controls[4+i].disabled=session.disconnected or reward or (session.ready and i!=3) or (upgrades and i>0)
	view.get_node("Refresh/Content/CostLabel").text="REFRESH %d"%ItemBase.ECONOMY_RULES.reroll_price(owner_coop.arena.spawner.wave_index,session.rerolls)
	controls[7].text="LISTO"
	$ReadyShade.visible=session.ready and owner_coop.mode=="shop"
	for i in controls.size():
		if i in [5,6]: continue
		var button=controls[i]
		if i==7:
			var states=UITheme._button_styles(UITheme.palette.primary,UITheme.palette.outline)
			for state in states: button.add_theme_stylebox_override(state,states[state])
		else: UITheme.style_slot(button,inventory[i-9].item.item_tier if i>=9 else 0)
		if _highlighted(i):
			var style=button.get_theme_stylebox("hover").duplicate() as StyleBoxFlat
			style.border_color=owner_coop.COLORS[session.slot]
			style.set_border_width_all(maxi(4,UITheme.palette.focus_width))
			button.add_theme_stylebox_override("normal",style)
	for i in lock_buttons.size():
		if _highlighted(200+i):
			var border=lock_buttons[i].get_theme_stylebox("hover").duplicate() as StyleBoxFlat
			border.border_color=owner_coop.COLORS[session.slot]
			border.set_border_width_all(maxi(4,UITheme.palette.focus_width))
			lock_buttons[i].add_theme_stylebox_override("normal",border)
			lock_buttons[i].add_theme_stylebox_override("pressed",border)
	for pair in [["ItemsButton",300],["ShopButton",301]]:
		var button: Button=view.get_node(pair[0])
		UITheme.style_slot(button,0)
		if _highlighted(pair[1]) and not button.disabled:
			button.add_theme_stylebox_override("normal",UITheme.box(UITheme.palette.hover_surface,owner_coop.COLORS[session.slot],14,4))
	_render_weapon_actions()
	_show_detail()

func _show_detail() -> void:
	var popup=view.get_node("Inspect")
	var valid: bool=context_target()==null and session.cursor>=9 and session.cursor-9<inventory.size() and controls[session.cursor].is_visible_in_tree()
	if not valid:
		popup.dismiss()
		return
	popup.preview_stats=session.actor.stats
	popup.shop_wave_override=owner_coop.arena.spawner.wave_index
	popup.show_for_card(controls[session.cursor])

func scroll_detail(amount: float) -> void:
	if session.cursor>=9: view.get_node("Inspect").full_description.get_v_scroll_bar().value+=amount*2
	elif session.cursor<4 and offers[session.cursor].visible: offers[session.cursor].item_description.get_v_scroll_bar().value+=amount*2

func show_waiting() -> void:
	$InnerFrame.hide()
	$Margin.hide()
	$Empty.text="Listo"
	$Empty.add_theme_color_override("font_color",UITheme.palette.hud_text)
	$Empty.show()
	add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,Color.TRANSPARENT,0,0))

func context_target() -> Weapon:
	return context_weapon if is_instance_valid(context_weapon) and session.actor.current_weapons.has(context_weapon) else null

func activate_inventory(index: int) -> void:
	if session.ready or index<9 or index-9>=inventory.size(): return
	var entry=inventory[index-9]
	if not entry.weapon: return
	SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT)
	context_origin=index
	context_weapon=entry.instance
	view.get_node("WeaponActions").show()
	session.cursor=5 if owner_coop.can_combine(session,context_weapon) else 6
	present()

func close_weapon_actions(play_sound: bool=true) -> void:
	if play_sound: SoundManager.play_sound(SoundManager.Sound.UI_BACK)
	context_weapon=null
	view.get_node("WeaponActions").hide()
	session.cursor=clampi(context_origin,0,controls.size()-1)
	present()

func _render_weapon_actions() -> void:
	var popup=view.get_node("WeaponActions")
	var weapon=context_target()
	popup.visible=weapon!=null
	if not weapon: return
	popup.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,UITheme.palette.outline,16,2))
	controls[5].text="COMBINAR"
	controls[5].disabled=not owner_coop.can_combine(session,weapon) or session.ready
	controls[6].text="VENDER · %d YEMAS"%weapon.data.get_sell_price(owner_coop.arena.spawner.wave_index)
	controls[6].disabled=session.ready
	var close=popup.get_node("Margin/Content/Close")
	for pair in [[controls[5],5],[controls[6],6],[close,100]]:
		var button: Button=pair[0]
		var fill: Color=UITheme.palette.danger if pair[1]==6 else UITheme.palette.button
		var styles=UITheme._button_styles(fill,UITheme.palette.outline)
		for state in styles: button.add_theme_stylebox_override(state,styles[state])
		if _highlighted(pair[1]): button.add_theme_stylebox_override("normal",styles.hover)
	popup.reset_size()
	var rect: Rect2=view.get_global_transform().affine_inverse()*controls[context_origin].get_global_rect()
	var point:=Vector2(rect.get_center().x-popup.size.x*.5,rect.position.y-popup.size.y-12)
	popup.position=point.clamp(Vector2(12,12),view.size-popup.size-Vector2(12,12))

func _input(event: InputEvent) -> void:
	if MenuInput.coop_mouse_blocked() and (event is InputEventMouseMotion or event is InputEventMouseButton): return
	if is_visible_in_tree() and session and session.device<0 and event is InputEventMouseMotion and event.relative.length_squared()>0:
		initial_style_pending=false
	if is_visible_in_tree() and session and session.device<0 and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		var tooltip=view.get_node("Inspect")
		if tooltip.visible and tooltip.get_global_rect().has_point(get_global_mouse_position()):
			scroll_detail(-100.0 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 100.0)
			get_viewport().set_input_as_handled()
			return
	if not is_visible_in_tree() or not session or session.device>=0 or context_target()==null: return
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		var point=get_global_mouse_position()
		if get_global_rect().has_point(point) and not view.get_node("WeaponActions").get_global_rect().has_point(point):
			close_weapon_actions()
			get_viewport().set_input_as_handled()

func _refresh_panel_style() -> void:
	var color: Color=owner_coop.COLORS[slot_index]
	add_theme_stylebox_override("panel",UITheme.box(color,color,12,3))
	$InnerFrame.show()
	$InnerFrame/Surface.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,Color.TRANSPARENT,12,0))
	$TabAnchor/PlayerTab.add_theme_stylebox_override("panel",UITheme.box(color,Color.TRANSPARENT,7,0))
	$TabAnchor/PlayerTab/Label.text="P%d"%(slot_index+1)
	$TabAnchor/PlayerTab/Label.add_theme_color_override("font_color",UITheme.palette.surface)
	if session and owner_coop.mode=="rewards" and session.rewards.is_empty(): show_waiting()
