extends RefCounted

signal level_gained(level: int)
signal changed

var level := 1
var experience := 0
var pending_levels: Array[int] = []

# Cost to reach the next level: 16, 25, 36, ...
func required_experience() -> int:
	return (level + 3) * (level + 3)

func reset() -> void:
	level = 1
	experience = 0
	pending_levels.clear()
	changed.emit()

func add_experience(amount: int) -> void:
	if amount <= 0: return
	experience += amount
	while experience >= required_experience():
		experience -= required_experience()
		level += 1
		pending_levels.append(level)
		level_gained.emit(level)
	changed.emit()
