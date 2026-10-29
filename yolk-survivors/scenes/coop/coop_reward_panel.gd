extends PanelContainer
var session
var controller
var controls: Array[Button]=[]
var mouse_navigation:=false
var hovered_control:=-1
var sell_value: Label
@onready var card=$Viewport/View/Card
func setup(player_session,owner_coop,slot: int) -> void:
	session=player_session
	controller=owner_coop
	add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,controller.COLORS[slot],12,2))
	$HeaderOverlay/PlayerLabel.text="P%d" % (slot+1)
	$HeaderOverlay/PlayerLabel.add_theme_color_override("font_color",UITheme.palette.hud_text)
	$HeaderOverlay/PlayerLabel.add_theme_stylebox_override("normal",UITheme.box(controller.COLORS[slot],Color.TRANSPARENT,12,0))
	$Waiting.add_theme_color_override("font_color",UITheme.palette.hud_text)
	var keep: Button=card.get_node("MarginContainer/Control/Actions").get_child(0)
	keep.pressed.disconnect(card._on_custom_button_pressed)
	var sell: Button=card.lock_button
	sell.toggled.disconnect(card._on_lock_toggled)
	sell.toggle_mode=false
	controls.assign([keep,sell])
	for i in 2:
		var button=controls[i]
		button.focus_mode=Control.FOCUS_NONE
		button.set_meta("sfx_manual",true)
		button.mouse_entered.connect(_hover.bind(i))
		button.mouse_exited.connect(_unhover.bind(i))
		button.pressed.connect(func():
			if session and session.device<0 and not MenuInput.coop_mouse_blocked(): controller.activate(session,i))
	card.get_node("MarginContainer/Control/Actions").get_child(0).get_node("HBoxContainer/TextureRect").hide()
	var sell_content=sell.get_node("SellContent")
	sell_value=sell_content.get_node("Row/Value")
	sell_value.add_theme_color_override("font_color",UITheme.palette.text)
	present()
func _hover(index: int) -> void:
	if MenuInput.coop_mouse_blocked(): return
	if session and session.device<0 and not MenuInput.coop_mouse_blocked():
		mouse_navigation=true
		hovered_control=index
		if session.cursor!=index: SoundManager.play_sound(SoundManager.Sound.SELECTION_HOVER)
		session.cursor=index
		present()
func _unhover(index: int) -> void:
	if MenuInput.coop_mouse_blocked(): return
	if hovered_control==index:
		hovered_control=-1
		present()
func move_selector(direction: Vector2) -> void:
	if not session or session.rewards.is_empty(): return
	mouse_navigation=false
	var index=0 if direction.y<0 or direction.x<0 else 1
	if session.cursor!=index: SoundManager.play_sound(SoundManager.Sound.SELECTION_HOVER)
	session.cursor=index
	present()
func present() -> void:
	if not session or session.rewards.is_empty():
		show_waiting()
		return
	$Viewport.show()
	$Waiting.hide()
	card.preview_stats=session.actor.stats
	card.shop_wave=controller.arena.spawner.wave_index
	card.shop_item=session.rewards[0]
	card.item_cost.text="CONSERVAR"
	controls[1].text=""
	sell_value.text="VENDER %d" % session.rewards[0].get_sell_price(card.shop_wave)
	for i in 2:
		controls[i].disabled=session.disconnected
		UITheme.style_slot(controls[i],0)
		if (hovered_control==i if mouse_navigation else session.cursor==i):
			controls[i].add_theme_stylebox_override("normal",controls[i].get_theme_stylebox("hover").duplicate())
func show_waiting() -> void:
	$Viewport.hide()
	$Waiting.text="LISTO" if session else "JUGADOR NO CONECTADO"
	$Waiting.show()
func scroll_detail(amount: float) -> void:
	card.item_description.get_v_scroll_bar().value+=amount*2
