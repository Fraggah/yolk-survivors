extends Panel
class_name StartPanel

signal on_play_pressed
signal on_options_pressed
signal on_credits_pressed
signal on_exit_pressed

@export var roster_entrance_duration := 0.46
@export var roster_settle_duration := 0.20
@export var roster_overshoot := 12.0

var roster_entrance: Tween
@onready var roster_left: TextureRect = $RosterLeft
@onready var roster_right: TextureRect = $RosterRight
@onready var roster_left_rest := Vector2(roster_left.offset_left, roster_left.offset_right)
@onready var roster_right_rest := Vector2(roster_right.offset_left, roster_right.offset_right)

func _ready() -> void:
	visibility_changed.connect(_play_roster_entrance)
	_play_roster_entrance()

func _play_roster_entrance() -> void:
	if roster_entrance: roster_entrance.kill()
	if not is_visible_in_tree():
		_set_roster_offset(Vector2.ZERO)
		return
	var left_width := size.x * (roster_left.anchor_right - roster_left.anchor_left) + roster_left_rest.y - roster_left_rest.x
	var right_width := size.x * (roster_right.anchor_right - roster_right.anchor_left) + roster_right_rest.y - roster_right_rest.x
	var entrance := Vector2(-left_width, right_width)
	var overshoot := Vector2(roster_overshoot, -roster_overshoot)
	_set_roster_offset(entrance)
	roster_entrance = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	roster_entrance.tween_method(_set_roster_offset, entrance, overshoot, roster_entrance_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	roster_entrance.tween_method(_set_roster_offset, overshoot, Vector2.ZERO, roster_settle_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_roster_offset(shift: Vector2) -> void:
	roster_left.offset_left = roster_left_rest.x + shift.x
	roster_left.offset_right = roster_left_rest.y + shift.x
	roster_right.offset_left = roster_right_rest.x + shift.y
	roster_right.offset_right = roster_right_rest.y + shift.y

func _on_play_button_pressed() -> void:
	on_play_pressed.emit()


func _on_options_button_pressed() -> void:
	on_options_pressed.emit()


func _on_credits_button_pressed() -> void:
	on_credits_pressed.emit()


func _on_exit_button_pressed() -> void:
	on_exit_pressed.emit()
