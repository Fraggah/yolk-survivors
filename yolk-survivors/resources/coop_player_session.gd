extends RefCounted
## Stable ownership, independent of the actor's alive/down state.
var slot := 0
var device := -1 # -1 keyboard; >=0 a single joypad, never all devices.
var character: UnitStats
var weapon: ItemWeapon
var actor: Player
var coins := 25
var reserve := 0
var experience = preload("res://resources/run_experience.gd").new()
var offers: Array[ItemBase] = []
var rewards: Array[ItemPassive] = []
var upgrades_offered := false
var locked := [false, false, false, false]
# Shop locks survive combat and intermediate reward/level-up screens.
var saved_shop_offers: Array[ItemBase] = []
var ready := false
var cursor := 0
var rerolls := 0
var input_vector := Vector2.ZERO
var dash_requested := false
var disconnected := false

func collect(amount: int) -> int:
	var bonus := mini(reserve, maxi(0, amount))
	reserve -= bonus
	coins += maxi(0, amount) + bonus
	if is_instance_valid(actor): actor.passive_items.on_yolks_collected(maxi(0, amount)+bonus)
	return bonus

func poll_movement() -> Vector2:
	if disconnected: return Vector2.ZERO
	if device < 0:
		return Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W))).limit_length()
	var stick := Vector2(Input.get_joy_axis(device,JOY_AXIS_LEFT_X),Input.get_joy_axis(device,JOY_AXIS_LEFT_Y))
	var pad := Vector2(float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_RIGHT))-float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_LEFT)),float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_DOWN))-float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_UP)))
	return pad.limit_length() if pad.length_squared()>0 else stick.limit_length() if stick.length()>0.2 else Vector2.ZERO
