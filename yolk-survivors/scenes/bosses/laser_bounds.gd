extends RefCounted

static func for_view(area: ArenaEnvironment, viewport: Viewport, overscan: float) -> Rect2:
	var bounds := Rect2(area.background_offset-area.background_size*0.5,area.background_size)
	var camera := viewport.get_camera_2d()
	if is_instance_valid(camera) and camera.has_method("laser_coverage_bounds") and camera.overview_toggle_enabled:
		bounds = bounds.merge(camera.laser_coverage_bounds())
	return bounds.grow(overscan)
