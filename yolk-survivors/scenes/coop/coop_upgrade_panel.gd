extends PanelContainer
var session
var controller
var controls: Array[Button]=[]
var cards: Array=[]
var mouse_navigation:=false
var hovered_control:=-1
@onready var view=$Margin/Content/Viewport/UpgradeView
func setup(player_session,owner_coop,slot: int) -> void:
	session=player_session
	controller=owner_coop
	$HeaderOverlay/PlayerLabel.text="P%d" % (slot+1)
	$HeaderOverlay/PlayerLabel.add_theme_color_override("font_color",UITheme.palette.hud_text)
	$HeaderOverlay/PlayerLabel.add_theme_stylebox_override("normal",UITheme.box(controller.COLORS[slot],Color.TRANSPARENT,12,0))
	add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,controller.COLORS[slot],12,2))
	$Waiting.add_theme_color_override("font_color",UITheme.palette.hud_text)
	$Margin/Content/Header.add_theme_color_override("font_color",UITheme.palette.hud_text)
	if not session:
		$Margin.hide(); $Waiting.show(); $Waiting.text="Jugador no conectado"
		return
	for i in 4:
		var card=view.get_node("Cards/Offer%d"%i)
		cards.append(card)
		var button: Button=card.get_node("MarginContainer/Control/CustomButton")
		button.pressed.disconnect(card._on_custom_button_pressed)
		_register(button,i)
		card.mouse_entered.connect(_hover.bind(i))
		card.mouse_exited.connect(_unhover.bind(i))
	_register(view.get_node("Refresh"),4)
	present()
func _register(button: Button,index: int) -> void:
	controls.append(button)
	button.focus_mode=Control.FOCUS_NONE
	button.mouse_entered.connect(_hover.bind(index))
	button.mouse_exited.connect(_unhover.bind(index))
	button.pressed.connect(func():
		if session.device<0 and not MenuInput.coop_mouse_blocked(): controller.activate(session,index))
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
		present()
func select(index: int) -> void:
	if session.experience.pending_levels.is_empty(): return
	if session.cursor!=index: SoundManager.play_sound(SoundManager.Sound.SELECTION_HOVER)
	session.cursor=index
	present()
func move_selector(direction: Vector2) -> void:
	mouse_navigation=false
	if controls.is_empty() or session.experience.pending_levels.is_empty(): return
	var origin=controls[clampi(session.cursor,0,4)]
	var next: Button=null
	var score:=INF
	for button in controls:
		if button==origin: continue
		var offset=button.get_global_rect().get_center()-origin.get_global_rect().get_center()
		var forward=offset.dot(direction)
		if forward<=1: continue
		var value=forward+absf(offset.cross(direction))*4
		if value<score: next=button; score=value
	if next: select(controls.find(next))
	else: present()
func present() -> void:
	if not session: return
	var waiting: bool=session.experience.pending_levels.is_empty()
	$Margin.visible=not waiting
	$Waiting.visible=waiting
	if waiting: return

	for i in 4:
		var item=session.offers[i] if i<session.offers.size() else null
		cards[i].visible=item is ItemUpgrade
		if item is ItemUpgrade: cards[i].item=item
		controls[i].disabled=session.disconnected or not item is ItemUpgrade
	for i in controls.size():
		UITheme.style_slot(controls[i],0)
		if i==session.cursor and (not mouse_navigation or hovered_control==i):
			var style=controls[i].get_theme_stylebox("hover").duplicate() as StyleBoxFlat
			style.border_color=controller.COLORS[session.slot]
			style.set_border_width_all(maxi(4,UITheme.palette.focus_width))
			controls[i].add_theme_stylebox_override("normal",style)
	var cost: int=ItemBase.ECONOMY_RULES.reroll_price(controller.arena.spawner.wave_index,session.rerolls)
	controls[4].text="REFRESH %d"%cost
	controls[4].disabled=session.disconnected or session.coins<cost
