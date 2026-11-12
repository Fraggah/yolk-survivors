extends Panel
class_name OptionsPanel

signal on_options_exited

@onready var tabs: Array[Button] = [%AudioTab, %DisplayTab, %ProgressTab]
@onready var pages: Array[Control] = [%Audio, %Display, %Progress]

func _ready() -> void:
	%MasterSlider.set_value_no_signal(DataManager.master_volume)
	%MusicSlider.set_value_no_signal(SoundManager.music_volume)
	%SFXSlider.set_value_no_signal(SoundManager.sfx_volume)
	%MasterSlider.value_changed.connect(DataManager.set_master_volume)
	%MusicSlider.value_changed.connect(SoundManager.set_music_volume)
	%SFXSlider.value_changed.connect(SoundManager.set_sfx_volume)
	for index in tabs.size():
		tabs[index].pressed.connect(_select_page.bind(index))
	%Back.pressed.connect(_on_custom_button_pressed)
	%ThemeButton.pressed.connect(_cycle_palette)
	%ScreenButton.pressed.connect(_toggle_fullscreen)
	%VSyncButton.pressed.connect(_toggle_vsync)
	%UnlockAll.pressed.connect(_change_progress.bind(false))
	%ResetProgress.pressed.connect(_request_reset)
	%ConfirmReset.pressed.connect(_change_progress.bind(true))
	%CancelReset.pressed.connect(_cancel_reset)
	%ProgressTab.visible = OS.is_debug_build()
	_refresh_display()

func _select_page(index: int) -> void:
	for tab in tabs.size():
		tabs[tab].set_pressed_no_signal(tab == index)
		pages[tab].visible = tab == index
	%Confirmation.hide()
	%ResetProgress.disabled = false

func _refresh_display() -> void:
	var theme_id: String = UITheme.PALETTES.find_key(UITheme.palette)
	%ThemeButton.text = "Theme · " + theme_id.capitalize()
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	%ScreenButton.text = "Screen mode · " + ("Fullscreen" if fullscreen else "Windowed")
	var vsync := DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	%VSyncButton.text = "VSync · " + ("On" if vsync else "Off")

func _cycle_palette() -> void:
	var ids := UITheme.PALETTES.keys()
	var index := ids.find(UITheme.PALETTES.find_key(UITheme.palette))
	UITheme.set_palette(ids[(index + 1) % ids.size()])
	_refresh_display()

func _toggle_fullscreen() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_display()

func _toggle_vsync() -> void:
	var enabled := DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED if enabled else DisplayServer.VSYNC_ENABLED)
	_refresh_display()

func _request_reset() -> void:
	%Confirmation.show()
	%ResetProgress.disabled = true
	%CancelReset.grab_focus()

func _cancel_reset() -> void:
	%Confirmation.hide()
	%ResetProgress.disabled = false
	%ResetProgress.grab_focus()

func _change_progress(reset: bool) -> void:
	if reset: _cancel_reset()
	var saved := Progression.debug_reset_progress() if reset else Progression.debug_unlock_all()
	%Message.text = ("Progress reset" if reset else "Everything unlocked") if saved else "Could not save progress"

func _on_custom_button_pressed() -> void:
	if %Confirmation.is_visible_in_tree():
		_cancel_reset()
		return
	var result := DataManager.save_settings()
	if result != OK: push_warning("Could not save options: %s" % error_string(result))
	on_options_exited.emit()
