extends Panel
class_name ShopPanel

signal on_shop_next_wave

const SHOP_CARD_SCENE = preload("res://scenes/ui/shop/shop_card.tscn")
const WEAPON_TOOLTIP_SCENE = preload("res://scenes/ui/shop/weapon_tooltip.tscn")

@export var shop_items: Array[ItemBase]

@onready var items_container: HBoxContainer = %ItemsContainer
@onready var passive_container: GridContainer = %PassiveContainer
@onready var weapon_container: GridContainer = %WeaponContainer
@onready var combine_button: Button = %CombineButton

var context_card: ItemCard
var weapon_tooltip: WeaponTooltip

func _ready() -> void:
	weapon_tooltip = WEAPON_TOOLTIP_SCENE.instantiate() as WeaponTooltip
	add_child(weapon_tooltip)
	visibility_changed.connect(_on_visibility_changed)
	clear_items()

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		weapon_tooltip.dismiss()

func _on_item_card_hovered(card: ItemCard) -> void:
	if is_visible_in_tree() and card.get_parent() == weapon_container:
		weapon_tooltip.show_for_card(card)

func load_shop(current_wave: int) -> void:
	for child in items_container.get_children(): child.queue_free()
	
	var config := Global.SHOP_PROBABILITY_CONFIG
	var selected_items := Global.select_items_for_offer(shop_items, current_wave, config)
	for shop_item: ItemBase in selected_items:
		var instance := SHOP_CARD_SCENE.instantiate() as ShopCard
		items_container.add_child(instance)
		instance.shop_item = shop_item
		instance.purchase_handler = try_purchase_item


func create_item_card() -> ItemCard:
	var item_card := Global.ITEM_CARD_SCENE.instantiate()
	item_card.on_item_card_selected.connect(_on_item_card_selected)
	item_card.mouse_entered.connect(_on_item_card_hovered.bind(item_card))
	item_card.mouse_exited.connect(weapon_tooltip.hide_for_card.bind(item_card))
	return item_card

func create_item_weapon(weapon: ItemWeapon) -> void:
	var item_card := create_item_card()
	weapon_container.add_child(item_card)
	item_card.item = weapon

func _on_new_wave_button_pressed() -> void:
	on_shop_next_wave.emit()

func _get_auto_upgrade_card(weapon: ItemWeapon) -> ItemCard:
	if not weapon.upgrade_to or not is_instance_valid(Global.player): return null
	if not Global.player.current_weapons.any(func(w: Weapon): return weapon.matches_for_upgrade(w.data)): return null
	if not Global.equipped_weapons.any(func(w: ItemWeapon): return weapon.matches_for_upgrade(w)): return null
	for card: ItemCard in weapon_container.get_children():
		if not card.is_queued_for_deletion() and card.item is ItemWeapon and weapon.matches_for_upgrade(card.item):
			return card
	return null

func try_purchase_item(item: ItemBase) -> bool:
	if not item or not is_instance_valid(Global.player) or Global.coins < item.item_cost: return false
	if item.item_type == ItemBase.ItemType.WEAPON and Global.equipped_weapons.size() >= 6:
		if not _get_auto_upgrade_card(item as ItemWeapon): return false
	Global.coins -= item.item_cost
	_on_item_purchased(item)
	return true

func _on_item_purchased(item: ItemBase) -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if item is ItemWeapon and Global.equipped_weapons.size() >= 6:
		_auto_upgrade_purchased_weapon(item as ItemWeapon)
		return
	var item_card := create_item_card()
	
	if item.item_type == ItemBase.ItemType.WEAPON:
		weapon_container.add_child(item_card)
		var weapon := item as ItemWeapon
		Global.player.add_weapon(weapon)
		Global.equipped_weapons.append(weapon)
	elif item.item_type == ItemBase.ItemType.PASSIVE:
		passive_container. add_child(item_card)
		var passive := item as ItemPassive
		passive.apply_passive_values()
		
	item_card.item = item

func _auto_upgrade_purchased_weapon(purchased: ItemWeapon) -> void:
	var card := _get_auto_upgrade_card(purchased)
	var existing: Weapon = Global.player.current_weapons.filter(func(w: Weapon):
		return purchased.matches_for_upgrade(w.data)).front()
	var equipment_index := Global.equipped_weapons.find_custom(func(w: ItemWeapon): return purchased.matches_for_upgrade(w))
	Global.player.current_weapons.erase(existing)
	existing.queue_free()
	Global.equipped_weapons[equipment_index] = purchased.upgrade_to
	Global.player.add_weapon(purchased.upgrade_to)
	card.item = purchased.upgrade_to
	Global.selected_weapon = purchased.upgrade_to
	_on_item_card_selected(card)

func _on_item_card_selected(card: ItemCard) -> void:
	context_card = card
	for slot: ItemCard in weapon_container.get_children():
		slot.set_pressed_no_signal(slot == card)
	
	var can_merge := false
	if context_card and context_card.item.item_type == ItemBase.ItemType.WEAPON:
		var count := 0
		for weapon: ItemWeapon in Global.equipped_weapons:
			if weapon.item_name == context_card.item.item_name:
				count += 1
		
		if count >= 2:
			can_merge = true
	
	combine_button.disabled = not can_merge

func clear_items() -> void:
	weapon_tooltip.dismiss()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	for child in passive_container.get_children(): child.queue_free()
	for child in weapon_container.get_children(): child.queue_free()

func _on_combine_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if not context_card: return
	
	var clicked_weapon := context_card.item as ItemWeapon
	if not clicked_weapon.upgrade_to: return
	
	var weapons_to_remove := Global.player.current_weapons.filter(func(w: Weapon):
		return w.data.item_name == clicked_weapon.item_name).slice(0, 2)
	
	var cards_to_remove := weapon_container.get_children().filter(func(c: ItemCard):
		return c.item.item_name == clicked_weapon.item_name).slice(0, 2)
	
	if weapons_to_remove.size() < 2 or cards_to_remove.size() < 2: return
	
	for weapon: Weapon in weapons_to_remove:
		Global.player.current_weapons.erase(weapon)
		Global.equipped_weapons.erase(weapon.data)
		weapon.queue_free()
	
	for card: ItemCard in cards_to_remove:
		card.queue_free()
	
	var upgraded_weapon := load(clicked_weapon.upgrade_to.resource_path)
	Global.player.add_weapon(upgraded_weapon)
	Global.equipped_weapons.append(upgraded_weapon)
	
	var new_card := create_item_card()
	weapon_container.add_child(new_card)
	new_card.item = upgraded_weapon
	
	_on_item_card_selected(new_card)
	Global.selected_weapon = upgraded_weapon


func _on_sell_weapon_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if not context_card: return
	
	var clicked_weapon := context_card.item as ItemWeapon
	var coins := clicked_weapon.item_cost * .75
	
	var weapon_to_remove: Weapon = Global.player.current_weapons.filter(func(w: Weapon):
		return w.data.item_name == clicked_weapon.item_name).front()
	
	if weapon_to_remove:
		Global.player.current_weapons.erase(weapon_to_remove)
		Global.equipped_weapons.erase(weapon_to_remove.data)
		weapon_to_remove.queue_free()
	
	context_card.queue_free()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	
	Global.coins += coins
