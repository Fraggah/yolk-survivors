extends Panel
class_name StatsContainer

const PRIMARY := ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]
const SECONDARY := ["critical_multiplier", "area_of_effect", "effects", "fire_tick_speed", "block_effectiveness", "pickup_range", "piercing", "bounces"]
const TITLES := {"critical_multiplier":"Crit multiplier bonus:", "area_of_effect":"Area of effect:", "effects":"Effects:", "fire_tick_speed":"Fire tick speed:", "block_effectiveness":"Block Power:", "piercing":"Piercing:", "bounces":"Bounces:"}
const PERCENT_STATS := ["life_steal", "damage_percent", "attack_speed", "critical_chance", "block_chance", "critical_multiplier", "area_of_effect", "effects", "fire_tick_speed", "block_effectiveness", "pickup_range"]

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

var extra_labels: Dictionary = {}
var stat_labels: Dictionary = {}
var stat_rows: Dictionary = {}
var secondary_visible := false
var primary_button: Button
var secondary_button: Button
var tabs: HBoxContainer
var hint: Label

func _ready() -> void:
	var layout := $MarginContainer/VBoxContainer
	layout.add_theme_constant_override("separation", 5)
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
		title.add_theme_font_size_override("font_size", 23)
		value.add_theme_font_size_override("font_size", 23)
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
	show_primary()
	call_deferred("_fit_content")

func _tab(caption: String, group: ButtonGroup) -> Button:
	var button := Button.new()
	button.text = caption
	button.toggle_mode = true
	button.button_group = group
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 44
	button.add_theme_font_size_override("font_size", 25)
	tabs.add_child(button)
	return button

func show_primary() -> void:
	show_secondary(false)

func show_secondary(value: bool = true) -> void:
	secondary_visible = value
	for stat in stat_rows: stat_rows[stat].visible = (stat in SECONDARY) == value
	primary_button.set_pressed_no_signal(not value)
	secondary_button.set_pressed_no_signal(value)
	_update_values()
	call_deferred("_fit_content")

func _on_visibility_changed() -> void:
	if is_visible_in_tree() and is_instance_valid(primary_button): show_primary()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	var menu: Control = MenuInput._visible_menu()
	if not is_instance_valid(menu) or not menu.is_ancestor_of(self): return
	var keyboard: bool = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB and not event.ctrl_pressed and not event.alt_pressed
	var gamepad: bool = event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_Y
	if keyboard or gamepad:
		show_secondary(not secondary_visible)
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if is_visible_in_tree(): _update_values()

func _update_values() -> void:
	if not is_instance_valid(Global.player): return
	for stat in stat_labels:
		stat_labels[stat].text = ItemWeapon.format_number(Global.player.stats.get(stat)) + ("%" if stat in PERCENT_STATS else "")

func _fit_content() -> void:
	if not is_instance_valid(tabs) or not is_instance_valid(hint): return
	var width := 0.0
	var heights := {}
	for stat in stat_rows:
		var row: Panel = stat_rows[stat]
		var content: Vector2 = row.get_child(0).get_combined_minimum_size()
		row.custom_minimum_size = Vector2(content.x + 23, maxf(34, content.y))
		width = maxf(width, row.custom_minimum_size.x)
		heights[stat] = row.custom_minimum_size.y
	var max_height := 0.0
	for page in [PRIMARY, SECONDARY]:
		var height: float = tabs.get_combined_minimum_size().y + hint.get_combined_minimum_size().y + (page.size() + 1) * 5
		for stat in page: height += heights[stat]
		max_height = maxf(max_height, height)
	custom_minimum_size = Vector2(maxf(480,width + 32), maxf(650,max_height + 32))
