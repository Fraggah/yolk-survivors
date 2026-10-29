extends Panel
## Pending rewards survive wave cleanup, but never death or run reset.
signal resolved
var pending: Array[Dictionary] = []
var current: Dictionary = {}
var loot = load("res://resources/rewards/incognito_loot.tres")
var arena: Node
var heading: Label
var item_name: Label
var rarity: Label
var icon: TextureRect
var description: RichTextLabel
var keep_button: Button
var sell_button: Button
var card: PanelContainer
var _resolving := false

func _ready() -> void:
	card=get_node("CenterContainer1/PanelContainer0")
	description=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/RichTextLabel4")
	heading=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/Label0")
	icon=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/TextureRect2")
	item_name=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/Label3")
	keep_button=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/HBoxContainer5/Keep")
	rarity=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/Label1")
	sell_button=get_node("CenterContainer1/PanelContainer0/MarginContainer0/VBoxContainer0/HBoxContainer5/Sell")
	keep_button.pressed.connect(keep_current)
	sell_button.pressed.connect(sell_current)
func enqueue_drop(player: Player, wave: int) -> bool:
	var item: ItemPassive = loot.select_item(player,pending)
	if item==null: return false
	pending.append({"item":item,"wave":wave,"sell_value":item.get_sell_price(wave)})
	return true

func open_next() -> bool:
	if pending.is_empty():
		current.clear()
		hide()
		return false
	current=pending[0]
	var item: ItemPassive=current.item
	heading.text="INCOGNITO REWARD — %d LEFT" % pending.size()
	item_name.text=item.item_name
	rarity.text=["COMMON","RARE","EPIC","LEGENDARY"][item.item_tier]
	icon.texture=item.item_icon
	ItemBase.scale_icon(icon,item.icon_scale)
	description.text=UITheme.rich_text(item.get_description())
	card.add_theme_stylebox_override("panel",Global.get_tier_style(item.item_tier))
	var allowed: bool=is_instance_valid(Global.player) and item.available_for(Global.player)
	keep_button.disabled=not allowed
	keep_button.text="KEEP" if allowed else "LIMIT REACHED"
	sell_button.text="SELL — %d YOLKS" % current.sell_value
	show()
	if MenuInput.gamepad_active:
		(keep_button if allowed else sell_button).grab_focus()
	return true

func keep_current() -> void:
	_choose(true)

func sell_current() -> void:
	_choose(false)

func _choose(keep: bool) -> void:
	if _resolving or not is_visible_in_tree() or pending.is_empty() or current.is_empty() or not is_instance_valid(Global.player): return
	if keep and not current.item.available_for(Global.player):
		open_next()
		return
	_resolving=true
	var reward: Dictionary=pending.pop_front()
	current={}
	hide()
	if keep: arena.shop_panel._on_item_purchased(reward.item)
	else: Global.coins+=reward.sell_value
	_resolving=false
	resolved.emit()

func reset() -> void:
	pending.clear()
	current={}
	_resolving=false
	hide()
