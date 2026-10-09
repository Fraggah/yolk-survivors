@tool
extends Resource
class_name UIPalette

@export var display_name := "Cream & yolk"
@export_group("Surfaces")
@export var background := Color("f2e4cb")
@export var surface := Color("fff7e6")
@export var inset := Color("e7d5b4")
@export var outline := Color("695039")
@export_group("Content")
@export var text := Color("443528")
@export var muted := Color("766450")
@export var positive := Color("34704c")
@export var negative := Color("a33836")
@export var accent := Color("a06a18")
@export var hud_text := Color("fff7e6")
@export_group("Actions")
@export var button := Color("dbc7a3")
@export var primary := Color("f5bd4f")
@export var danger := Color("df8b78")
@export var focus := Color("176f80")
@export var hover_surface := Color("b9dfe2")
@export var hover_selected := Color("8ac5cd")
@export var disabled := Color("dfd8c9")
@export var disabled_text := Color("80796e")
@export_group("Rarity borders")
@export var common := Color("988164")
@export var rare := Color("388566")
@export var epic := Color("75629d")
@export var legendary := Color("c58121")
@export_group("Geometry")
@export_range(0, 28) var radius := 16
@export_range(1, 5) var border_width := 2
@export_range(3, 8) var focus_width := 5
@export_range(0, 12) var shadow_size := 3
@export var shadow_color := Color(0, 0, 0, 0.2)

func rarity(tier: int) -> Color:
	return [common, rare, epic, legendary][clampi(tier, 0, 3)]
