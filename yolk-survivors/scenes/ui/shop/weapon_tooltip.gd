extends PanelContainer
class_name WeaponTooltip

@export var manual_selection := false
@export var show_full_description := false
var preview_stats: UnitStats
var shop_wave_override := -1
@onready var scroll_hint: Label=$MarginContainer/Content/ScrollHint
@onready var full_description: RichTextLabel = $MarginContainer/Content/FullDescription

const SCREEN_MARGIN := 12.0
const SLOT_GAP := 10.0

@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_name: Label = %WeaponName
@onready var weapon_type: Label = %WeaponType
@onready var stats_grid: GridContainer = %StatsGrid

var passive_description: Label
var hovered_card: ItemCard
var displayed_weapon: ItemWeapon
var value_labels: Array[RichTextLabel] = []

func _ready() -> void:
	passive_description=$MarginContainer/Content/PassiveDescription
	for i in 9:
		var cell=stats_grid.get_node("Value%d" % i) if i!=7 else stats_grid.get_node("ValueSaleMargin/Value7")
		value_labels.append(cell)
	set_process(false)

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in control.get_children():
		if child is Control:
			_ignore_mouse(child)

func show_for_card(card: ItemCard) -> void:
	if not card.item or not card.is_visible_in_tree(): return
	hovered_card = card
	if card.item is ItemWeapon:
		if not card.item.stats: return
		_update_weapon(card.item)
	elif card.item is ItemPassive:
		_update_passive(card.item)
	else: return
	show()
	set_process(true)
	_position_above_card()

func dismiss() -> void:
	hovered_card = null
	displayed_weapon = null
	hide()
	set_process(false)

func hide_for_card(card: ItemCard) -> void:
	if hovered_card == card:
		dismiss()

func _process(_delta: float) -> void:
	if not is_instance_valid(hovered_card) or hovered_card.is_queued_for_deletion():
		dismiss()
		return
	if not hovered_card.is_visible_in_tree() or (not manual_selection and not hovered_card.has_focus() and not hovered_card.get_global_rect().has_point(get_global_mouse_position())):
		dismiss()
		return
	if hovered_card.item is ItemWeapon:
		_update_weapon(hovered_card.item)
	elif hovered_card.item is ItemPassive:
		_update_passive(hovered_card.item)
	else:
		dismiss()
		return
	var bar=full_description.get_v_scroll_bar()
	scroll_hint.visible=show_full_description and full_description.visible and bar.max_value>bar.page
	_position_above_card()

func _update_weapon(weapon: ItemWeapon) -> void:
	stats_grid.show()
	passive_description.hide()
	displayed_weapon = weapon
	weapon_icon.texture = weapon.item_icon
	ItemBase.scale_icon(weapon_icon, weapon.icon_scale)
	weapon_name.text = weapon.item_name
	weapon_type.text = weapon.get_category_label()
	weapon_type.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var style := Global.get_tier_style(weapon.item_tier).duplicate() as StyleBoxFlat
	style.bg_color = UITheme.palette.surface
	style.set_border_width_all(2)
	style.shadow_color = UITheme.palette.shadow_color
	style.shadow_size = UITheme.palette.shadow_size
	add_theme_stylebox_override("panel", style)
	var stats := weapon.stats
	stats_grid.get_child(0).text = weapon.damage_label
	var values: Array[String] = [
		weapon.get_direct_damage_description(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null),
		"%s s" % _format_number(weapon.get_display_cooldown(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null)),
		_format_number(weapon.get_effective_range(preview_stats)) if preview_stats else weapon.get_range_description(),
		"%s%%" % _format_number(weapon.get_effective_critical_chance(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null) * 100.0),
		"%s%%" % _format_number(weapon.get_effective_life_steal(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null) * 100.0),
		"∞" if stats.unlimited_piercing else str(weapon.get_effective_piercing(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null)),
		str(weapon.get_effective_bounces(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null)),
		str(weapon.get_sell_price(shop_wave_override if shop_wave_override>=0 else (get_parent() as ShopPanel).shop_wave if get_parent() is ShopPanel else 1)),
		"%s x" % _format_number(weapon.get_effective_critical_multiplier(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null))
	]
	for index in values.size():
		var show_stat := index < 5 or index >= 7 or (weapon.has_tag(ItemWeapon.Tag.RANGED) and ((index == 5 and stats.unlimited_piercing) or int(values[index]) > 0))
		if index == 6: show_stat = show_stat and weapon.shows_bounce_count()
		if index in [2, 3, 8]: show_stat = show_stat and not weapon.has_tag(ItemWeapon.Tag.CHILI)
		stats_grid.get_child(index * 2).visible = show_stat
		value_labels[index].visible = show_stat
		value_labels[index].add_theme_color_override("default_color", UITheme.palette.positive)
		value_labels[index].text = "[right]%s[/right]" % UITheme.rich_text(values[index])
	full_description.visible=show_full_description
	if show_full_description:
		var extra: PackedStringArray=[]
		for line in weapon.get_description(preview_stats).split("\n"):
			if line.get_slice(":",0).strip_edges().to_lower() not in [weapon.damage_label.to_lower(),"cooldown","range","critical chance","life steal","piercing","bounces"]: extra.append(line)
		var description=UITheme.rich_text("\n".join(extra))
		if full_description.text!=description: full_description.text=description
		full_description.visible=not extra.is_empty()
	reset_size()

func _update_passive(item: ItemPassive) -> void:
	full_description.hide()
	displayed_weapon = null
	stats_grid.hide()
	passive_description.show()
	weapon_icon.texture = item.item_icon
	ItemBase.scale_icon(weapon_icon, item.icon_scale)
	weapon_name.text = item.item_name
	weapon_type.text = "Passive" + (" · ×%d" % hovered_card.quantity if hovered_card.quantity > 1 else "")
	var style := Global.get_tier_style(item.item_tier).duplicate() as StyleBoxFlat
	style.bg_color = UITheme.palette.surface
	style.set_border_width_all(2)
	style.shadow_color = UITheme.palette.shadow_color
	style.shadow_size = UITheme.palette.shadow_size
	add_theme_stylebox_override("panel", style)
	passive_description.text = item.get_description()
	if item.golden_multiplier > 1.0:
		passive_description.text += "\nBeneficios ×%s · Penalizaciones ×%s%s" % [ItemWeapon.format_number(item.golden_multiplier), ItemWeapon.format_number(item.golden_penalty_multiplier), " · Perfecta" if item.golden_perfect else ""]
	if show_full_description:
		passive_description.hide()
		full_description.show()
		if full_description.text!=passive_description.text: full_description.text=passive_description.text
	reset_size()

func _format_number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func _position_above_card() -> void:
	# Work in the parent's coordinates: co-op canvases are scaled per quadrant.
	var parent_control=get_parent() as Control
	var slot_rect: Rect2=parent_control.get_global_transform().affine_inverse()*hovered_card.get_global_rect()
	var bounds:=Rect2(Vector2.ZERO,parent_control.size).grow(-SCREEN_MARGIN)
	var target:=Vector2(slot_rect.get_center().x-size.x*.5,slot_rect.position.y-size.y-SLOT_GAP)
	if target.y<bounds.position.y: target.y=slot_rect.end.y+SLOT_GAP
	position=target.clamp(bounds.position,(bounds.end-size).max(bounds.position))
