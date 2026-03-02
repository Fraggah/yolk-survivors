extends Panel
class_name OptionsPanel

signal on_options_exited
signal on_load_game

@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/HBoxContainer2/SFXSlider
@onready var message: Label = $Message


func _ready() -> void:
	music_slider.value = SoundManager.music_volume
	sfx_slider.value = SoundManager.sfx_volume

func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)


func _on_custom_button_pressed() -> void:
	on_options_exited.emit()


func _on_save_game_button_pressed() -> void:
	DataManager.save_game()
	show_message("Game Saved")


func _on_load_game_button_pressed() -> void:
	if DataManager.load_game():
		music_slider.value = SoundManager.music_volume
		sfx_slider.value = SoundManager.sfx_volume
		on_load_game.emit()
		show_message("Game Loaded")
	else:
		show_message("No Save Data Found")

func show_message(text: String) -> void:
	message.text = text
	message.show()
	message.modulate.a = 1
	var tween := create_tween()
	tween.tween_property(message, "modulate:a", 0, 3)
	await tween.finished
	message.hide()
