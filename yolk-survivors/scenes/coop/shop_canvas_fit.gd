@tool
extends Container
## Scale the scene-authored solo layout to its player's quadrant.
@export var design_size:=Vector2(1880,980)
func _notification(what: int) -> void:
	if what!=NOTIFICATION_SORT_CHILDREN: return
	for child in get_children():
		if child is Control:
			var factor:=minf(size.x/design_size.x,size.y/design_size.y)
			child.size=design_size
			child.scale=Vector2.ONE*factor
			child.position=(size-design_size*factor)*.5
