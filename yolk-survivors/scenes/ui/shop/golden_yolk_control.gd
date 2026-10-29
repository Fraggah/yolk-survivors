extends Button
## The confirmation only arms selection. A charge is spent on a valid target.
signal target_selected(card: ItemCard)
var shop: ShopPanel
@export var kind := "golden_yolk"
@export var display_name := "Yema de oro"
var selecting := false
var confirmation: ConfirmationDialog
var hint_label: Label

func _ready() -> void:
	confirmation=$Confirmation
	hint_label=$Hint
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
	refresh()

func _charges() -> int:
	if not is_instance_valid(Global.player): return 0
	return Global.player.passive_items.breading_charges if kind == "breading" else Global.player.passive_items.golden_yolks

func refresh() -> void:
	visible = _charges() > 0 or selecting
	text = ""
	$Count.text = str(_charges())
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
