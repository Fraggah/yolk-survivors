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
	name = "IncognitoRewards"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 15
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var dim := ColorRect.new()
	dim.color = Color(0.08,0.06,0.04,0.8)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card = PanelContainer.new()
	card.custom_minimum_size = Vector2(680,800)
	center.add_child(card)
	var margin := MarginContainer.new()
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,28)
	card.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",14)
	margin.add_child(content)
	heading=_label(content,"INCOGNITO REWARD",40)
	rarity=_label(content,"",30)
	icon=TextureRect.new()
	icon.custom_minimum_size=Vector2(220,220)
	icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	content.add_child(icon)
	item_name=_label(content,"",40)
	description=RichTextLabel.new()
	description.bbcode_enabled=true
	description.custom_minimum_size=Vector2(600,170)
	description.add_theme_font_size_override("normal_font_size",28)
	description.add_theme_color_override("default_color",UITheme.palette.text)
	content.add_child(description)
	var buttons:=HBoxContainer.new()
	buttons.add_theme_constant_override("separation",16)
	content.add_child(buttons)
	keep_button=Button.new()
	keep_button.name="Keep"
	keep_button.text="KEEP"
	keep_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	keep_button.custom_minimum_size=Vector2(0,80)
	keep_button.add_theme_font_size_override("font_size",32)
	buttons.add_child(keep_button)
	sell_button=Button.new()
	sell_button.name="Sell"
	sell_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	sell_button.custom_minimum_size=Vector2(0,80)
	sell_button.add_theme_font_size_override("font_size",30)
	buttons.add_child(sell_button)
	keep_button.pressed.connect(keep_current)
	sell_button.pressed.connect(sell_current)
	hide()

func _label(parent: Node, value: String, font_size: int) -> Label:
	var label:=Label.new()
	label.text=value
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",UITheme.palette.text)
	parent.add_child(label)
	return label

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
