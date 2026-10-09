extends Panel
class_name UpgradeCard

@export var item: ItemUpgrade: set = _set_data

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription

func _set_data(value: ItemUpgrade) -> void:
	item = value
	
	if item_icon == null:
		await ready
	item_icon.texture = item.item_icon
	item_name.text = item.item_name
	var font := item_name.get_theme_font("font")
	var text_width := font.get_string_size(item.item_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
	item_name.add_theme_font_size_override("font_size", int(clampf(30.0 * 180.0 / maxf(text_width, 180.0), 16.0, 30.0)))
	item_description.text = item.description
	
	var style := Global.get_tier_style(item.item_tier)
	set_meta("ui_tier", int(item.item_tier))
	add_theme_stylebox_override("panel", style)


func _on_custom_button_pressed() -> void:
	if item:
		add_theme_stylebox_override("panel", UITheme.selected_tier_style(int(item.item_tier)))
		item.apply_upgrade()
		Global.on_upgrade_selected.emit()
		SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
