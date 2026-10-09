extends PanelContainer
class_name WeaponTooltip

const SCREEN_MARGIN := 12.0
const SLOT_GAP := 10.0

@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_name: Label = %WeaponName
@onready var weapon_type: Label = %WeaponType
@onready var stats_grid: GridContainer = %StatsGrid

var hovered_card: ItemCard
var displayed_weapon: ItemWeapon
var value_labels: Array[Label] = []

func _ready() -> void:
	_ignore_mouse(self)
	for stat_name: String in ["Damage", "Scaling", "Cooldown", "Range", "Critical chance", "Knockback", "Life steal"]:
		var caption := Label.new()
		caption.text = stat_name
		caption.add_theme_font_size_override("font_size", 22)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stats_grid.add_child(caption)
		var value := Label.new()
		value.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.add_theme_font_size_override("font_size", 22)
		value.set_meta("ui_color", "positive")
		stats_grid.add_child(value)
		value_labels.append(value)
	hide()
	set_process(false)

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in control.get_children():
		if child is Control:
			_ignore_mouse(child)

func show_for_card(card: ItemCard) -> void:
	if not card.item is ItemWeapon or not card.is_visible_in_tree(): return
	var weapon := card.item as ItemWeapon
	if not weapon.stats: return
	hovered_card = card
	_update_weapon(weapon)
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
	if not hovered_card.is_visible_in_tree() or (not hovered_card.has_focus() and not hovered_card.get_global_rect().has_point(get_global_mouse_position())):
		dismiss()
		return
	if not hovered_card.item is ItemWeapon:
		dismiss()
		return
	_update_weapon(hovered_card.item as ItemWeapon)
	_position_above_card()

func _update_weapon(weapon: ItemWeapon) -> void:
	displayed_weapon = weapon
	weapon_icon.texture = weapon.item_icon
	weapon_name.text = weapon.item_name
	weapon_type.text = "Ranged weapon" if weapon.type == ItemWeapon.Type.RANGE else "Melee weapon"
	var style := Global.get_tier_style(weapon.item_tier).duplicate() as StyleBoxFlat
	style.bg_color = UITheme.palette.surface
	style.set_border_width_all(2)
	style.shadow_color = UITheme.palette.shadow_color
	style.shadow_size = UITheme.palette.shadow_size
	add_theme_stylebox_override("panel", style)
	var stats := weapon.stats
	var values: Array[String] = [
		_format_number(weapon.get_effective_damage(Global.player.stats if is_instance_valid(Global.player) else null)),
		"%s%% %s" % [_format_number(stats.damage_scaling * 100.0), "melee" if weapon.type == ItemWeapon.Type.MELEE else "ranged"],
		"%s s" % _format_number(weapon.get_effective_cooldown(Global.player.stats if is_instance_valid(Global.player) else null)),
		_format_number(stats.max_range),
		"%s%%" % _format_number(stats.crit_chance * 100.0),
		_format_number(stats.knockback),
		"%s%%" % _format_number(stats.life_steal * 100.0)
	]
	for index in values.size():
		value_labels[index].text = values[index]
	reset_size()

func _format_number(value: float) -> String:
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")

func _position_above_card() -> void:
	var slot_rect := hovered_card.get_global_rect()
	var bounds := (get_parent() as Control).get_global_rect().grow(-SCREEN_MARGIN)
	var target := Vector2(slot_rect.get_center().x - size.x * 0.5, slot_rect.position.y - size.y - SLOT_GAP)
	if target.y < bounds.position.y:
		target.y = slot_rect.end.y + SLOT_GAP
	target.x = clampf(target.x, bounds.position.x, maxf(bounds.position.x, bounds.end.x - size.x))
	target.y = clampf(target.y, bounds.position.y, maxf(bounds.position.y, bounds.end.y - size.y))
	global_position = target
