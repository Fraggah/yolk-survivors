extends Button
class_name SelectionCard

func _ready() -> void:
	toggle_mode = true
	SlotSelectionStyle.apply(self, Global.COMMON_STYLE)

func set_icon(texture: Texture2D) -> void:
	icon = texture


func _on_mouse_entered() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)


func _on_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
