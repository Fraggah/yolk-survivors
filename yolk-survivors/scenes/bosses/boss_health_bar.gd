extends Control
var bar: ProgressBar
var caption: Label
var status: Label
var phase := 0
func _ready() -> void:
	bar=get_node("ProgressBar1")
	caption=get_node("Label0")
	status=get_node("Label2")

func show_boss(title: String, current: float, maximum: float) -> void:
	caption.text = title
	bar.max_value = maximum
	bar.value = current
	bar.show()
	caption.show()
func hide_boss() -> void:
	bar.hide()
	caption.hide()
