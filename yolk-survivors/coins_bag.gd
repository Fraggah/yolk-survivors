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
	coins_label.text = str(Global.coins)
	reserve_label.text = str(Global.yolk_reserve)
