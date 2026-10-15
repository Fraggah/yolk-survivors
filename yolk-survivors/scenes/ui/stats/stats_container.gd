extends Panel
class_name StatsContainer

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

func _process(_delta: float) -> void:
	if not is_instance_valid(Global.player): return
	
	health_label.text = ItemWeapon.format_number(Global.player.stats.health)
	hp_regen_label.text = ItemWeapon.format_number(Global.player.stats.hp_regen)
	life_steal_label.text = str(Global.player.stats.life_steal) + "%"
	damage_label.text = str(Global.player.stats.damage_percent) + "%"
	melee_damage_label.text = str(Global.player.stats.melee_damage)
	ranged_damage_label.text = str(Global.player.stats.ranged_damage)
	attack_speed_label.text = str(Global.player.stats.attack_speed) + "%"
	luck_label.text = str(Global.player.stats.luck)
	block_label.text = str(Global.player.stats.block_chance) + "%"
	speed_label.text = str(Global.player.stats.speed)
	harvesting_label.text = str(Global.player.stats.harvesting)
	armor_label.text = ItemWeapon.format_number(Global.player.stats.armor)
	critical_chance_label.text = ItemWeapon.format_number(Global.player.stats.critical_chance) + "%"
	pickup_range_label.text = ItemWeapon.format_number(Global.player.stats.pickup_range) + "%"

func _ready() -> void:
	var layout := $MarginContainer/VBoxContainer
	for row in layout.get_children():
		var title := row.get_node("Title") as Label
		var value := row.get_child(1) as Label
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
	call_deferred("_fit_content")

func _fit_content() -> void:
	var layout := $MarginContainer/VBoxContainer
	for row in layout.get_children():
		var line := row.get_child(0) as HBoxContainer
		if line:
			var content_size := line.get_combined_minimum_size()
			row.custom_minimum_size = Vector2(content_size.x+23,maxf(36,content_size.y))
	var needed: Vector2 = layout.get_combined_minimum_size() + Vector2(32,32)
	custom_minimum_size = Vector2(maxf(480,needed.x),maxf(650,needed.y))
