extends ItemBase
class_name ItemUpgrade

@export var value: float
@export var description: String
@export var stat_id: String

func apply_upgrade() -> void:
	Global.player.stats.apply_stat_change(stat_id, value)

func get_offer_key() -> String:
	return "upgrade:%s" % stat_id
