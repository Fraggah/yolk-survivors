extends Panel
class_name StatsContainer

@export var text_scale := 1.0
var bound_player: Player
var independent_navigation := false

const PRIMARY := ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "effects", "weapon_range", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]
const SECONDARY := ["slow_strength", "knockback", "experience_gain", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range", "piercing", "bounces", "dash_cooldown"]
const TITLES := {"dash_cooldown":"Dash cooldown:", "chili_power":"Chili Power:", "explosive_damage":"Explosive damage:","slow_strength":"Slow potency:", "weapon_range":"Range:", "knockback":"Push:", "experience_gain":"Experience gain:", "critical_multiplier":"Crit multiplier bonus:", "area_of_effect":"Area of effect:", "effects":"Effects:", "crowd_control":"Crowd control:", "fire_tick_speed":"Fire tick speed:", "block_effectiveness":"Block Power:", "piercing":"Piercing:", "bounces":"Bounces:"}
const PERCENT_STATS := ["slow_strength", "experience_gain", "life_steal", "damage_percent", "attack_speed", "critical_chance", "block_chance", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range"]

@onready var health_label: Label = %HealthLabel
@onready var hp_regen_label: Label = %HpRegenLabel
@onready var life_steal_label: Label = %LifeStealLabel
@onready var damage_label: Label = %DamageLabel
@onready var melee_damage_label: Label = %MeleeDamageLabel
@onready var ranged_damage_label: Label = %RangedDamageLabel
@onready var attack_speed_label: Label = %AttackSpeedLabel
@onready var luck_label: Label = %LuckLabel
@onready var speed_label: Label = %SpeedLabel
@onready var block_label: Label = %BlockLabel
@onready var armor_label: Label = %ArmorLabel
@onready var critical_chance_label: Label = %CriticalChanceLabel
@onready var pickup_range_label: Label = %PickupRangeLabel
@onready var harvesting_label: Label = %HarvestingLabel

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
	hp_regen_label.get_parent().tooltip_text = "Each point restores 0.1 HP per second, in small pulses."
	var layout := $MarginContainer/VBoxContainer
	layout.add_theme_constant_override("separation", 3)
	stat_labels = {"health":health_label, "hp_regen":hp_regen_label, "life_steal":life_steal_label, "damage_percent":damage_label, "melee_damage":melee_damage_label, "ranged_damage":ranged_damage_label, "attack_speed":attack_speed_label, "critical_chance":critical_chance_label, "armor":armor_label, "block_chance":block_label, "speed":speed_label, "luck":luck_label, "harvesting":harvesting_label, "pickup_range":pickup_range_label}
	for stat in TITLES:
		var row := Panel.new()
		row.theme_type_variation = &"InsetPanel"
		layout.add_child(row)
		var title := Label.new()
		title.name = "Title"
		title.text = TITLES[stat]
		row.add_child(title)
		var value := Label.new()
		row.add_child(value)
		stat_labels[stat] = value
		extra_labels[stat] = value
	for stat in stat_labels:
		var value: Label = stat_labels[stat]
		var row := value.get_parent() as Panel
		stat_rows[stat] = row
		var title := row.get_node("Title") as Label
		title.add_theme_font_size_override("font_size", roundi(23*text_scale))
		value.add_theme_font_size_override("font_size", roundi(23*text_scale))
		var line := HBoxContainer.new()
		row.add_child(line)
		line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		line.offset_left = 10
		line.offset_right = -13
		title.reparent(line)
		value.reparent(line)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.minimum_size_changed.connect(_fit_content)
		row.tooltip_text = ""
		var target := Button.new()
		target.name = "StatHelpTarget"
		target.flat = true
		target.mouse_default_cursor_shape = Control.CURSOR_HELP
		row.add_child(target)
		target.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		target.mouse_entered.connect(_show_stat_help.bind(target, title.text))
		target.focus_entered.connect(_show_stat_help.bind(target, title.text))
	tabs = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	layout.add_child(tabs)
	layout.move_child(tabs, 0)
	var group := ButtonGroup.new()
	primary_button = _tab("Primary", group)
	secondary_button = _tab("Secondary", group)
	primary_button.pressed.connect(show_primary)
	secondary_button.pressed.connect(func(): show_secondary(true))
	var index := 1
	for stat in PRIMARY + SECONDARY:
		layout.move_child(stat_rows[stat], index)
		index += 1
	hint = Label.new()
	hint.text = "TAB / Y  ·  Switch stats"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	layout.add_child(hint)
	visibility_changed.connect(_on_visibility_changed)
	_build_stat_help()
	show_primary()
	call_deferred("_fit_content")

func _tab(caption: String, group: ButtonGroup) -> Button:
	var button := Button.new()
	button.text = caption
	button.toggle_mode = true
	button.button_group = group
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 44
	button.add_theme_font_size_override("font_size", roundi(25*text_scale))
	tabs.add_child(button)
	return button

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
	if is_visible_in_tree() and is_instance_valid(primary_button): show_primary()

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
	if not is_instance_valid(tabs) or not is_instance_valid(hint): return
	var width := 0.0
	var heights := {}
	for stat in stat_rows:
		var row: Panel = stat_rows[stat]
		var content: Vector2 = row.get_child(0).get_combined_minimum_size()
		row.custom_minimum_size = Vector2(content.x + 23, maxf(32, content.y))
		width = maxf(width, row.custom_minimum_size.x)
		heights[stat] = row.custom_minimum_size.y
	var max_height := 0.0
	for page in [PRIMARY, SECONDARY]:
		var height: float = (tabs.get_combined_minimum_size().y if tabs.visible else 0.0) + (hint.get_combined_minimum_size().y if hint.visible else 0.0) + (page.size() + 1) * 3
		for stat in page: height += heights[stat]
		max_height = maxf(max_height, height)
	custom_minimum_size = Vector2(maxf(480,width + 32), maxf(650,max_height + 32))

func _build_stat_help() -> void:
	stat_help = PanelContainer.new()
	stat_help.name = "StatHelp"
	stat_help.top_level = true
	stat_help.z_index = 110
	stat_help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stat_help.add_theme_stylebox_override("panel", UITheme.box(UITheme.palette.surface, UITheme.palette.outline, 14, 2))
	add_child(stat_help)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stat_help.add_child(margin)
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)
	stat_help_title = Label.new()
	stat_help_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stat_help_title.add_theme_font_size_override("font_size", 26)
	content.add_child(stat_help_title)
	var description := Label.new()
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description.custom_minimum_size.x = 350
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 22)
	description.text = HELP_TEXT
	content.add_child(description)
	stat_help.hide()

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
