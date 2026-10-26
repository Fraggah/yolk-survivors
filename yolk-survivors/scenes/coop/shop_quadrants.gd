extends Container
## Four equal editor-visible quadrants, independent of active player count.
@export var separation:=14.0:
	set(value):
		separation=value
		queue_sort()
var columns:=2
func _notification(what: int) -> void:
	if what!=NOTIFICATION_SORT_CHILDREN: return
	var cell: Vector2=(size-Vector2.ONE*separation)/2.0
	var index:=0
	for child in get_children():
		if child is Control and child.visible:
			fit_child_in_rect(child,Rect2(Vector2(index%2,index/2)*(cell+Vector2.ONE*separation),cell))
			index+=1
