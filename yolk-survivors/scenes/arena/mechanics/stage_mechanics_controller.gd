extends Node
class_name StageMechanicsController

var spawner: Spawner
var environments: ArenaEnvironmentController
var current_mechanic: StageMechanic

func setup(context: Spawner, visuals: ArenaEnvironmentController) -> void:
	spawner = context
	environments = visuals
	spawner.on_wave_started.connect(_start_wave)
	spawner.on_wave_cleared.connect(stop)
	spawner.on_wave_completed.connect(stop)

func _start_wave(_wave: int) -> void:
	stop()
	var stage := environments.current_stage
	if not stage or not stage.mechanic_scene: return
	current_mechanic = stage.mechanic_scene.instantiate() as StageMechanic
	add_child(current_mechanic)
	current_mechanic.start(spawner, stage.play_area)

func stop() -> void:
	var bursts := get_parent().get_node_or_null("ArenaBursts")
	if bursts: bursts.clear_impacts()
	if is_instance_valid(current_mechanic):
		current_mechanic.stop()
		current_mechanic.queue_free()
	current_mechanic = null
