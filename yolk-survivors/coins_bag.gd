extends VBoxContainer
class_name CoinsBag

@onready var coins_label: Label = $BalanceRow/CoinsLabel
@onready var reserve_label: Label = $ReserveRow/ReserveLabel
@onready var jar_icon: TextureRect = $ReserveRow/JarIcon

func _ready() -> void:
	if get_parent() is CanvasLayer:
		coins_label.theme_type_variation = &"HudLabel"
		reserve_label.theme_type_variation = &"HudLabel"

func _process(_delta: float) -> void:
	var reveal = get_tree().get_first_node_in_group("coin_balance_reveal")
	var shown_balance: int = reveal.displayed_balance if is_instance_valid(reveal) and reveal.is_visible_in_tree() else Global.coins
	coins_label.text = str(shown_balance)
	reserve_label.text = str(Global.yolk_reserve)

	var coop=get_tree().current_scene.get("coop") if get_tree().current_scene else null
	if coop and coop.active:
		var balance:=0
		var reserve:=0
		for session in coop.sessions:
			balance+=session.coins
			reserve+=session.reserve
		coins_label.text=str(balance)
		reserve_label.text=str(reserve)
