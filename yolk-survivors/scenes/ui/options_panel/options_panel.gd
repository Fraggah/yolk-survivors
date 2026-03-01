extends Panel
class_name OptionsPanel

signal on_options_exited

@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/HBoxContainer2/SFXSlider

func _ready() -> void:
	music_slider.value = SoundManager.music_volume
	sfx_slider.value = SoundManager.sfx_volume

func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)


func _on_custom_button_pressed() -> void:
	on_options_exited.emit()
