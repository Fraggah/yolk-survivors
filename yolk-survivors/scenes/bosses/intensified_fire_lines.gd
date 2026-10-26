extends "res://scenes/bosses/static_fire_lines.gd"
## Reuse the Phase 1 patterns and damage pipeline without changing their resource.
func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	var intensified := settings.duplicate()
	var original_cycle: float = settings.line_warning_seconds+settings.line_active_seconds+settings.line_rest_seconds
	var ratio: float = settings.intensified_line_interval/maxf(0.001,original_cycle)
	intensified.line_warning_seconds *= ratio
	intensified.line_active_seconds *= ratio
	intensified.line_rest_seconds *= ratio
	var patterns: Array[Resource] = []
	for original in settings.static_line_patterns:
		var pattern: Resource = original.duplicate()
		pattern.label = "Intensified · "+original.label
		pattern.horizontal_positions = _thin_positions(original.horizontal_positions,settings.intensified_line_density)
		pattern.vertical_positions = _thin_positions(original.vertical_positions,settings.intensified_line_density)
		patterns.append(pattern)
	intensified.static_line_patterns = patterns
	super.setup(geometry,intensified,damage_source)

func _thin_positions(positions: PackedFloat32Array, density: float) -> PackedFloat32Array:
	if positions.is_empty(): return positions
	var count := clampi(roundi(positions.size()*density),1,positions.size())
	var result := PackedFloat32Array()
	for index in count:
		var sample: int = roundi(index*float(positions.size()-1)/float(count-1)) if count>1 else int(positions.size()/2)
		result.append(positions[sample])
	return result
