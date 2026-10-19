extends RefCounted

signal level_gained(level: int)
signal changed

var level := 1
var experience := 0
var fractional_experience := 0.0
var pending_levels: Array[int] = []

# Cost to reach the next level: 16, 25, 36, ...
func required_experience() -> int:
	return (level + 3) * (level + 3)

func reset() -> void:
	level = 1
	experience = 0
	fractional_experience = 0.0
	pending_levels.clear()
	changed.emit()

func add_experience(amount: int, gain_percent: float = 0.0) -> void:
	if amount <= 0: return
	var earned := amount * maxf(0.0, 1.0 + gain_percent / 100.0) + fractional_experience
	var whole := floori(earned + 0.0000001)
	fractional_experience = maxf(0.0, earned - whole)
	experience += whole
	while experience >= required_experience():
		experience -= required_experience()
		level += 1
		pending_levels.append(level)
		level_gained.emit(level)
	changed.emit()

func grant_levels(amount: int) -> void:
	if amount <= 0: return
	for index in amount:
		level += 1
		pending_levels.append(level)
		level_gained.emit(level)
	changed.emit()
