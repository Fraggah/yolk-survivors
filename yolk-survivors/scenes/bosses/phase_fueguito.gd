extends "res://scenes/bosses/hot_zones_fueguitos.gd"
## A single persistent pursuer, owned by the phase rather than a section.
func setup(geometry: ArenaEnvironment, settings: Resource, damage_source: Node2D) -> void:
	config = settings
	start(damage_source.get_parent().spawner,geometry)
	set_process(false)
	y_sort_enabled = true
	add_to_group("boss_phase_hazards")
	profile = settings.fueguito_profile
	flare_duration = settings.fueguito_flare_seconds
	batch_size = 1
	running = true
	begin_batch()
	materialize_at = flare_duration

func advance(delta: float) -> void:
	if not running or Global.game_paused: return
	elapsed += maxf(0,delta)
	if not hazards.is_empty(): return
	if pending > 0 and elapsed >= materialize_at: materialize_batch()
	if hazards.is_empty() and pending == 0:
		# A player who steps onto the flare cancels that unsafe arrival. Retry the
		# existing safe-position preview instead of materializing under the player.
		begin_batch()
		materialize_at = elapsed+flare_duration
