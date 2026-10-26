extends Panel
class_name ShopPanel

signal on_shop_next_wave

const MAX_WEAPON_OFFERS := 2
const SHOP_CARD_SCENE = preload("res://scenes/ui/shop/shop_card.tscn")
const WEAPON_TOOLTIP_SCENE = preload("res://scenes/ui/shop/weapon_tooltip.tscn")

@export var shop_items: Array[ItemBase]
## Temporary animation test: guaranteed chocolate coin for Hoarder.
@export var test_hoarder_chocolate_coin := true
@export var test_glass_egg_golden_yolk := true

@onready var items_container: HBoxContainer = %ItemsContainer
@onready var passive_container: GridContainer = %PassiveContainer
@onready var weapon_container: GridContainer = %WeaponContainer
@onready var reroll_button: Button = %RerollButton
@onready var reroll_cost_label: Label = %RerollButton/Content/CostLabel
@onready var combine_button: Button = %CombineButton

var breading_control: Button
var golden_control: Button
var golden_result: AcceptDialog
var gamble_button: Button
var coin_animation: Control
var golden_animation: Control

var context_card: ItemCard
var weapon_tooltip: WeaponTooltip
var shop_wave := 1
var pending_level_rewards := 0
var reroll_count := 0
var equipped_guarantee_shown := false
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
	var actions := $MarginContainer/Control/VBoxContainer
	next_stage_panel.reparent(actions)
	actions.move_child(next_stage_panel, 1)
	next_stage_panel.custom_minimum_size = Vector2.ZERO
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
	next_stage_icon.custom_minimum_size = Vector2(48, 42)
	next_stage_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	next_stage_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	next_stage_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(next_stage_icon)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text)
	next_stage_label = Label.new()
	next_stage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_stage_label.add_theme_font_size_override("font_size", 20)
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
	next_stage_panel.hide()
	if not stage: return
	var special_arena := stage.id != &"neutral_plate"
	var notices: Array[String] = []
	var arena = get_tree().current_scene
	if arena is Arena:
		var data = arena.spawner.wave_data_for(wave)
		if data:
			if data.has_boss_encounter():
				var boss_settings: Resource = data.boss_encounter
				next_stage = boss_settings.arena_stage
				next_stage_panel.show()
				next_stage_icon.show()
				next_stage_icon.texture = next_stage.vessel
				next_stage_label.text = boss_settings.boss_name
				next_stage_description.text = "BOSS · Defeat the boss to complete the wave"
				next_stage_description.show()
				return
			if data.wave_type == WaveData.WaveType.HORDE or (is_instance_valid(Global.player) and Global.player.passive_items.force_horde): notices.append("HORDE")
			elif data.wave_type == WaveData.WaveType.BOSS: notices.append("BOSS")
			elif data.wave_type == WaveData.WaveType.SPECIAL: notices.append("SPECIAL WAVE")
			for event in data.scheduled_spawns:
				if event and event.enemy: notices.append("%s · %ds" % [String(event.enemy.id).capitalize(), roundi(event.second)])
	next_stage_panel.visible = special_arena or not notices.is_empty()
	next_stage_icon.visible = special_arena
	next_stage_icon.texture = stage.vessel
	next_stage_label.text = stage.display_name if special_arena else "EVENTS"
	next_stage_description.text = " · ".join(notices)
	next_stage_description.visible = not notices.is_empty()

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
	shop_items = shop_items.filter(func(item): return not item is ItemPassive)
	shop_items.append_array(load("res://resources/items/passives/catalogue.gd").items())
	for item in load("res://resources/items/weapons/melee_catalogue.gd").items(true):
		if not shop_items.has(item): shop_items.append(item)
	for item in RangedCatalogue.items(true):
		if not shop_items.has(item): shop_items.append(item)
	for item in load("res://resources/items/weapons/spicy_catalogue.gd").items(true):
		if not item.selection_only and not shop_items.has(item): shop_items.append(item)
	weapon_tooltip = WEAPON_TOOLTIP_SCENE.instantiate() as WeaponTooltip
	add_child(weapon_tooltip)
	visibility_changed.connect(_on_visibility_changed)
	_build_weapon_actions()
	_build_next_stage_preview()
	_build_golden_yolk_control()
	_build_breading_control()
	coin_animation = load("res://scenes/ui/shop/chocolate_coin_reveal.gd").new()
	get_parent().add_child.call_deferred(coin_animation)
	golden_animation = load("res://scenes/ui/shop/golden_yolk_reveal.gd").new()
	get_parent().add_child.call_deferred(golden_animation)
	gamble_button = Button.new()
	gamble_button.name = "GamblerCoinButton"
	gamble_button.text = ""
	gamble_button.flat = false
	gamble_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	gamble_button.custom_minimum_size = Vector2(64, 64)
	gamble_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var gamble_icon := TextureRect.new()
	gamble_icon.name = "CoinIcon"
	gamble_icon.texture = load("res://assets/sprites/Items/Catalogue/034.png")
	gamble_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gamble_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gamble_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gamble_button.add_child(gamble_icon)
	gamble_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gamble_icon.offset_left = 7
	gamble_icon.offset_top = 7
	gamble_icon.offset_right = -7
	gamble_icon.offset_bottom = -7
	var shimmer := ShaderMaterial.new()
	shimmer.shader = load("res://effects/golden_item.gdshader")
	shimmer.set_shader_parameter("strength", 0.65)
	gamble_icon.material = shimmer
	gamble_button.tooltip_text = "Apostar gratis · Requiere al menos 1 yema"
	gamble_button.pressed.connect(func():
		if Global.coins < 1: return
		resolve_chocolate_coin()
		gamble_button.hide()
		_update_reroll_button()
	)
	$MarginContainer/Control.add_child(gamble_button)
	gamble_button.hide()
	clear_items()

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		weapon_tooltip.dismiss()
		close_weapon_actions()
		_clear_liquidation_sales()
		if golden_control: golden_control.cancel_selection()
		if breading_control: breading_control.cancel_selection()
		if golden_result: golden_result.hide()

func _on_item_card_hovered(card: ItemCard) -> void:
	if is_visible_in_tree() and card.get_parent() in [weapon_container, passive_container]:
		weapon_tooltip.show_for_card(card)

func load_shop(current_wave: int) -> void:
	cancel_consumable_selection()
	_clear_liquidation_sales()
	$MarginContainer/Control/VBoxContainer/NewWaveButton.add_theme_font_size_override("font_size", 38)
	shop_wave = maxi(1, current_wave)
	set_pending_level_rewards(pending_level_rewards)
	gamble_button.visible = is_instance_valid(Global.player) and Global.player.stats.unlock_id == "gambler"
	reroll_count = 0
	equipped_guarantee_shown = false
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
	var owned: Array[String] = load("res://resources/shop_weapon_bias.gd").families(load("res://resources/shop_weapon_bias.gd").equipped(Global.player))
	for card in items_container.get_children():
		if card.shop_item is ItemWeapon and owned.has(card.shop_item.get_offer_key()): equipped_guarantee_shown = true
	_ensure_test_consumable()
	_ensure_liquidation_offer()

func _purchase_offer(item: ItemBase, card: ShopCard) -> bool:
	var doubled := card.sale_two_for_one
	if doubled and not _can_receive_two(item): return false
	if not try_purchase_item(item, card.shop_wave, card.get_effective_price()): return false
	if doubled: _on_item_purchased(item)
	return true

func _eligible_shop_items() -> Array[ItemBase]:
	var result: Array[ItemBase] = []
	var policy = load("res://resources/shop_weapon_bias.gd")
	var held = policy.equipped(Global.player)
	for item in shop_items:
		if item == null: continue
		if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and is_instance_valid(Global.player) and not item.available_for(Global.player): continue
		if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or (is_instance_valid(Global.player) and not Global.player.stats.can_use_weapon(item))): continue
		if item is ItemWeapon and is_instance_valid(Global.player) and not policy.useful_tier(item, held, Global.player.get_weapon_limit()): continue
		result.append(item)
	return result

func _choose_shop_candidate(candidates: Array) -> ItemBase:
	var policy = load("res://resources/shop_weapon_bias.gd")
	return policy.choose(candidates, policy.equipped(Global.player))

func _draw_shop_items(pool: Array, wave: int, amount: int, keys: Array, weapon_budget: int = MAX_WEAPON_OFFERS) -> Array:
	var result: Array = []
	var excluded := keys.duplicate()
	var remaining_weapons := maxi(0, weapon_budget)
	for slot in maxi(0, amount):
		var allowed := pool.filter(func(item): return remaining_weapons > 0 or not item is ItemWeapon)
		var draw := Global.select_items_for_offer(allowed, wave, Global.SHOP_PROBABILITY_CONFIG, 1, excluded, _choose_shop_candidate)
		if draw.is_empty(): break
		var item: ItemBase = draw[0]
		result.append(item)
		excluded.append(item.get_offer_key())
		if item is ItemWeapon: remaining_weapons -= 1
	return result

func select_shop_offers(completed_wave: int, excluded_keys: Array = [], previous_keys: Array = []) -> Array:
	var blocked := excluded_keys.duplicate()
	for key in previous_keys:
		if not blocked.has(key): blocked.append(key)
	var catalog := _eligible_shop_items().filter(func(item): return not blocked.has(item.get_offer_key()))
	var offers: Array = []
	var keys: Array = blocked.duplicate()
	var slots := 4 - excluded_keys.size()
	var retained_weapons := excluded_keys.filter(func(key): return str(key).begins_with("weapon:")).size()
	var weapon_slots := maxi(0, MAX_WEAPON_OFFERS - retained_weapons)
	if slots <= 0: return offers
	var policy = load("res://resources/shop_weapon_bias.gd")
	var held: Array[ItemWeapon] = policy.equipped(Global.player)
	var owned: Array[String] = policy.families(held)
	var locked_match := excluded_keys.any(func(key): return owned.has(key))
	if weapon_slots > 0 and held.size() > 0 and held.size() < 3 and not equipped_guarantee_shown and not locked_match:
		var matches := catalog.filter(func(item): return item is ItemWeapon and owned.has(item.get_offer_key()))
		if not matches.is_empty():
			# Draw the tier through the normal rarity policy, without forcing a tier.
			var guaranteed := _draw_shop_items(matches, completed_wave, 1, keys)
			offers.append_array(guaranteed)
			for item in guaranteed: keys.append(item.get_offer_key())
	if completed_wave <= 2:
		var weapons := catalog.filter(func(item): return item is ItemWeapon)
		if completed_wave == 1 and offers.size() < mini(slots, weapon_slots):
			var affordable := weapons.filter(func(item):
				return not keys.has(item.get_offer_key()) and item.item_tier == Global.UpgradeTier.COMMON and item.get_shop_price(completed_wave) <= ItemBase.ECONOMY_RULES.FIRST_SHOP_AFFORDABLE_PRICE)
			var already_affordable := offers.any(func(item): return item.item_tier == Global.UpgradeTier.COMMON and item.get_shop_price(completed_wave) <= ItemBase.ECONOMY_RULES.FIRST_SHOP_AFFORDABLE_PRICE)
			if not already_affordable and not affordable.is_empty():
				var first: ItemBase = _choose_shop_candidate(affordable)
				offers.append(first)
				keys.append(first.get_offer_key())
		offers.append_array(_draw_shop_items(weapons, completed_wave, mini(weapon_slots, slots) - offers.size(), keys))
		for item: ItemBase in offers:
			if not keys.has(item.get_offer_key()): keys.append(item.get_offer_key())
	offers.append_array(_draw_shop_items(catalog, completed_wave, slots - offers.size(), keys, weapon_slots - offers.size()))
	return offers

func _refill_offer(purchased: ItemBase, card: ShopCard) -> void:
	var keys: Array = []
	var retained_weapons := 0
	for other: ShopCard in items_container.get_children():
		if other != card:
			keys.append(other.shop_item.get_offer_key())
			if other.shop_item is ItemWeapon: retained_weapons += 1
	var weapon_budget := maxi(0, MAX_WEAPON_OFFERS - retained_weapons)
	# Prefer a different family from the purchase; allow it if the catalog is small.
	var offers := _draw_shop_items(_eligible_shop_items(), shop_wave, 1, keys + [purchased.get_offer_key()], weapon_budget)
	if offers.is_empty():
		offers = _draw_shop_items(_eligible_shop_items(), shop_wave, 1, keys, weapon_budget)
	if not offers.is_empty():
		card.set_locked(false)
		card.shop_wave = shop_wave
		card.shop_item = offers[0]
	else:
		items_container.remove_child(card)
		card.queue_free()
	_ensure_test_consumable()
	_ensure_liquidation_offer()
	_update_reroll_button()

func get_reroll_cost() -> int:
	var discount: float = 0.1 * Global.player.passive_items.power("butcher") if is_instance_valid(Global.player) else 0.0
	return maxi(0, floori(ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count) * maxf(0.0, 1.0-discount)))

func try_reroll() -> bool:
	var price := get_reroll_cost()
	if Global.coins < price:
		SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
		return false
	var previous_keys: Array = []
	for card in items_container.get_children(): previous_keys.append(card.shop_item.get_offer_key())
	var locked := _locked_offer_keys()
	var required := 4 - locked.size()
	if required <= 0: return false
	var offers := select_shop_offers(shop_wave, locked, previous_keys)
	# An impossible refresh leaves both money and cards unchanged.
	if offers.size() != required: return false
	Global.coins -= price
	reroll_count += 1
	_populate_offers(offers)
	_update_reroll_button()
	return true

func _on_reroll_button_pressed() -> void:
	if try_reroll(): SoundManager.play_sound(SoundManager.Sound.SHOP_REROLL)

func _process(_delta: float) -> void:
	_update_reroll_button()
	if is_instance_valid(gamble_button): gamble_button.disabled = Global.coins <= 0
	_position_refresh_buttons()
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
	cancel_consumable_selection()
	_clear_liquidation_sales()
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

func try_purchase_item(item: ItemBase, price_wave: int = -1, price_override: int = -1) -> bool:
	if not item or not is_instance_valid(Global.player): return false
	if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and not item.available_for(Global.player): return false
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return false
	var price := item.get_shop_price(shop_wave if price_wave < 0 else price_wave)
	if price_override >= 0: price = clampi(price_override, 1, price)
	if Global.coins < price:
		SoundManager.play_sound(SoundManager.Sound.SHOP_NO_MONEY)
		return false
	if item.item_type == ItemBase.ItemType.WEAPON and Global.equipped_weapons.size() >= Global.player.get_weapon_limit():
		if not _get_auto_upgrade_card(item as ItemWeapon): return false
	Global.coins -= price
	_on_item_purchased(item)
	return true

func _on_item_purchased(item: ItemBase) -> void:
	if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and not item.available_for(Global.player): return
	if item is ItemWeapon and (not Progression.is_weapon_unlocked(item) or not Global.player.stats.can_use_weapon(item)): return
	SoundManager.play_sound(SoundManager.Sound.SHOP_BUY)
	if item is ItemWeapon and Global.equipped_weapons.size() >= Global.player.get_weapon_limit():
		_auto_upgrade_purchased_weapon(item as ItemWeapon)
		return
	if item is ItemPassive:
		(item as ItemPassive).apply_passive_values()
		if Global.player.passive_items.is_consumable(item):
			golden_control.refresh()
			breading_control.refresh()
			return
		for owned in passive_container.get_children():
			if owned is ItemCard and not owned.is_queued_for_deletion() and owned.item.get_offer_key() == item.get_offer_key() and owned.item.golden_multiplier == 1.0:
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
	Global.player.refresh_equipment_modifiers()
	existing.queue_free()
	var upgraded := _inherit_golden_upgrade(purchased.upgrade_to, [existing.data, purchased])
	Global.equipped_weapons[equipment_index] = upgraded
	SoundManager.play_sound(SoundManager.Sound.SHOP_COMBINE)
	Progression.record("combines", 1.0)
	Global.player.add_weapon(upgraded)
	card.item = upgraded
	card.weapon_instance = Global.player.current_weapons.back()
	Global.selected_weapon = upgraded
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
	if golden_control.try_select(card): return
	if breading_control.try_select(card): return
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
	equipped_guarantee_shown = false
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
		Global.player.refresh_equipment_modifiers()
		Global.equipped_weapons.erase(weapon.data)
		weapon.queue_free()
	
	for card: ItemCard in cards_to_remove:
		card.queue_free()
	
	var upgraded_weapon := _inherit_golden_upgrade(clicked_weapon.upgrade_to, [weapons_to_remove[0].data, weapons_to_remove[1].data])
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
		Global.player.refresh_equipment_modifiers()
		Global.equipped_weapons.erase(weapon_to_remove.data)
		weapon_to_remove.queue_free()
	
	context_card.queue_free()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	
	Global.coins += coins

func _clear_liquidation_sales() -> void:
	for card in items_container.get_children():
		if card is ShopCard: card.set_sale()

func _can_receive_two(item: ItemBase) -> bool:
	if not is_instance_valid(Global.player): return false
	var player := Global.player
	if item is ItemWeapon:
		return Progression.is_weapon_unlocked(item) and player.stats.can_use_weapon(item) and maxi(player.current_weapons.size(), Global.equipped_weapons.size()) + 2 <= player.get_weapon_limit()
	if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd":
		# Unique items can receive a percentage sale, never a second copy.
		if item.max_copies == 1: return false
		if not item.available_for(player): return false
		if item.max_copies > 0 and player.passive_items.count(item.effect_key) + 2 > item.max_copies: return false
		if item.effect_key == "extra_slot" and player.passive_items.count("extra_slot") + 2 > 3: return false
	return true

func _ensure_liquidation_offer() -> void:
	if not is_instance_valid(Global.player) or not Global.player.passive_items.liquidation_data: return
	var candidates: Array[ShopCard] = []
	var fallback: Array[ShopCard] = []
	for card in items_container.get_children():
		if not card is ShopCard or not card.shop_item: continue
		if card.has_sale(): return
		fallback.append(card)
		if not card.locked: candidates.append(card)
	if candidates.is_empty(): candidates = fallback
	if candidates.is_empty(): return
	var selected: ShopCard = candidates.pick_random()
	var data = Global.player.passive_items.liquidation_data
	var doubled: bool = randf() < data.two_for_one_chance and _can_receive_two(selected.shop_item)
	selected.set_sale(data.roll_sale_discount(), doubled)

func _build_golden_yolk_control() -> void:
	golden_control = load("res://scenes/ui/shop/golden_yolk_control.gd").new()
	golden_control.shop = self
	$MarginContainer/Control.add_child(golden_control)
	golden_control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	golden_control.offset_left = 785
	golden_control.offset_right = 925
	golden_control.offset_top = -205
	golden_control.offset_bottom = -145
	golden_control.target_selected.connect(func(card): apply_golden_yolk(card))
	golden_result = AcceptDialog.new()
	golden_result.title = "Yema de oro"
	add_child(golden_result)
	weapon_container.columns = 3
	for grid in [passive_container, weapon_container]:
		var scroll := ScrollContainer.new()
		scroll.name = "InventoryScroll"
		scroll.custom_minimum_size = Vector2(0, 180)
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.follow_focus = true
		grid.get_parent().add_child(scroll)
		if grid == weapon_container:
			var center := CenterContainer.new()
			center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			center.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			scroll.add_child(center)
			grid.reparent(center)
		else:
			grid.reparent(scroll)

func apply_golden_yolk(card: ItemCard, test_roll: float = -1.0) -> bool:
	if not is_instance_valid(Global.player) or not is_instance_valid(card) or card.is_queued_for_deletion(): return false
	if card.get_parent() != weapon_container and card.get_parent() != passive_container: return false
	var manager = Global.player.passive_items
	if manager.golden_yolks <= 0: return false
	var owned_record: Dictionary = {}
	if card.item is ItemPassive:
		owned_record = manager.find_owned_record(card.item)
		if owned_record.is_empty(): return false
	elif not is_instance_valid(card.weapon_instance) or not Global.player.current_weapons.has(card.weapon_instance):
		return false
	var enhancement = load("res://resources/items/golden_enhancement.gd")
	var config = load("res://resources/items/passives/catalogue/item_078.tres")
	var outcome: float = enhancement.roll_outcome(test_roll, config.golden_outcome_weights)
	manager.golden_yolks -= 1
	golden_control.cancel_selection()
	close_weapon_actions()
	weapon_tooltip.dismiss()
	var original := card.item
	var replacement: ItemBase = enhancement.improve(original, outcome) if outcome >= 0.0 else null
	if original is ItemWeapon:
		var weapon := card.weapon_instance
		weapon.weapon_behaviour.reset_attack()
		var index := Global.equipped_weapons.find(weapon.data)
		if replacement:
			if index >= 0: Global.equipped_weapons[index] = replacement
			weapon.data = replacement
			weapon.damage_record["weapon"] = replacement
			weapon._refresh_range()
			load("res://effects/golden_visual.gd").apply_weapon(weapon)
			card.item = replacement
		else:
			if index >= 0: Global.equipped_weapons.remove_at(index)
			Global.player.current_weapons.erase(weapon)
			weapon.queue_free()
			_discard_owned_card(card)
		Global.player.refresh_equipment_modifiers()
		Global.player.weapons_container.update_weapons_position(Global.player.current_weapons)
	else:
		manager.replace_owned(owned_record, replacement)
		if card.quantity > 1:
			card.quantity -= 1
			if replacement:
				var separated := create_item_card()
				passive_container.add_child(separated)
				separated.item = replacement
		elif replacement:
			card.item = replacement
		else:
			_discard_owned_card(card)
	# Revalidate offers after destroying a unique, even if it was locked.
	for offer in items_container.get_children():
		if offer.shop_item is ItemPassive and not offer.shop_item.available_for(Global.player):
			_refill_offer(offer.shop_item, offer)
	if manager.liquidation_data == null: _clear_liquidation_sales()
	context_card = null
	Global.selected_weapon = null
	combine_button.disabled = true
	golden_animation.play_upgrade(original, replacement, outcome)
	return true

func _discard_owned_card(card: ItemCard) -> void:
	card.get_parent().remove_child(card)
	card.queue_free()

func _inherit_golden_upgrade(base: ItemWeapon, donors: Array) -> ItemWeapon:
	var best: ItemWeapon = donors[0]
	for donor: ItemWeapon in donors:
		if donor.golden_multiplier > best.golden_multiplier: best = donor
	var result := base
	if best.golden_multiplier > 1.0:
		result = load("res://resources/items/golden_enhancement.gd").improve(base, best.golden_multiplier - 1.0, best.golden_penalty_multiplier)
		result.golden_perfect = best.golden_perfect
	return load("res://resources/items/breading.gd").inherit_tags(result, donors)

func _build_breading_control() -> void:
	breading_control = load("res://scenes/ui/shop/golden_yolk_control.gd").new()
	breading_control.shop = self
	breading_control.kind = "breading"
	breading_control.display_name = "Rebozado"
	$MarginContainer/Control.add_child(breading_control)
	breading_control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	breading_control.offset_left = 785
	breading_control.offset_right = 925
	breading_control.offset_top = -100
	breading_control.offset_bottom = -40
	breading_control.target_selected.connect(func(card): apply_breading(card))

func cancel_consumable_selection(except_control: Button = null) -> void:
	for control in [golden_control, breading_control]:
		if is_instance_valid(control) and control != except_control: control.cancel_selection()

func apply_breading(card: ItemCard, test_tag: int = -1) -> bool:
	if not is_instance_valid(Global.player) or not is_instance_valid(card) or card.is_queued_for_deletion(): return false
	if card.get_parent() != weapon_container or not card.item is ItemWeapon: return false
	if not is_instance_valid(card.weapon_instance) or not Global.player.current_weapons.has(card.weapon_instance): return false
	var manager = Global.player.passive_items
	if manager.breading_charges <= 0: return false
	var breading = load("res://resources/items/breading.gd")
	var choices: Array[int] = breading.available_tags(card.item, Global.player)
	if choices.is_empty():
		golden_result.title = "Rebozado"
		golden_result.dialog_text = "Esa arma ya tiene todas las tags compatibles. Elegí otra arma."
		if is_visible_in_tree(): golden_result.popup_centered(Vector2i(590, 180))
		return false
	var tag: int = choices.pick_random() if test_tag < 0 else test_tag
	if not choices.has(tag): return false
	var replacement: ItemWeapon = breading.add_tag(card.item, tag)
	var weapon := card.weapon_instance
	weapon.weapon_behaviour.reset_attack()
	var index := Global.equipped_weapons.find(weapon.data)
	if index >= 0: Global.equipped_weapons[index] = replacement
	weapon.data = replacement
	weapon.damage_record["weapon"] = replacement
	weapon._refresh_range()
	load("res://effects/golden_visual.gd").apply_weapon(weapon)
	card.item = replacement
	manager.breading_charges -= 1
	SoundManager.play_event("breading_apply")
	cancel_consumable_selection()
	Global.player.refresh_equipment_modifiers()
	close_weapon_actions()
	weapon_tooltip.dismiss()
	Global.selected_weapon = replacement
	golden_result.title = "Rebozado"
	golden_result.dialog_text = "%s recibió la tag %s." % [replacement.item_name, ItemWeapon.TAG_LABELS[tag]]
	if is_visible_in_tree(): golden_result.popup_centered(Vector2i(590, 180))
	return true

func set_pending_level_rewards(amount: int) -> void:
	pending_level_rewards = maxi(0, amount)
	var next_wave: int = next_stage_wave if next_stage_wave > 0 else shop_wave + 1
	$MarginContainer/Control/VBoxContainer/NewWaveButton.text = "UPGRADES (%d)" % pending_level_rewards if pending_level_rewards > 0 else "next wave %d" % next_wave

func show_ayahuasca_result(message: String) -> void:
	golden_result.title = "Ayahuasca"
	golden_result.dialog_text = message
	if is_visible_in_tree(): golden_result.popup_centered(Vector2i(620, 200))

func resolve_chocolate_coin(forced_outcome: int = -1) -> bool:
	var previous_balance := Global.coins
	var success := randf() < 0.5 if forced_outcome < 0 else forced_outcome == 1
	Global.coins = Global.coins * 2 if success else 0
	coin_animation.play(success, Global.coins, previous_balance)
	return success

func _ensure_test_consumable() -> void:
	if not is_instance_valid(Global.player): return
	var character: String = Global.player.stats.unlock_id
	var path := ""
	if test_hoarder_chocolate_coin and character == "hoarder": path = "res://resources/items/passives/catalogue/item_034.tres"
	elif test_glass_egg_golden_yolk and character == "glass_egg": path = "res://resources/items/passives/catalogue/item_078.tres"
	if path.is_empty(): return
	var test_item: ItemBase = load(path)
	var replacement: ShopCard
	for card: ShopCard in items_container.get_children():
		if card.shop_item.get_offer_key() == test_item.get_offer_key(): return
		if not card.locked and (not replacement or card.shop_item is ItemPassive): replacement = card
	# Preserve locked offers, including a fully locked shop.
	if replacement: replacement.shop_item = test_item

func _position_refresh_buttons() -> void:
	if not is_instance_valid(gamble_button): return
	var stats_panel := $MarginContainer/Control/StatsContainer as Control
	var gap := 12.0
	var coin_width := 64.0
	var group_width := reroll_button.size.x + (gap + coin_width if gamble_button.visible else 0.0)
	reroll_button.position.x = stats_panel.position.x + (stats_panel.size.x - group_width) * 0.5
	gamble_button.size = Vector2(coin_width, reroll_button.size.y)
	gamble_button.position = Vector2(reroll_button.position.x + reroll_button.size.x + gap, reroll_button.position.y + (reroll_button.size.y - gamble_button.size.y) * 0.5)
