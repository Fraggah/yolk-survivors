extends Button
## The confirmation only arms selection. A charge is spent on a valid target.
signal target_selected(card: ItemCard)
var shop: ShopPanel
var kind := "golden_yolk"
var display_name := "Yema de oro"
var selecting := false
var confirmation: ConfirmationDialog
var hint_label: Label

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon = load("res://assets/sprites/Items/Catalogue/%s.png" % ("081" if kind == "breading" else "078"))
	expand_icon = true
	custom_minimum_size = Vector2(140, 60)
	add_theme_constant_override("icon_max_width", 48)
	add_theme_font_size_override("font_size", 28)
	tooltip_text = "Seleccioná un arma propia para agregar una tag aleatoria nueva." if kind == "breading" else "Usá una Yema de oro en un arma o ítem propio."
	confirmation = ConfirmationDialog.new()
	confirmation.title = display_name
	confirmation.dialog_text = "¿Usar una Yema de oro?\nDespués, elegí un arma o ítem de tu inventario.\n25% de probabilidad de destruirlo."
	if kind == "breading": confirmation.dialog_text = "¿Usar un Rebozado?\nDespués, elegí un arma de tu inventario.\nRecibirá una tag aleatoria que todavía no tenga."
	confirmation.ok_button_text = "Elegir arma" if kind == "breading" else "Elegir ítem"
	confirmation.cancel_button_text = "Cancelar"
	add_child(confirmation)
	confirmation.confirmed.connect(func():
		shop.cancel_consumable_selection(self)
		selecting = true
		shop.close_weapon_actions()
		refresh()
	)
	pressed.connect(func():
		if selecting:
			cancel_selection()
		elif _charges() > 0:
			confirmation.popup_centered(Vector2i(590, 210))
	)
	hint_label = Label.new()
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_label.add_theme_font_size_override("font_size", 20)
	hint_label.position = Vector2(0, -32)
	add_child(hint_label)
	refresh()

func _charges() -> int:
	if not is_instance_valid(Global.player): return 0
	return Global.player.passive_items.breading_charges if kind == "breading" else Global.player.passive_items.golden_yolks

func refresh() -> void:
	visible = _charges() > 0 or selecting
	text = "× %d" % _charges()
	disabled = _charges() <= 0 and not selecting
	hint_label.text = ""
	tooltip_text = ("Elegí un arma; pulsá de nuevo para cancelar." if kind == "breading" else "Elegí un ítem; pulsá de nuevo para cancelar.") if selecting else display_name

func cancel_selection() -> void:
	selecting = false
	confirmation.hide()
	refresh()

func try_select(card: ItemCard) -> bool:
	if not selecting: return false
	target_selected.emit(card)
	return true
