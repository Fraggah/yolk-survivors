extends Panel
class_name StatsContainer

@export var initial_secondary := false
var bound_player: Player
var independent_navigation := false

const PRIMARY := ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "effects", "weapon_range", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]
const SECONDARY := ["slow_strength", "knockback", "experience_gain", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range", "piercing", "bounces", "dash_cooldown"]
const TITLES := {"dash_cooldown":"Dash cooldown:", "chili_power":"Chili Power:", "explosive_damage":"Explosive damage:","slow_strength":"Slow potency:", "weapon_range":"Range:", "knockback":"Push:", "experience_gain":"Experience gain:", "critical_multiplier":"Crit multiplier bonus:", "area_of_effect":"Area of effect:", "effects":"Effects:", "crowd_control":"Crowd control:", "fire_tick_speed":"Fire tick speed:", "block_effectiveness":"Block Power:", "piercing":"Piercing:", "bounces":"Bounces:"}
const PERCENT_STATS := ["speed", "slow_strength", "experience_gain", "damage_percent", "attack_speed", "critical_chance", "block_chance", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range"]

const HELP_TEXT := "Esta estadística modifica las capacidades de tu personaje. Descripción provisional: más adelante detallaremos su efecto y cómo se calcula."
var stat_help: PanelContainer
var stat_help_title: Label
var help_target: Button
var extra_labels: Dictionary = {}
var stat_labels: Dictionary = {}
var stat_rows: Dictionary = {}
var secondary_visible := false
var primary_button: Button
var secondary_button: Button
var tabs: HBoxContainer
var hint: Label

func _ready() -> void:
	var layout=$MarginContainer/VBoxContainer
	for stat in PRIMARY+SECONDARY:
		var row=layout.get_node(stat)
		stat_rows[stat]=row
		stat_labels[stat]=row.get_node("Line/Value")
		var title=row.get_node("Line/Title")
		var target=row.get_node("StatHelpTarget")
		target.mouse_entered.connect(_show_stat_help.bind(target,title.text))
		target.focus_entered.connect(_show_stat_help.bind(target,title.text))
	tabs=layout.get_node("Tabs")
	primary_button=tabs.get_node("Primary")
	secondary_button=tabs.get_node("Secondary")
	hint=layout.get_node("Hint")
	stat_help=$StatHelp
	stat_help_title=$StatHelp/Margin/Content/Title
	primary_button.pressed.connect(show_primary)
	secondary_button.pressed.connect(func(): show_secondary(true))
	visibility_changed.connect(_on_visibility_changed)
	show_secondary(initial_secondary)

func show_primary() -> void:
	show_secondary(false)

func show_secondary(value: bool = true) -> void:
	if is_instance_valid(stat_help): stat_help.hide()
	help_target = null
	secondary_visible = value
	for stat in stat_rows: stat_rows[stat].visible = (stat in SECONDARY) == value
	primary_button.set_pressed_no_signal(not value)
	secondary_button.set_pressed_no_signal(value)
	_update_values()
	call_deferred("_fit_content")

func _on_visibility_changed() -> void:
	if is_instance_valid(stat_help): stat_help.hide()
	if is_visible_in_tree() and is_instance_valid(primary_button): show_secondary(initial_secondary)

func _input(event: InputEvent) -> void:
	if independent_navigation or not is_visible_in_tree(): return
	var menu: Control = MenuInput._visible_menu()
	if not is_instance_valid(menu) or not menu.is_ancestor_of(self): return
	var keyboard: bool = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB and not event.ctrl_pressed and not event.alt_pressed
	var gamepad: bool = event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_Y
	if keyboard or gamepad:
		show_secondary(not secondary_visible)
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if is_visible_in_tree(): _update_values()
	if is_instance_valid(stat_help) and stat_help.visible:
		if not is_instance_valid(help_target) or not help_target.is_visible_in_tree() or (not help_target.has_focus() and not help_target.get_global_rect().has_point(get_global_mouse_position())):
			stat_help.hide()
		else:
			_position_stat_help()

func _update_values() -> void:
	var player: Player=bound_player if is_instance_valid(bound_player) else Global.player
	if not is_instance_valid(player): return
	for stat in stat_labels:
		if stat == "dash_cooldown":
			stat_labels[stat].text = ItemWeapon.format_number(player.get_dash_cooldown()) + " s"
			continue
		var value: float = player.stats.get_block_chance() if stat == "block_chance" else float(player.stats.get(stat))
		stat_labels[stat].text = ItemWeapon.format_number(value) + ("%" if stat in PERCENT_STATS else "")

func _fit_content() -> void:
	# Kept as a compatibility hook; scene containers own the layout.
	pass

func _show_stat_help(target: Button, caption: String) -> void:
	if not is_instance_valid(stat_help): return
	help_target = target
	stat_help_title.text = caption.trim_suffix(":")
	stat_help.reset_size()
	stat_help.show()
	_position_stat_help()

func _position_stat_help() -> void:
	var slot := help_target.get_global_rect()
	var bounds := get_viewport_rect().grow(-12)
	var point := Vector2(slot.position.x - stat_help.size.x - 12, slot.position.y)
	if point.x < bounds.position.x: point.x = slot.end.x + 12
	point.x = clampf(point.x, bounds.position.x, maxf(bounds.position.x, bounds.end.x - stat_help.size.x))
	point.y = clampf(point.y, bounds.position.y, maxf(bounds.position.y, bounds.end.y - stat_help.size.y))
	stat_help.global_position = point
