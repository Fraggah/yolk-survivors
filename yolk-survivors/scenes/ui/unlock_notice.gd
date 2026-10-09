extends PanelContainer

var pending: Array[String] = []
var remaining := 0.0
var caption: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	offset_left = -350.0
	offset_right = 350.0
	offset_top = 90.0
	z_index = 20
	var style := StyleBoxFlat.new()
	style.bg_color = Color("875649")
	style.border_color = Color("ffe395")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	add_theme_stylebox_override("panel", style)
	caption = Label.new()
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 26)
	add_child(caption)
	Progression.unlock_earned.connect(_on_unlock_earned)
	hide()

func _on_unlock_earned(reward: String) -> void:
	pending.append(reward)

func _process(delta: float) -> void:
	remaining -= delta
	if remaining > 0.0: return
	if pending.is_empty():
		hide()
		return
	caption.text = "Unlocked: " + pending.pop_front()
	remaining = 3.0
	show()
