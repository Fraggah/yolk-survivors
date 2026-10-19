extends Node2D
class_name WeaponsContainer

const SLOT_DISTANCE_SCALE := 0.75

@onready var one: Node2D = $One
@onready var two: Node2D = $Two
@onready var three: Node2D = $Three
@onready var four: Node2D = $Four
@onready var five: Node2D = $Five
@onready var six: Node2D = $Six

func _ready() -> void:
	for layout in [one, two, three, four, five, six]:
		for marker in layout.get_children():
			marker.position *= SLOT_DISTANCE_SCALE

func update_weapons_position(weapons: Array[Weapon]) -> void:
	var count := weapons.size()
	if count > 6:
		var radius := 60.0 * SLOT_DISTANCE_SCALE
		for marker in six.get_children(): radius = maxf(radius, marker.position.length())
		for index in count:
			var angle := TAU * index / count - PI * 0.5
			weapons[index].global_position = to_global(Vector2(cos(angle) * radius, sin(angle) * radius * 0.65))
		return
	var reference_node: Node2D
	match count:
		1: reference_node = one
		2: reference_node = two
		3: reference_node = three
		4: reference_node = four
		5: reference_node = five
		6: reference_node = six
	
	if not reference_node: return
	var markers := reference_node.get_children()
	if markers.size() != count: return
	
	for i in count:
		weapons[i].global_position = markers[i].global_position
