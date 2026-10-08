extends HealthComponent
## Reject damage and death at the component boundary, including direct calls.

func take_damage(_value: float) -> void:
	pass

func die() -> void:
	pass
