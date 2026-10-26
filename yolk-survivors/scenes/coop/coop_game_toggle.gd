extends Button
## Scene-authored vertical layout; only the knob's state is animated at runtime.
@onready var track: Control = $Margin/Row/Track
@onready var knob: Panel = $Margin/Row/Track/Knob
@onready var background: Panel = $Margin/Row/Track/Background
var rest_position := Vector2.ZERO
var motion: Tween

func _ready() -> void:
	rest_position=knob.position
	toggled.connect(_sync.bind(true))
	track.resized.connect(func(): _sync(button_pressed,false))
	UITheme.palette_changed.connect(func(): _sync(button_pressed,false))
	_sync(button_pressed,false)

func _sync(on: bool, animate: bool) -> void:
	background.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.focus if on else UITheme.palette.inset,UITheme.palette.outline,18,2))
	knob.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.hud_text if on else UITheme.palette.muted,Color.TRANSPARENT,14,0))
	var target: float=maxf(0,track.size.y-knob.size.y-rest_position.y) if on else rest_position.y
	if motion and motion.is_valid(): motion.kill()
	if animate and is_visible_in_tree():
		motion=create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		motion.tween_property(knob,"position:y",target,.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else: knob.position.y=target

func sync_state() -> void:
	_sync(button_pressed,false)
