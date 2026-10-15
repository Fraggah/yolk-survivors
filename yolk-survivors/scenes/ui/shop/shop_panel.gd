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
var weapon_actions: PanelContainer
var next_stage: ArenaStage
var next_stage_wave := 0
var next_stage_panel: PanelContainer
var next_stage_icon: TextureRect
var next_stage_label: Label
var next_stage_description: Label

func _build_next_stage_preview() -> void:
	next_stage_panel = PanelContainer.new()
	next_stage_panel.name = "NextStagePreview"
	next_stage_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MarginContainer/Control.add_child(next_stage_panel)
	next_stage_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	next_stage_panel.offset_left = 20
	next_stage_panel.offset_right = 620
	next_stage_panel.offset_top = 154
	next_stage_panel.offset_bottom = 238
	var style := UITheme.box(UITheme.palette.surface, UITheme.palette.outline)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	next_stage_panel.add_theme_stylebox_override("panel", style)
	UITheme.palette_changed.connect(func():
		style.bg_color = UITheme.palette.surface
		style.border_color = UITheme.palette.outline
	)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	next_stage_panel.add_child(row)
	next_stage_icon = TextureRect.new()
	next_stage_icon.custom_minimum_size = Vector2(96, 64)
	next_stage_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	next_stage_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	next_stage_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(next_stage_icon)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text)
	next_stage_label = Label.new()
	next_stage_label.add_theme_font_size_override("font_size", 24)
	text.add_child(next_stage_label)
	next_stage_description = Label.new()
	next_stage_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_stage_description.add_theme_font_size_override("font_size", 18)
	text.add_child(next_stage_description)
	next_stage_panel.hide()

func set_next_stage(stage: ArenaStage, wave: int) -> void:
	next_stage = stage
	next_stage_wave = wave
	if not next_stage_panel: return
	next_stage_panel.visible = stage != null
	if not stage: return
	next_stage_icon.texture = stage.vessel
	next_stage_label.text = "NEXT WAVE %d — %s" % [wave, stage.display_name]
	next_stage_description.text = stage.description

func _build_weapon_actions() -> void:
	weapon_actions = PanelContainer.new()
	weapon_actions.name = "WeaponActions"
	weapon_actions.z_index = 20
	var style := UITheme.box(UITheme.palette.surface, UITheme.palette.outline, 16, 2)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	weapon_actions.add_theme_stylebox_override("panel", style)
	add_child(weapon_actions)
	var actions := VBoxContainer.new()
	weapon_actions.add_child(actions)
	combine_button.reparent(actions)
	var sell := get_node("MarginContainer/Control/VBoxContainer/SellWeaponButton") as Button
	sell.reparent(actions)
	for button in [combine_button, sell]:
		button.custom_minimum_size = Vector2(240, 52)
		button.add_theme_font_size_override("font_size", 30)
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(240, 48)
	close.pressed.connect(close_weapon_actions)
	actions.add_child(close)
	weapon_actions.hide()
	UITheme.palette_changed.connect(func():
		style.bg_color = UITheme.palette.surface
		style.border_color = UITheme.palette.outline
	)

func _input(event: InputEvent) -> void:
	if weapon_actions and weapon_actions.visible and event is InputEventMouseButton and event.pressed:
		if not weapon_actions.get_global_rect().has_point(get_global_mouse_position()): close_weapon_actions()

func close_weapon_actions() -> void:
	weapon_actions.hide()
	if MenuInput.gamepad_active and is_instance_valid(context_card) and not context_card.is_queued_for_deletion(): context_card.grab_focus()

func _position_weapon_actions() -> void:
	if not weapon_actions.visible or not is_instance_valid(context_card): return
	weapon_actions.reset_size()
	var rect := context_card.get_global_rect()
	var desired := Vector2(rect.get_center().x - weapon_actions.size.x * 0.5, rect.position.y - weapon_actions.size.y - 12)
	var bounds := get_global_rect()
	weapon_actions.global_position = desired.clamp(bounds.position + Vector2(12, 12), bounds.end - weapon_actions.size - Vector2(12, 12))

func _ready() -> void:
	for item in RangedCatalogue.items(true):
		if not shop_items.has(item): shop_items.append(item)
	for item in load("res://resources/items/weapons/spicy_catalogue.gd").items():
		if not item.selection_only and not shop_items.has(item): shop_items.append(item)
	weapon_tooltip = WEAPON_TOOLTIP_SCENE.instantiate() as WeaponTooltip
	add_child(weapon_tooltip)
	visibility_changed.connect(_on_visibility_changed)
	_build_weapon_actions()
	_build_next_stage_preview()
	clear_items()

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		weapon_tooltip.dismiss()
		close_weapon_actions()

func _on_item_card_hovered(card: ItemCard) -> void:
	if is_visible_in_tree() and card.get_parent() == weapon_container:
		weapon_tooltip.show_for_card(card)

func load_shop(current_wave: int) -> void:
	$MarginContainer/Control/VBoxContainer/NewWaveButton.text = "next wave %d" % (current_wave + 1)
	$MarginContainer/Control/VBoxContainer/NewWaveButton.add_theme_font_size_override("font_size", 38)
	shop_wave = maxi(1, current_wave)
	reroll_count = 0
	_populate_offers(select_shop_offers(shop_wave, _locked_offer_keys()))
	_update_reroll_button()

func _locked_offer_keys() -> Array:
	var keys: Array = []
	for card in items_container.get_children():
		if card is ShopCard and card.locked: keys.append(card.shop_item.get_offer_key())
	return keys

func _populate_offers(offers: Array) -> void:
	var next_offer := 0
	for card in items_container.get_children():
		if card is ShopCard and card.locked: continue
		card.purchase_handler = _purchase_offer.bind(card)
		var refill := _refill_offer.bind(card)
		if not card.on_item_purchased.is_connected(refill): card.on_item_purchased.connect(refill)
		if next_offer < offers.size():
			card.shop_wave = shop_wave
			card.shop_item = offers[next_offer]
			next_offer += 1
		else:
			items_container.remove_child(card)
			card.queue_free()
	while next_offer < offers.size():
		var card := SHOP_CARD_SCENE.instantiate() as ShopCard
		items_container.add_child(card)
		card.shop_wave = shop_wave
		card.shop_item = offers[next_offer]
		card.purchase_handler = _purchase_offer.bind(card)
		card.on_item_purchased.connect(_refill_offer.bind(card))
		next_offer += 1

func _purchase_offer(item: ItemBase, card: ShopCard) -> bool:
	return try_purchase_item(item, card.shop_wave)

func _eligible_shop_items() -> Array[ItemBase]:
	var result: Array[ItemBase] = []
	for item in shop_items:
		if item == null: continue
		if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or (is_instance_valid(Global.player) and not Global.player.stats.can_use_weapon(item))): continue
		result.append(item)
	return result

func select_shop_offers(completed_wave: int, excluded_keys: Array = []) -> Array:
	var catalog := _eligible_shop_items().filter(func(item): return not excluded_keys.has(item.get_offer_key()))
	var offers: Array = []
	var keys: Array = excluded_keys.duplicate()
	var slots := 4 - excluded_keys.size()
	if slots <= 0: return offers
	if completed_wave <= 2:
		var weapons := catalog.filter(func(item: ItemBase): return item is ItemWeapon)
		if completed_wave == 1:
			var affordable := weapons.filter(func(item: ItemBase):
				return item.item_tier == Global.UpgradeTier.COMMON and item.get_shop_price(completed_wave) <= ItemBase.ECONOMY_RULES.FIRST_SHOP_AFFORDABLE_PRICE)
			if not affordable.is_empty():
				var first: ItemBase = affordable.pick_random()
				offers.append(first)
				keys.append(first.get_offer_key())
		offers.append_array(Global.select_items_for_offer(weapons, completed_wave, Global.SHOP_PROBABILITY_CONFIG, mini(2, slots) - offers.size(), keys))
		for item: ItemBase in offers:
			if not keys.has(item.get_offer_key()): keys.append(item.get_offer_key())
	offers.append_array(Global.select_items_for_offer(catalog, completed_wave, Global.SHOP_PROBABILITY_CONFIG, slots - offers.size(), keys))
	return offers

func _refill_offer(purchased: ItemBase, card: ShopCard) -> void:
	var keys: Array = []
	for other: ShopCard in items_container.get_children():
		if other != card: keys.append(other.shop_item.get_offer_key())
	# Prefer a different family from the purchase; allow it if the catalog is small.
	var offers := Global.select_items_for_offer(_eligible_shop_items(), shop_wave, Global.SHOP_PROBABILITY_CONFIG, 1, keys + [purchased.get_offer_key()])
	if offers.is_empty():
		offers = Global.select_items_for_offer(_eligible_shop_items(), shop_wave, Global.SHOP_PROBABILITY_CONFIG, 1, keys)
	if not offers.is_empty():
		card.set_locked(false)
		card.shop_wave = shop_wave
		card.shop_item = offers[0]
	else:
		items_container.remove_child(card)
		card.queue_free()
	_update_reroll_button()

func get_reroll_cost() -> int:
	return ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count)

func try_reroll() -> bool:
	var price := get_reroll_cost()
	if Global.coins < price:
		SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
		return false
	var offers := select_shop_offers(shop_wave, _locked_offer_keys())
	if offers.is_empty(): return false
	Global.coins -= price
	reroll_count += 1
	_populate_offers(offers)
	_update_reroll_button()
	return true

func _on_reroll_button_pressed() -> void:
	if try_reroll(): SoundManager.play_sound(SoundManager.Sound.SHOP_REROLL)

func _process(_delta: float) -> void:
	_update_reroll_button()
	_position_weapon_actions()

func _update_reroll_button() -> void:
	reroll_cost_label.text = "refresh %s" % get_reroll_cost()
	reroll_button.disabled = Global.coins < get_reroll_cost() or _locked_offer_keys().size() >= 4
	reroll_cost_label.add_theme_color_override("font_color", UITheme.palette.disabled_text if reroll_button.disabled else UITheme.palette.text)


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
	if is_instance_valid(Global.player):
		for equipped: Weapon in Global.player.current_weapons:
			if equipped.data == weapon and not weapon_container.get_children().any(func(card): return card is ItemCard and not card.is_queued_for_deletion() and card != item_card and card.weapon_instance == equipped):
				item_card.weapon_instance = equipped
				break

func _on_new_wave_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT)
	on_shop_next_wave.emit()

func _get_auto_upgrade_card(weapon: ItemWeapon) -> ItemCard:
	if not weapon.upgrade_to or not is_instance_valid(Global.player): return null
	if not Global.player.current_weapons.any(func(w: Weapon): return weapon.matches_for_upgrade(w.data)): return null
	if not Global.equipped_weapons.any(func(w: ItemWeapon): return weapon.matches_for_upgrade(w)): return null
	for card: ItemCard in weapon_container.get_children():
		if not card.is_queued_for_deletion() and card.item is ItemWeapon and weapon.matches_for_upgrade(card.item) and is_instance_valid(card.weapon_instance) and Global.player.current_weapons.has(card.weapon_instance) and weapon.matches_for_upgrade(card.weapon_instance.data):
			return card
	return null

func try_purchase_item(item: ItemBase, price_wave: int = -1) -> bool:
	if not item or not is_instance_valid(Global.player): return false
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return false
	var price := item.get_shop_price(shop_wave if price_wave < 0 else price_wave)
	if Global.coins < price:
		SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
		return false
	if item.item_type == ItemBase.ItemType.WEAPON and Global.equipped_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS:
		if not _get_auto_upgrade_card(item as ItemWeapon): return false
	Global.coins -= price
	_on_item_purchased(item)
	return true

func _on_item_purchased(item: ItemBase) -> void:
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return
	SoundManager.play_sound(SoundManager.Sound.SHOP_BUY)
	if item is ItemWeapon and Global.equipped_weapons.size() >= Global.MAX_EQUIPPED_WEAPONS:
		_auto_upgrade_purchased_weapon(item as ItemWeapon)
		return
	if item is ItemPassive:
		(item as ItemPassive).apply_passive_values()
		for owned in passive_container.get_children():
			if owned is ItemCard and not owned.is_queued_for_deletion() and owned.item.get_offer_key() == item.get_offer_key():
				owned.quantity += 1
				return
	var item_card := create_item_card()
	
	if item.item_type == ItemBase.ItemType.WEAPON:
		weapon_container.add_child(item_card)
		var weapon := item as ItemWeapon
		Global.player.add_weapon(weapon)
		item_card.weapon_instance = Global.player.current_weapons.back()
		Global.equipped_weapons.append(weapon)
	elif item.item_type == ItemBase.ItemType.PASSIVE:
		passive_container. add_child(item_card)

		
	item_card.item = item

func _auto_upgrade_purchased_weapon(purchased: ItemWeapon) -> void:
	var card := _get_auto_upgrade_card(purchased)
	if not is_instance_valid(card): return
	var existing: Weapon = card.weapon_instance
	var equipment_index := Global.equipped_weapons.find(existing.data)
	if equipment_index < 0: return
	Global.player.current_weapons.erase(existing)
	existing.queue_free()
	Global.equipped_weapons[equipment_index] = purchased.upgrade_to
	SoundManager.play_sound(SoundManager.Sound.SHOP_COMBINE)
	Progression.record("combines", 1.0)
	Global.player.add_weapon(purchased.upgrade_to)
	card.item = purchased.upgrade_to
	card.weapon_instance = Global.player.current_weapons.back()
	Global.selected_weapon = purchased.upgrade_to
	_on_item_card_selected(card, false)

func _get_combine_weapons(card: ItemCard) -> Array[Weapon]:
	var result: Array[Weapon] = []
	if not is_instance_valid(card) or card.is_queued_for_deletion() or not card.item is ItemWeapon or not is_instance_valid(Global.player): return result
	var item := card.item as ItemWeapon
	if not item.upgrade_to or not is_instance_valid(card.weapon_instance) or not Global.player.current_weapons.has(card.weapon_instance): return result
	if not item.matches_for_upgrade(card.weapon_instance.data): return result
	result.append(card.weapon_instance)
	for other in weapon_container.get_children():
		if other == card or not other is ItemCard or other.is_queued_for_deletion(): continue
		if not is_instance_valid(other.weapon_instance) or other.weapon_instance == card.weapon_instance: continue
		if Global.player.current_weapons.has(other.weapon_instance) and other.item is ItemWeapon and item.matches_for_upgrade(other.item) and item.matches_for_upgrade(other.weapon_instance.data):
			result.append(other.weapon_instance)
			break
	return result

func _on_item_card_selected(card: ItemCard, open_actions: bool = true) -> void:
	if not card.item is ItemWeapon: return
	context_card = card
	for slot: ItemCard in weapon_container.get_children():
		slot.set_pressed_no_signal(slot == card)
	
	combine_button.disabled = _get_combine_weapons(card).size() != 2
	if open_actions:
		weapon_actions.show()
		weapon_tooltip.dismiss()
		_position_weapon_actions()
		if MenuInput.gamepad_active:
			weapon_actions.get_child(0).get_child(1).grab_focus()

func reset_offers() -> void:
	for card in items_container.get_children():
		items_container.remove_child(card)
		card.queue_free()
	reroll_count = 0

func clear_items() -> void:
	if weapon_actions: close_weapon_actions()
	weapon_tooltip.dismiss()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	for child in passive_container.get_children(): child.queue_free()
	for child in weapon_container.get_children(): child.queue_free()

func _on_combine_button_pressed() -> void:
	close_weapon_actions()
	if not context_card: return
	
	var clicked_weapon := context_card.item as ItemWeapon
	if not clicked_weapon.upgrade_to: return
	
	var weapons_to_remove := _get_combine_weapons(context_card)
	
	var cards_to_remove := weapon_container.get_children().filter(func(c: ItemCard):
		return not c.is_queued_for_deletion() and is_instance_valid(c.weapon_instance) and weapons_to_remove.has(c.weapon_instance))
	
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
	new_card.weapon_instance = Global.player.current_weapons.back()
	
	_on_item_card_selected(new_card, false)
	Global.selected_weapon = upgraded_weapon
	SoundManager.play_sound(SoundManager.Sound.SHOP_COMBINE)
	Progression.record("combines", 1.0)


func _on_sell_weapon_button_pressed() -> void:
	close_weapon_actions()
	if not context_card: return
	
	var clicked_weapon := context_card.item as ItemWeapon
	SoundManager.play_sound(SoundManager.Sound.SHOP_SELL)
	var coins := clicked_weapon.get_sell_price(shop_wave)
	
	var weapon_to_remove: Weapon = context_card.weapon_instance
	
	if weapon_to_remove:
		Global.player.current_weapons.erase(weapon_to_remove)
		Global.equipped_weapons.erase(weapon_to_remove.data)
		weapon_to_remove.queue_free()
	
	context_card.queue_free()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	
	Global.coins += coins
