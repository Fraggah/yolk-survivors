extends Panel
class_name ShopPanel

signal on_shop_next_wave

const SHOP_CARD_SCENE = preload("res://scenes/ui/shop/shop_card.tscn")
const WEAPON_TOOLTIP_SCENE = preload("res://scenes/ui/shop/weapon_tooltip.tscn")

@export var shop_items: Array[ItemBase]

@onready var items_container: HBoxContainer = %ItemsContainer
@onready var passive_container: GridContainer = %PassiveContainer
@onready var weapon_container: GridContainer = %WeaponContainer
@onready var reroll_button: Button = %RerollButton
@onready var reroll_cost_label: Label = %RerollButton/Content/CostLabel
@onready var combine_button: Button = %CombineButton

var context_card: ItemCard
var weapon_tooltip: WeaponTooltip
var shop_wave := 1
var reroll_count := 0

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
	shop_wave = maxi(1, current_wave)
	reroll_count = 0
	_populate_offers(select_shop_offers(shop_wave))
	_update_reroll_button()

func _populate_offers(offers: Array) -> void:
	for child in items_container.get_children():
		items_container.remove_child(child)
		child.queue_free()
	for item: ItemBase in offers:
		var card := SHOP_CARD_SCENE.instantiate() as ShopCard
		items_container.add_child(card)
		card.shop_wave = shop_wave
		card.shop_item = item
		card.purchase_handler = try_purchase_item
		card.on_item_purchased.connect(_refill_offer.bind(card))

func _eligible_shop_items() -> Array[ItemBase]:
	var result: Array[ItemBase] = []
	for item in shop_items:
		if item == null: continue
		if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or (is_instance_valid(Global.player) and not Global.player.stats.can_use_weapon(item))): continue
		result.append(item)
	return result

func select_shop_offers(completed_wave: int) -> Array:
	var catalog := _eligible_shop_items()
	var offers: Array = []
	var keys: Array = []
	if completed_wave <= 2:
		var weapons := catalog.filter(func(item: ItemBase): return item is ItemWeapon)
		if completed_wave == 1:
			var affordable := weapons.filter(func(item: ItemBase):
				return item.item_tier == Global.UpgradeTier.COMMON and item.get_shop_price(completed_wave) <= ItemBase.ECONOMY_RULES.FIRST_SHOP_AFFORDABLE_PRICE)
			if not affordable.is_empty():
				var first: ItemBase = affordable.pick_random()
				offers.append(first)
				keys.append(first.get_offer_key())
		offers.append_array(Global.select_items_for_offer(weapons, completed_wave, Global.SHOP_PROBABILITY_CONFIG, 2 - offers.size(), keys))
		for item: ItemBase in offers:
			if not keys.has(item.get_offer_key()): keys.append(item.get_offer_key())
	offers.append_array(Global.select_items_for_offer(catalog, completed_wave, Global.SHOP_PROBABILITY_CONFIG, 4 - offers.size(), keys))
	return offers

func _refill_offer(purchased: ItemBase, card: ShopCard) -> void:
	var keys: Array = []
	for other: ShopCard in items_container.get_children():
		if other != card: keys.append(other.shop_item.get_offer_key())
	# Prefer a different family from the purchase; allow it if the catalog is small.
	var offers := Global.select_items_for_offer(_eligible_shop_items(), shop_wave, Global.SHOP_PROBABILITY_CONFIG, 1, keys + [purchased.get_offer_key()])
	if offers.is_empty():
		offers = Global.select_items_for_offer(_eligible_shop_items(), shop_wave, Global.SHOP_PROBABILITY_CONFIG, 1, keys)
	if not offers.is_empty(): card.shop_item = offers[0]
	else:
		items_container.remove_child(card)
		card.queue_free()
	_update_reroll_button()

func get_reroll_cost() -> int:
	return ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count)

func try_reroll() -> bool:
	var price := get_reroll_cost()
	if Global.coins < price: return false
	var offers := select_shop_offers(shop_wave)
	if offers.is_empty(): return false
	Global.coins -= price
	reroll_count += 1
	_populate_offers(offers)
	_update_reroll_button()
	return true

func _on_reroll_button_pressed() -> void:
	if try_reroll(): SoundManager.play_sound(SoundManager.Sound.UI_CLICK)

func _process(_delta: float) -> void:
	_update_reroll_button()

func _update_reroll_button() -> void:
	reroll_cost_label.text = "refresh %s" % get_reroll_cost()
	reroll_button.disabled = Global.coins < get_reroll_cost()
	reroll_cost_label.get_parent().modulate.a = 0.5 if reroll_button.disabled else 1.0


func create_item_card() -> ItemCard:
	var item_card := Global.ITEM_CARD_SCENE.instantiate()
	item_card.on_item_card_selected.connect(_on_item_card_selected)
	item_card.mouse_entered.connect(_on_item_card_hovered.bind(item_card))
	item_card.focus_entered.connect(_on_item_card_hovered.bind(item_card))
	item_card.focus_exited.connect(weapon_tooltip.hide_for_card.bind(item_card))
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
	if not item or not is_instance_valid(Global.player): return false
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return false
	var price := item.get_shop_price(shop_wave)
	if Global.coins < price: return false
	if item.item_type == ItemBase.ItemType.WEAPON and Global.equipped_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS:
		if not _get_auto_upgrade_card(item as ItemWeapon): return false
	Global.coins -= price
	_on_item_purchased(item)
	return true

func _on_item_purchased(item: ItemBase) -> void:
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if item is ItemWeapon and Global.equipped_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS:
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
	Progression.record("combines", 1.0)
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
	Progression.record("combines", 1.0)


func _on_sell_weapon_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_CLICK)
	if not context_card: return
	
	var clicked_weapon := context_card.item as ItemWeapon
	var coins := clicked_weapon.get_sell_price(shop_wave)
	
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
