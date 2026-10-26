extends Control
var bar: ProgressBar
var caption: Label
var status: Label
var phase := 0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption = Label.new()
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",28)
	caption.add_theme_color_override("font_color",Color("fff0cc"))
	caption.add_theme_color_override("font_outline_color",Color("241610"))
	caption.add_theme_constant_override("outline_size",5)
	add_child(caption)
	bar = ProgressBar.new()
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background",UITheme.box(Color("301b18"),Color("d3b98c"),7,2))
	bar.add_theme_stylebox_override("fill",UITheme.box(Color("b7442a"),Color.TRANSPARENT,5,0))
	add_child(bar)
	for fraction in [1.0/3.0,2.0/3.0]:
		var mark := ColorRect.new()
		mark.color = Color("f2d8a6")
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(mark)
		mark.anchor_left = fraction
		mark.anchor_right = fraction
		mark.anchor_bottom = 1
		mark.offset_left = -1.5
		mark.offset_right = 1.5
		mark.offset_top = 2
		mark.offset_bottom = -2
	status = Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size",22)
	status.add_theme_color_override("font_color",Color("fff0cc"))
	status.add_theme_color_override("font_outline_color",Color("241610"))
	status.add_theme_constant_override("outline_size",5)
	add_child(status)
	resized.connect(_layout)
	_layout()
func _layout() -> void:
	if not is_instance_valid(bar): return
	var width := minf(1060,size.x-100)
	bar.position = Vector2((size.x-width)*0.5,size.y-68)
	bar.size = Vector2(width,28)
	caption.position = Vector2(bar.position.x,bar.position.y-42)
	caption.size = Vector2(width,38)
	status.position = Vector2(320,16)
	status.size = Vector2(maxf(100,size.x-640),60)
func show_boss(title: String, current: float, maximum: float) -> void:
	caption.text = title
	bar.max_value = maximum
	bar.value = current
	bar.show()
	caption.show()
func hide_boss() -> void:
	bar.hide()
	caption.hide()
