# Anexo por script y shader

Índice estático exhaustivo del alcance. Los candidatos NO son defectos confirmados: incluyen estado, matemáticas, rutas y protecciones. Para tareas concretas, consultar el informe principal.

## autoload/combat_texts.gd

61 líneas; 0 anotaciones export; 0 uniforms; 10 candidatos.

Hallazgos: PERF-02.

### Candidatos / evidencia

- L3, `declaración` (constante): `const CAPACITY := 384`
- L4, `declaración` (constante): `const PREWARM := 64`
- L5, `declaración` (constante): `const TEXT_SCENE := preload("res://scenes/ui/floating_text/floating_text.tscn")`
- L6, `declaración` (regla/valor): `var active: Array = []`
- L7, `declaración` (regla/valor): `var available: Array = []`
- L8, `declaración` (regla/valor): `var created := 0`
- L9, `declaración` (regla/valor): `var pending_damage: Dictionary = {}`
- L24, `_process` (visual): `text.global_position = entry.position + Vector2.RIGHT.rotated(randf_range(0, TAU))`
- L38, `_create` (regla/valor): `created += 1`
- L44, `acquire` (literal adicional (revisión)): `else: release(active[0])`

## autoload/continuous_weapon_audio.gd

11 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.


## autoload/data_manager.gd

34 líneas; 0 anotaciones export; 0 uniforms; 5 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const SAVE_PATH := "user://save.cfg"`
- L17, `load_game` (regla/valor): `var err := config.load(SAVE_PATH)`
- L22, `load_game` (literal adicional (revisión)): `config.get_value("audio", "music_volume", 1.0)`
- L26, `load_game` (literal adicional (revisión)): `config.get_value("audio", "sfx_volume", 1.0)`
- L32, `load_game` (literal adicional (revisión)): `1`

## autoload/electric_rays.gd

123 líneas; 0 anotaciones export; 0 uniforms; 47 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const CAPACITY := 8192`
- L5, `declaración` (regla/valor): `var count := 0`
- L6, `declaración` (regla/valor): `var submitted_frame := -1`
- L8, `declaración` (regla/valor): `var bolt_batches: Dictionary = {}`
- L9, `declaración` (regla/valor): `var depth_batches: Array[WeakRef] = []`
- L14, `_depth_batch` (texto): `var key := "DepthBolts_%s_%s" % [rays,int(burst)]`
- L17, `_depth_batch` (texto): `batch = preload("res://effects/electric_bolt_batch.gd").new()`
- L19, `_depth_batch` (literal adicional (revisión)): `batch.configure(rays,burst,1)`
- L21, `_depth_batch` (visual): `if depth_batches.size()%64==0:`
- L27, `_ready` (literal adicional (revisión)): `process_priority = 1000`
- L29, `_ready` (literal adicional (revisión)): `z_index = 3`
- L31, `_ready` (visual): `mesh.size = Vector2.ONE`
- L38, `_ready` (literal adicional (revisión)): `instances.visible_instance_count = 0`
- L39, `_ready` (literal adicional (revisión)): `buffer.resize(CAPACITY*16)`
- L40, `_ready` (literal adicional (revisión)): `instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))`
- L44, `_ready` (texto): `ray_material.shader = preload("res://shaders/electric_ray.gdshader")`
- L47, `_ready` (literal adicional (revisión)): `_get_bolt_batch(7,false)`
- L48, `_ready` (literal adicional (revisión)): `_get_bolt_batch(7,true)`
- L51, `_get_bolt_batch` (regla/valor): `var key := Vector2i(rays,1 if burst else 0)`
- L53, `_get_bolt_batch` (texto): `var batch = preload("res://effects/electric_bolt_batch.gd").new()`
- L60, `submit_aura` (regla/valor): `if rays<=0: return`
- L61, `submit_aura` (literal adicional (revisión)): `_depth_batch(context,rays,false).submit_data(context,center,Color(tint,minf(1.0,left/0.25)),Color(extent.x,extent.y,elapsed,glow))`
- L64, `submit_burst` (regla/valor): `if rays<=0: return`
- L65, `submit_burst` (literal adicional (revisión)): `_depth_batch(context,rays,true).submit_data(context,Vector2.ZERO,Color(tint,(1.0-progress)*(1.0-progress)),Color(radius,progress,elapsed,glow))`
- L80, `submit` (literal adicional (revisión)): `count = 0`
- L83, `submit` (visual): `if points.size()<2: return`
- L85, `submit` (literal adicional (revisión)): `var start := world_transform*points[0]`
- L86, `submit` (literal adicional (revisión)): `for i in range(1,points.size()):`
- L91, `submit` (visual): `var size := Vector2(length+1.5,scaled_width)`
- L92, `submit` (literal adicional (revisión)): `var axis := direction/maxf(0.00001,length)`
- L93, `submit` (literal adicional (revisión)): `var segment_center := (start+end)*0.5`
- L94, `submit` (literal adicional (revisión)): `var offset := count*16`
- L97, `submit` (literal adicional (revisión)): `buffer[offset+1] = -axis.y*size.y`
- L98, `submit` (literal adicional (revisión)): `buffer[offset+3] = segment_center.x`
- L99, `submit` (literal adicional (revisión)): `buffer[offset+4] = axis.y*size.x`
- L100, `submit` (literal adicional (revisión)): `buffer[offset+5] = axis.x*size.y`
- L101, `submit` (literal adicional (revisión)): `buffer[offset+7] = segment_center.y`
- L102, `submit` (literal adicional (revisión)): `buffer[offset+8] = tint.r`
- L103, `submit` (literal adicional (revisión)): `buffer[offset+9] = tint.g`
- L104, `submit` (literal adicional (revisión)): `buffer[offset+10] = tint.b`
- L105, `submit` (literal adicional (revisión)): `buffer[offset+11] = tint.a`
- L106, `submit` (literal adicional (revisión)): `buffer[offset+12] = glow`
- L107, `submit` (regla/valor): `count += 1`
- L113, `_process` (regla/valor): `instances.visible_instance_count = count if submitted_frame==Engine.get_process_frames() else 0`
- L116, `clear` (literal adicional (revisión)): `count = 0`
- L117, `clear` (literal adicional (revisión)): `submitted_frame = -1`
- L118, `clear` (literal adicional (revisión)): `instances.visible_instance_count = 0`

## autoload/enemy_crowd.gd

228 líneas; 0 anotaciones export; 0 uniforms; 58 candidatos.

Hallazgos: PERF-01.

### Candidatos / evidencia

- L3, `declaración` (constante): `const CELL_SIZE := 96.0`
- L4, `declaración` (constante): `const GRID_INTERVAL := 0.05`
- L5, `declaración` (constante): `const MAX_NEIGHBORS := 16`
- L6, `declaración` (constante): `const MAX_CANDIDATES := 64`
- L7, `declaración` (constante): `const UPDATES_PER_FRAME := 32`
- L14, `declaración` (regla/valor): `var steering := Vector2.ZERO`
- L18, `declaración` (regla/valor): `var members: Dictionary = {}`
- L19, `declaración` (regla/valor): `var member_ids: Array[int] = []`
- L20, `declaración` (regla/valor): `var cells: Dictionary = {}`
- L21, `declaración` (regla/valor): `var offsets: Array[Vector2i] = []`
- L22, `declaración` (regla/valor): `var clock := 0.0`
- L23, `declaración` (regla/valor): `var grid_left := 0.0`
- L24, `declaración` (regla/valor): `var max_body_radius := 0.0`
- L25, `declaración` (regla/valor): `var checks_last_sample := 0`
- L26, `declaración` (regla/valor): `var cursor := 0`
- L29, `_ready` (literal adicional (revisión)): `process_priority = -100`
- L30, `_ready` (literal adicional (revisión)): `for x in range(-6,7):`
- L31, `_ready` (literal adicional (revisión)): `for y in range(-6,7): offsets.append(Vector2i(x,y))`
- L42, `register_enemy` (visual): `entry.position = enemy.global_position`
- L52, `register_enemy` (literal adicional (revisión)): `grid_left = 0.0`
- L65, `unregister_enemy` (literal adicional (revisión)): `max_body_radius = 0.0`
- L72, `_process` (regla/valor): `if grid_left <= 0.0:`
- L81, `_process` (regla/valor): `cursor += 1`
- L84, `_process` (regla/valor): `if not enemy.can_move or enemy.get_movement_multiplier()<=0.0 or (not enemy.movement_override_enabled and not enemy.can_move_towards_player() and enemy.knockback_power<=0):`
- L95, `rebuild` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health<=0: continue`
- L96, `rebuild` (visual): `entry.position = enemy.global_position`
- L97, `rebuild` (visual): `var cell := Vector2i((entry.position/CELL_SIZE).floor())`
- L103, `separation` (regla/valor): `if not members.has(id): return Vector2.ZERO`
- L109, `reset_steering` (regla/valor): `if members.has(id): members[id].steering = Vector2.ZERO`
- L115, `random_target` (literal adicional (revisión)): `for i in 8:`
- L119, `random_target` (regla/valor): `var eligible := 0`
- L123, `random_target` (regla/valor): `eligible += 1`
- L124, `random_target` (regla/valor): `if randi_range(1,eligible)==1: chosen = candidate`
- L131, `_bounce_candidate` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health<=0: return null`
- L135, `nearest` (regla/valor): `var center := Vector2i((origin/CELL_SIZE).floor())`
- L139, `nearest` (regla/valor): `if reach>6:`
- L143, `nearest` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not enemy.targetable or enemy.is_retiring or enemy.health_component.current_health<=0: continue`
- L154, `nearest` (regla/valor): `var corner := Vector2(key)*CELL_SIZE`
- L155, `nearest` (regla/valor): `var closest := Vector2(clampf(origin.x,corner.x,corner.x+CELL_SIZE),clampf(origin.y,corner.y,corner.y+CELL_SIZE))`
- L163, `nearest` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not enemy.targetable or enemy.is_retiring or enemy.health_component.current_health<=0: continue`
- L171, `nearby` (literal adicional (revisión)): `func nearby(origin: Vector2, radius: float, excluded: int, limit: int, y_ratio: float = 0.6) -> Array:`
- L172, `nearby` (regla/valor): `var center := Vector2i((origin/CELL_SIZE).floor())`
- L174, `nearby` (regla/valor): `var found: Array = []`
- L175, `nearby` (regla/valor): `var checked := 0`
- L181, `nearby` (regla/valor): `checked += 1`
- L184, `nearby` (literal adicional (revisión)): `delta.y /= maxf(0.01,y_ratio)`
- L187, `nearby` (regla/valor): `if is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.targetable and not enemy.is_retiring and enemy.health_component.current_health>0:`
- L190, `nearby` (regla/valor): `if checked>=128: return found`
- L196, `_calculate` (regla/valor): `var cell := Vector2i((center/CELL_SIZE).floor())`
- L198, `_calculate` (regla/valor): `var steering := Vector2.ZERO`
- L199, `_calculate` (regla/valor): `var neighbors := 0`
- L200, `_calculate` (regla/valor): `var checked := 0`
- L206, `_calculate` (literal adicional (revisión)): `var start := (id+int(clock*10))%bucket.size()`
- L207, `_calculate` (literal adicional (revisión)): `var samples := mini(bucket.size(),4)`
- L212, `_calculate` (regla/valor): `checked += 1`
- L218, `_calculate` (regla/valor): `if distance_squared>0.001:`
- L220, `_calculate` (regla/valor): `neighbors += 1`
- L226, `_calculate` (literal adicional (revisión)): `entry.steering = entry.steering.lerp(steering.limit_length(1.0),0.5)`

## autoload/global.gd

236 líneas; 0 anotaciones export; 0 uniforms; 66 candidatos.

Hallazgos: BASE-01, BASE-02, BASE-06, UNIT-01.

### Candidatos / evidencia

- L19, `declaración` (constante): `const GAME_ENTITY_SCALE := 1.5`
- L20, `declaración` (constante): `const STARTING_COINS := 25`
- L21, `declaración` (constante): `const MAX_EQUIPPED_WEAPONS := 6`
- L23, `declaración` (constante): `const FLASH_MATERIAL = preload("res://effects/flash_material.tres")`
- L24, `declaración` (constante): `const FLOATING_TEXT_SCENE = preload("res://scenes/ui/floating_text/floating_text.tscn")`
- L27, `declaración` (constante): `const COINS_SCENE = preload("res://scenes/coins/coins.tscn")`
- L28, `declaración` (constante): `const ITEM_CARD_SCENE = preload("res://scenes/ui/shop/item_card.tscn")`
- L29, `declaración` (constante): `const SPAWN_EFFECT_SCENE = preload("res://scenes/effects/spawn_effect.tscn")`
- L30, `declaración` (constante): `const FRIED_SCENE = preload("res://scenes/units/fried.tscn")`
- L33, `declaración` (constante): `const UPGRADE_PROBABILITY_CONFIG = {"policy": "upgrade_cumulative_base"}`
- L36, `declaración` (constante): `const SHOP_PROBABILITY_CONFIG = {"policy": "shop_cumulative_base"}`
- L38, `declaración` (constante): `const TIER_COLORS: Dictionary[UpgradeTier, Color] = {`
- L39, `declaración` (literal adicional (revisión)): `UpgradeTier.RARE: Color(.4, .857, .41),`
- L40, `declaración` (literal adicional (revisión)): `UpgradeTier.EPIC: Color(.478, .251, .71),`
- L41, `declaración` (literal adicional (revisión)): `UpgradeTier.LEGENDARY: Color(.906, .212, .212)`
- L51, `declaración` (regla/valor): `var available_players: Dictionary[String, PackedScene] = {`
- L52, `declaración` (texto): `"Well Rounded": preload("res://scenes/units/players/player_well_rounded.tscn"),`
- L53, `declaración` (texto): `"Tiny Egg": preload("res://scenes/units/players/player_tiny_egg.tscn"),`
- L54, `declaración` (texto): `"Hardboiled": preload("res://scenes/units/players/player_hardboiled.tscn"),`
- L55, `declaración` (texto): `"Mutant": preload("res://scenes/units/players/player_mutant.tscn"),`
- L56, `declaración` (texto): `"Vampire": preload("res://scenes/units/players/player_vampire.tscn"),`
- L57, `declaración` (texto): `"Gambler": preload("res://scenes/units/players/player_gambler.tscn"),`
- L58, `declaración` (texto): `"Scrapper": preload("res://scenes/units/players/player_scrapper.tscn"),`
- L59, `declaración` (texto): `"Glass Egg": preload("res://scenes/units/players/player_glass_egg.tscn"),`
- L60, `declaración` (texto): `"Hoarder": preload("res://scenes/units/players/player_hoarder.tscn"),`
- L61, `declaración` (texto): `"Berserker": preload("res://scenes/units/players/player_berserker.tscn"),`
- L66, `declaración` (regla/valor): `var yolk_reserve: int = 0`
- L69, `declaración` (regla/valor): `var coop_players: Array[Player] = []`
- L72, `live_players` (regla/valor): `var result: Array[Player] = []`
- L74, `live_players` (regla/valor): `if is_instance_valid(actor) and not actor.is_queued_for_deletion() and actor.health_component.current_health>0: result.append(actor)`
- L75, `live_players` (regla/valor): `if coop_players.is_empty() and is_instance_valid(player) and not player.is_queued_for_deletion() and player.health_component.current_health>0: result.append(player)`
- L104, `players_clear_of` (regla/valor): `var level_reached := 0`
- L105, `players_clear_of` (regla/valor): `var level_selected := 0`
- L108, `get_starting_weapons` (regla/valor): `var result: Array[ItemWeapon] = []`
- L130, `collect_yolk` (literal adicional (revisión)): `var base := maxi(0, base_value)`
- L154, `get_chance_succes` (regla/valor): `var random = randf_range(0, 1)`
- L164, `calculate_tier_probability` (texto): `return load("res://resources/shop_rarity.gd").probabilities(current_wave)`
- L166, `calculate_tier_probability` (texto): `return load("res://resources/upgrade_rarity.gd").probabilities(current_wave)`
- L167, `calculate_tier_probability` (literal adicional (revisión)): `var common_chance := .0`
- L168, `calculate_tier_probability` (literal adicional (revisión)): `var rare_chance := .0`
- L169, `calculate_tier_probability` (literal adicional (revisión)): `var epic_chance := .0`
- L170, `calculate_tier_probability` (literal adicional (revisión)): `var legendary_chance := .0`
- L174, `calculate_tier_probability` (literal adicional (revisión)): `rare_chance = clampf((current_wave - 1) * config.rare.base_mult, 0.0, 1.0)`
- L177, `calculate_tier_probability` (literal adicional (revisión)): `epic_chance = clampf((current_wave - 3) * config.epic.base_mult, 0.0, 1.0)`
- L180, `calculate_tier_probability` (literal adicional (revisión)): `legendary_chance = clampf((current_wave - 6) * config.legendary.base_mult, 0.0, 1.0)`
- L184, `calculate_tier_probability` (regla/valor): `var luck_factor := 1.0 + (Global.player.stats.luck / 100)`
- L191, `calculate_tier_probability` (regla/valor): `if total_non_common_chance > 1.0:`
- L192, `calculate_tier_probability` (visual): `var scale_down := 1.0 / total_non_common_chance`
- L196, `calculate_tier_probability` (literal adicional (revisión)): `total_non_common_chance = 1.0`
- L198, `calculate_tier_probability` (literal adicional (revisión)): `common_chance = 1.0 - total_non_common_chance`
- L204, `calculate_tier_probability` (literal adicional (revisión)): `max(.0, common_chance),`
- L205, `calculate_tier_probability` (literal adicional (revisión)): `max(.0, rare_chance),`
- L206, `calculate_tier_probability` (literal adicional (revisión)): `max(.0, epic_chance),`
- L207, `calculate_tier_probability` (literal adicional (revisión)): `max(.0, legendary_chance)`
- L210, `select_items_for_offer` (literal adicional (revisión)): `func select_items_for_offer(item_pool: Array, current_wave: int, config: Dictionary, offer_count: int = 4, excluded_keys: Array = [], candidate_selector: Callable = Callable()) -> Array:`
- L214, `select_items_for_offer` (regla/valor): `var offers: Array = []`
- L216, `select_items_for_offer` (regla/valor): `var tier := 0`
- L218, `select_items_for_offer` (texto): `tier = load("res://resources/shop_rarity.gd").roll_tier(current_wave)`
- L220, `select_items_for_offer` (texto): `tier = load("res://resources/upgrade_rarity.gd").roll_tier(current_wave)`
- L223, `select_items_for_offer` (regla/valor): `if roll < chances[3]: tier = 3`
- L224, `select_items_for_offer` (regla/valor): `elif roll < chances[3] + chances[2]: tier = 2`
- L225, `select_items_for_offer` (regla/valor): `elif roll < chances[3] + chances[2] + chances[1]: tier = 1`
- L226, `select_items_for_offer` (regla/valor): `var candidates: Array = []`
- L227, `select_items_for_offer` (literal adicional (revisión)): `while candidates.is_empty() and tier >= 0:`
- L229, `select_items_for_offer` (literal adicional (revisión)): `tier -= 1`
- L231, `select_items_for_offer` (regla/valor): `candidates = remaining.filter(func(item: ItemBase): return chances[item.item_tier] > 0.0)`

## autoload/menu_input.gd

265 líneas; 0 anotaciones export; 0 uniforms; 32 candidatos.

Hallazgos: INPUT-01.

### Candidatos / evidencia

- L3, `declaración` (constante): `const FIRST_REPEAT_DELAY := 0.35`
- L4, `declaración` (constante): `const REPEAT_INTERVAL := 0.12`
- L5, `declaración` (regla/valor): `var menus: Array[Control] = []`
- L7, `declaración` (regla/valor): `var held_direction := Vector2.ZERO`
- L8, `declaración` (regla/valor): `var repeat_left := 0.0`
- L10, `declaración` (regla/valor): `var connected_gamepads: Array[int] = []`
- L13, `declaración` (regla/valor): `var last_device := -1`
- L15, `declaración` (regla/valor): `var remembered_focus: Dictionary = {}`
- L32, `_set_gamepad_active` (literal adicional (revisión)): `repeat_left = 0.0`
- L46, `_on_joy_connection_changed` (literal adicional (revisión)): `repeat_left = 0.0`
- L72, `_ready` (literal adicional (revisión)): `event.button_index = binding[1]`
- L73, `_ready` (regla/valor): `if not InputMap.action_has_event(binding[0], event): InputMap.action_add_event(binding[0], event)`
- L74, `_ready` (literal adicional (revisión)): `for binding in [["ui_left", JOY_AXIS_LEFT_X, -1.0], ["ui_right", JOY_AXIS_LEFT_X, 1.0], ["ui_up", JOY_AXIS_LEFT_Y, -1.0], ["ui_down", JOY_AXIS_LEFT_Y, 1.0]]:`
- L76, `_ready` (literal adicional (revisión)): `event.axis = binding[1]`
- L77, `_ready` (literal adicional (revisión)): `event.axis_value = binding[2]`
- L78, `_ready` (regla/valor): `if not InputMap.action_has_event(binding[0], event): InputMap.action_add_event(binding[0], event)`
- L79, `_ready` (literal adicional (revisión)): `InputMap.action_set_deadzone(binding[0], 0.45)`
- L102, `_controls` (regla/valor): `var result: Array[Control] = []`
- L126, `_initial_focus` (literal adicional (revisión)): `controls[0].grab_focus()`
- L138, `_process` (literal adicional (revisión)): `repeat_left = 0.0`
- L145, `_process` (texto): `var direction := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))`
- L146, `_process` (regla/valor): `if direction.length() < 0.2:`
- L148, `_process` (literal adicional (revisión)): `repeat_left = 0.0`
- L150, `_process` (regla/valor): `direction = Vector2(signf(direction.x), 0.0) if absf(direction.x) > absf(direction.y) else Vector2(0.0, signf(direction.y))`
- L156, `_process` (regla/valor): `elif repeat_left <= 0.0:`
- L167, `move_focus` (regla/valor): `if focused is HSlider and direction.x != 0.0:`
- L177, `move_focus` (regla/valor): `if forward <= 1.0: continue`
- L179, `move_focus` (literal adicional (revisión)): `var score := offset.length() + sideways * 2.0`
- L197, `_input` (literal adicional (revisión)): `last_device=-1`
- L209, `_input` (regla/valor): `elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.45:`
- L213, `_input` (regla/valor): `elif event is InputEventMouseMotion and event.relative.length_squared() >= 4.0:`
- L218, `_input` (literal adicional (revisión)): `if menu.name == "PausePanel" and event.is_action("pause"): return`

## autoload/progression.gd

193 líneas; 0 anotaciones export; 0 uniforms; 39 candidatos.

Hallazgos: BASE-05.

### Candidatos / evidencia

- L6, `declaración` (constante): `const SAVE_PATH := "user://progress.cfg"`
- L7, `declaración` (constante): `const INITIAL_CHARACTERS := ["well_rounded"]`
- L8, `declaración` (constante): `const INITIAL_WEAPONS := ["spatula", "b_knife", "knifer", "hydrant"]`
- L9, `declaración` (constante): `const ACHIEVEMENT_IDS := ["tiny_egg", "hardboiled", "mutant", "vampire", "gambler", "scrapper", "glass_egg", "hoarder", "berserker", "wood_mace", "blender", "mitten", "corpse_l", "smasher"]`
- L12, `declaración` (regla/valor): `var achievements: Array[Resource] = []`
- L13, `declaración` (regla/valor): `var completed: Array[String] = []`
- L14, `declaración` (regla/valor): `var counters: Dictionary = {}`
- L15, `declaración` (regla/valor): `var unlocked_characters: Array[String] = []`
- L16, `declaración` (regla/valor): `var unlocked_weapons: Array[String] = []`
- L18, `declaración` (regla/valor): `var current_character := ""`
- L22, `declaración` (regla/valor): `var save_delay := 0.0`
- L23, `declaración` (regla/valor): `var testing_unlock_override := -1`
- L28, `_ready` (texto): `achievements.append(load("res://resources/unlocks/%s.tres" % id))`
- L34, `_process` (regla/valor): `if save_delay <= 0.0: save_progress()`
- L43, `load_progress` (literal adicional (revisión)): `testing_unlock_override = -1`
- L44, `load_progress` (regla/valor): `if config.load(save_path) == OK:`
- L45, `load_progress` (literal adicional (revisión)): `testing_unlock_override = int(config.get_value("testing", "unlock_override", -1))`
- L46, `load_progress` (literal adicional (revisión)): `Global.level_reached = clampi(int(config.get_value("progress", "difficulty", 0)), 0, 5)`
- L56, `load_progress` (literal adicional (revisión)): `counters[key] = maxf(0.0, float(value))`
- L63, `save_progress` (literal adicional (revisión)): `config.set_value("progress", "version", 1)`
- L72, `save_progress` (literal adicional (revisión)): `save_delay = 5.0`
- L95, `_testing_unlocks_enabled` (regla/valor): `if testing_unlock_override >= 0: return testing_unlock_override == 1`
- L102, `debug_reset_progress` (literal adicional (revisión)): `testing_unlock_override = 0`
- L103, `debug_reset_progress` (literal adicional (revisión)): `Global.level_reached = 0`
- L104, `debug_reset_progress` (literal adicional (revisión)): `Global.level_selected = 0`
- L110, `debug_unlock_all` (literal adicional (revisión)): `testing_unlock_override = 0`
- L111, `debug_unlock_all` (literal adicional (revisión)): `Global.level_reached = 5`
- L117, `_finish_debug_progress_change` (literal adicional (revisión)): `current_character = ""`
- L128, `requirement_for` (literal adicional (revisión)): `var progress := minf(float(counters.get(achievement.metric, 0.0)), achievement.goal)`
- L150, `finish_wave` (texto): `if not wave_damaged: record("flawless_waves", 1.0)`
- L155, `end_run` (texto): `if won: record("win:" + current_character, 1.0)`
- L158, `end_run` (literal adicional (revisión)): `current_character = ""`
- L162, `record` (regla/valor): `if not run_active or amount <= 0.0: return`
- L163, `record` (literal adicional (revisión)): `counters[metric] = float(counters.get(metric, 0.0)) + amount`
- L172, `check_stats` (regla/valor): `if value > float(counters.get(achievement.metric, 0.0)):`
- L179, `_changed` (literal adicional (revisión)): `save_delay = 0.75`
- L180, `_changed` (regla/valor): `var rewards: Array[String] = []`
- L183, `_changed` (regla/valor): `if float(counters.get(achievement.metric, 0.0)) >= achievement.goal:`
- L193, `_number` (regla/valor): `return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")`

## autoload/sound_manager.gd

243 líneas; 81 anotaciones export; 0 uniforms; 18 candidatos.

Hallazgos: AUDIO-01, AUDIO-02.

### Ya expuesto en el editor

- L3: `@export var stream_players: Array[AudioStreamPlayer]`
- L5: `@export_group("Menus e interfaz")`
- L6: `@export var ui_hover: AudioStream`
- L7: `@export var ui_accept: AudioStream`
- L8: `@export var ui_play: AudioStream`
- L9: `@export var ui_back: AudioStream`
- L10: `@export var selection_hover: AudioStream`
- L11: `@export var selection_accept: AudioStream`
- L12: `@export var selection_invalid: AudioStream`
- L13: `@export_group("Oleadas")`
- L14: `@export var wave_start: AudioStream`
- L15: `@export var wave_final_seconds: AudioStream`
- L16: `@export var wave_complete: AudioStream`
- L17: `@export var run_defeat: AudioStream`
- L18: `@export_group("Combate")`
- L19: `@export var hit_al_enemigo: AudioStream`
- L20: `@export var critico_al_enemigo: AudioStream`
- L21: `@export var hit_al_player: AudioStream`
- L22: `@export var hit_bloqueado_al_player: AudioStream`
- L23: `@export_group("Tienda")`
- L24: `@export var shop_reroll: AudioStream`
- L25: `@export var shop_lock: AudioStream`
- L26: `@export var shop_unlock: AudioStream`
- L27: `@export var shop_buy: AudioStream`
- L28: `@export var shop_no_money: AudioStream`
- L29: `@export var shop_sell: AudioStream`
- L30: `@export var shop_combine: AudioStream`
- L31: `@export_group("Desbloqueos")`
- L32: `@export var unlock_reveal: AudioStream`
- L33: `@export var unlock_sequence_start: AudioStream`
- L34: `@export var unlock_sequence_end: AudioStream`
- L35: `@export_group("Recoleccion")`
- L36: `@export var yolk_pickup: AudioStream`
- L37: `@export_group("Escenarios")`
- L38: `@export var fueguito: AudioStream`
- L39: `@export var bubble_explosion: AudioStream`
- L40: `@export var spatula_impact: AudioStream`
- L41: `@export_group("Armas - impactos especiales")`
- L42: `@export var plate_break: AudioStream`
- L43: `@export_group("Armas por defecto")`
- L44: `@export var default_ranged_attack: AudioStream`
- L45: `@export var default_melee_attack: AudioStream`
- L46: `@export_group("Jugador y recompensas")`
- L47: `@export var dash: AudioStream`
- L48: `@export var enemy_death: AudioStream`
- L49: `@export var yolker_burst: AudioStream`
- L50: `@export var incognito_confetti: AudioStream`
- L51: `@export var level_up: AudioStream`
- L52: `@export_group("Estados")`
- L53: `@export var burning_apply: AudioStream`
- L54: `@export var electric_apply: AudioStream`
- L55: `@export_group("Explosiones y ataques continuos")`
- L56: `@export var explosion: AudioStream`
- L57: `@export var default_continuous_attack: AudioStream`
- L58: `@export_group("Moneda de chocolate")`
- L59: `@export var coin_spin: AudioStream`
- L60: `@export var coin_reveal: AudioStream`
- L61: `@export var coin_win: AudioStream`
- L62: `@export var coin_lose: AudioStream`
- L63: `@export_group("Yema de oro y Rebozado")`
- L64: `@export var golden_anticipation: AudioStream`
- L65: `@export var golden_impact: AudioStream`
- L66: `@export var golden_reveal: AudioStream`
- L67: `@export var golden_success: AudioStream`
- L68: `@export var golden_broken: AudioStream`
- L69: `@export var breading_apply: AudioStream`
- L70: `@export_group("Boss")`
- L71: `@export var laser_warning: AudioStream`
- L72: `@export var laser_fire: AudioStream`
- L73: `@export var turret_spawn: AudioStream`
- L74: `@export var boss_jump: AudioStream`
- L75: `@export var boss_fall_warning: AudioStream`
- L76: `@export var boss_impact: AudioStream`
- L77: `@export_group("Fueguitos - todos los escenarios")`
- L78: `@export var fueguito_spawn: AudioStream`
- L79: `@export var fueguito_exit: AudioStream`
- L81: `@export_group("Limites")`
- L82: `@export_range(1, 16) var maximum_event_voices := 4`
- L83: `@export_range(-40.0, 6.0) var sfx_gain_db := 0.0`
- L84: `@export_group("Volumen por evento (dB)")`
- L86: `@export var event_gain_db: Dictionary = {}`

### Candidatos / evidencia

- L87, `declaración` (regla/valor): `var event_times: Dictionary = {}`
- L89, `declaración` (regla/valor): `var sfx_volume : float = 1.0`
- L90, `declaración` (regla/valor): `var music_volume : float = 1.0`
- L151, `play_sound` (literal adicional (revisión)): `if type == Sound.UI_CLICK: key = "ui_accept"`
- L152, `play_sound` (literal adicional (revisión)): `if type == Sound.FIRE: key = "default_ranged_attack"`
- L153, `play_sound` (literal adicional (revisión)): `if type == Sound.PUNCH: key = "default_melee_attack"`
- L156, `play_stream` (literal adicional (revisión)): `func play_stream(audio: AudioStream, event: String = "weapon_attack") -> void:`
- L159, `play_stream` (regla/valor): `if now - int(event_times.get(event,-1000)) < 40: return`
- L160, `play_stream` (regla/valor): `var voices := 0`
- L162, `play_stream` (texto): `if player.playing and player.get_meta("sfx_event","") == event: voices += 1`
- L169, `play_stream` (regla/valor): `player.volume_db = sfx_gain_db + float(event_gain_db.get(event,0.0))`
- L172, `play_stream` (texto): `player.pitch_scale = 1.0 if event.begins_with("ui_") or event.begins_with("selection_") else randf_range(0.95,1.05)`
- L178, `play_event` (literal adicional (revisión)): `if event == "fueguito_spawn" and not audio: audio = fueguito`
- L190, `set_weapon_loop` (texto): `player.set_script(preload("res://autoload/continuous_weapon_audio.gd"))`
- L191, `set_weapon_loop` (literal adicional (revisión)): `player.name = "ContinuousAudio"`
- L195, `set_weapon_loop` (regla/valor): `player.volume_db = sfx_gain_db`
- L222, `_hook_button` (literal adicional (revisión)): `if button.text.to_upper() == "BACK":`
- L231, `_hook_button` (texto): `var event := Sound.UI_PLAY if name_lower == "playbutton" else Sound.UI_BACK if "back" in name_lower or "return" in name_lower or "exit" in name_lower else Sound.UI_ACCEPT`

## autoload/ui_theme.gd

214 líneas; 0 anotaciones export; 0 uniforms; 50 candidatos.

Hallazgos: UI-01, UI-02.

### Candidatos / evidencia

- L5, `declaración` (constante): `const PALETTES := {`
- L6, `declaración` (texto): `"cream": preload("res://resources/ui/palettes/cream.tres"),`
- L7, `declaración` (texto): `"sage": preload("res://resources/ui/palettes/sage.tres"),`
- L8, `declaración` (texto): `"cocoa": preload("res://resources/ui/palettes/cocoa.tres")`
- L10, `declaración` (constante): `const FONT = preload("res://assets/font/Bake Soda.otf")`
- L13, `declaración` (regla/valor): `var tier_styles: Array[StyleBoxFlat] = []`
- L32, `rich_text` (texto): `return text.replace("color=green]", "color=%s]" % color_hex("positive")).replace("[color=#ff6969]", "[color=%s]" % color_hex("negative")).replace("[color=#ffe395]", "[color=%s]" % color_hex("accent"))`
- L34, `box` (literal adicional (revisión)): `func box(fill: Color, edge: Color, radius: int = -1, border: int = -1) -> StyleBoxFlat:`
- L38, `box` (regla/valor): `style.set_border_width_all(palette.border_width if border < 0 else border)`
- L39, `box` (regla/valor): `style.set_corner_radius_all(palette.radius if radius < 0 else radius)`
- L41, `box` (literal adicional (revisión)): `style.set_content_margin_all(0)`
- L45, `focus_style` (visual): `return box(Color.TRANSPARENT, palette.focus, -1, palette.focus_width)`
- L66, `_update_button_focus` (texto): `var key: String = "ui_focus_saved_" + state`
- L69, `_update_button_focus` (texto): `button.add_theme_stylebox_override(state, button.get_theme_stylebox("hover" if state == "normal" else "hover_pressed"))`
- L70, `_update_button_focus` (texto): `button.add_theme_stylebox_override("focus", focus_style())`
- L74, `_clear_button_focus` (texto): `var key: String = "ui_focus_saved_" + state`
- L77, `_clear_button_focus` (visual): `if saved[0]: button.add_theme_stylebox_override(state, saved[1])`
- L95, `tier_style` (regla/valor): `return tier_styles[clampi(tier, 0, 3)]`
- L98, `selected_tier_style` (regla/valor): `return box(palette.surface.lerp(palette.button, 0.15), palette.focus, -1, 3)`
- L103, `_button_styles` (literal adicional (revisión)): `"hover": box(palette.hover_surface, palette.focus, -1, palette.focus_width),`
- L104, `_button_styles` (literal adicional (revisión)): `"pressed": box(base.lerp(palette.outline, 0.12), palette.focus, -1, 3),`
- L105, `_button_styles` (literal adicional (revisión)): `"hover_pressed": box(palette.hover_selected, palette.focus, -1, palette.focus_width),`
- L106, `_button_styles` (literal adicional (revisión)): `"disabled": box(palette.disabled, palette.disabled_text.lerp(palette.disabled, 0.6)),`
- L110, `style_slot` (literal adicional (revisión)): `func style_slot(button: Button, tier: int = 0) -> void:`
- L115, `style_slot` (literal adicional (revisión)): `states.normal.set_border_width_all(3)`
- L117, `style_slot` (visual): `button.add_theme_stylebox_override(state, states[state])`
- L123, `_rebuild` (literal adicional (revisión)): `ui_theme.default_font_size = 24`
- L127, `_rebuild` (literal adicional (revisión)): `ui_theme.set_constant("outline_size", "HudLabel", 4)`
- L133, `_rebuild` (literal adicional (revisión)): `if type_name != "Button": ui_theme.set_type_variation(type_name, "Button")`
- L134, `_rebuild` (texto): `var fill: Color = palette.primary if type_name == "PrimaryButton" else (palette.danger if type_name == "DangerButton" else palette.button)`
- L142, `_rebuild` (literal adicional (revisión)): `var fill: Color = palette.text.lerp(palette.button, 0.12) if state.begins_with("hover") else palette.text`
- L143, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox(state, "HeldButton", box(fill, palette.button, -1, 3))`
- L149, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox("panel", "ScreenPanel", box(palette.background, Color.TRANSPARENT, 0, 0))`
- L151, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox("panel", "InsetPanel", box(palette.inset, Color.TRANSPARENT, 8, 0))`
- L153, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox("panel", "OverlayPanel", box(Color(0.05, 0.04, 0.03, 0.65), Color.TRANSPARENT, 0, 0))`
- L155, `_rebuild` (texto): `var track := box(palette.inset if state == "slider" else palette.primary, palette.focus if state == "grabber_area_highlight" else palette.outline, 6, 2)`
- L156, `_rebuild` (literal adicional (revisión)): `track.content_margin_top = 6`
- L157, `_rebuild` (literal adicional (revisión)): `track.content_margin_bottom = 6`
- L162, `_rebuild` (texto): `var fill: Color = palette.disabled if icon_name == "grabber_disabled" else palette.primary`
- L163, `_rebuild` (literal adicional (revisión)): `image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28"><circle cx="14" cy="14" r="11" fill="#%s" stroke="#%s" stroke-width="3"/></svg>' % [fill.to_html(false), palette.outline.to_html(false)])`
- L166, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox("scroll", scrollbar, box(palette.inset, Color.TRANSPARENT, 6, 0))`
- L168, `_rebuild` (literal adicional (revisión)): `ui_theme.set_stylebox(state, scrollbar, box(palette.button, palette.outline, 6, 1))`
- L170, `_rebuild` (literal adicional (revisión)): `for tier in 4: tier_styles.append(box(palette.surface, palette.rarity(tier), -1, 3))`
- L186, `apply_control` (literal adicional (revisión)): `if ancestor.name == "GameUI" or ancestor.scene_file_path.begins_with("res://scenes/ui/"): ui = true`
- L195, `apply_control` (texto): `if portrait.material is ShaderMaterial: portrait.material.set_shader_parameter("silhouette_color", palette.muted)`
- L196, `apply_control` (texto): `if node is Panel and node.has_meta("ui_tier"): node.add_theme_stylebox_override("panel", tier_style(node.get_meta("ui_tier")))`
- L205, `apply_control` (literal adicional (revisión)): `node.label_settings.font_color = palette.hud_text if node.get_meta("ui_color") == "hud" else palette.get(node.get_meta("ui_color"))`
- L207, `apply_control` (texto): `node.add_theme_color_override("font_color", palette.hud_text if node.get_meta("ui_color") == "hud" else palette.get(node.get_meta("ui_color")))`
- L208, `apply_control` (literal adicional (revisión)): `if node is Label and node.name in ["CoinsLabel", "ReserveLabel"] and node.get_parent().get_parent().get_parent().name == "GameUI":`
- L209, `apply_control` (texto): `node.add_theme_color_override("font_color", palette.hud_text)`

## coins_bag.gd

27 líneas; 0 anotaciones export; 0 uniforms; 6 candidatos.

### Candidatos / evidencia

- L16, `_process` (texto): `coins_label.text = str(shown_balance)`
- L17, `_process` (texto): `reserve_label.text = str(Global.yolk_reserve)`
- L21, `_process` (regla/valor): `var balance:=0`
- L22, `_process` (regla/valor): `var reserve:=0`
- L26, `_process` (texto): `coins_label.text=str(balance)`
- L27, `_process` (texto): `reserve_label.text=str(reserve)`

## effects/arena_bursts.gd

68 líneas; 0 anotaciones export; 0 uniforms; 21 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const MAX_PARTICLES := 4096`
- L4, `declaración` (regla/valor): `var particles: Array[Dictionary] = []`
- L11, `emit_at` (texto): `emitter = load("res://effects/arena_bursts.gd").new()`
- L12, `emit_at` (literal adicional (revisión)): `emitter.name = "ArenaBursts"`
- L19, `_ready` (literal adicional (revisión)): `z_index = 8`
- L23, `emit_burst` (regla/valor): `var count := 28 if impact else 6`
- L28, `emit_burst` (regla/valor): `if impact and footprint.x > 0:`
- L29, `emit_burst` (literal adicional (revisión)): `var half := footprint * 0.5`
- L30, `emit_burst` (regla/valor): `var edge := Vector2(-half.x if i%2 == 0 else half.x, randf_range(-half.y,half.y)) if i%4 < 2 else Vector2(randf_range(-half.x,half.x), -half.y if i%2 == 0 else half.y)`
- L32, `emit_burst` (regla/valor): `angle = edge.angle() + randf_range(-0.5,0.5)`
- L33, `emit_burst` (regla/valor): `var velocity := Vector2.from_angle(angle) * randf_range(180,420) if impact else Vector2.from_angle(angle) * randf_range(45,95)`
- L34, `emit_burst` (regla/valor): `if impact: velocity.y *= 0.55`
- L35, `emit_burst` (regla/valor): `var duration := randf_range(0.28,0.48) if impact else randf_range(0.22,0.34)`
- L36, `emit_burst` (texto): `particles.append({"position":origin,"velocity":velocity,"life":duration,"duration":duration,"radius":randf_range(3,7),"impact":impact,"color":Color("fff2ce") if i%2 == 0 else Color("d7b477")})`
- L41, `_process` (literal adicional (revisión)): `for i in range(particles.size()-1,-1,-1):`
- L45, `_process` (regla/valor): `if p.life <= 0:`
- L49, `_process` (literal adicional (revisión)): `p.velocity *= exp(-5.0 * delta)`
- L55, `_draw` (literal adicional (revisión)): `var fade: float = clampf(p.life/p.duration,0,1)`
- L58, `_draw` (literal adicional (revisión)): `var radius: float = p.radius * (0.4+0.6*fade)`
- L61, `_draw` (literal adicional (revisión)): `draw_line(p.position-direction*radius,p.position+direction*radius,color,4.0,true)`
- L63, `_draw` (literal adicional (revisión)): `draw_circle(p.position,radius,color,true,-1,true)`

## effects/breading_hit.gd

46 líneas; 0 anotaciones export; 0 uniforms; 10 candidatos.

### Candidatos / evidencia

- L6, `on_damage` (literal adicional (revisión)): `_process_record(hit, target, dealt, hit.weapon_damage_record, 1.0)`
- L21, `_apply` (regla/valor): `if item.breading_explosion_radius <= 0.0 and item.breading_slow_strength <= 0.0 and item.breading_status_effects.is_empty(): return`
- L23, `_apply` (literal adicional (revisión)): `template.setup(amount, false, 0.0, original.source)`
- L29, `_apply` (regla/valor): `if item.breading_explosion_radius > 0.0:`
- L34, `_apply` (literal adicional (revisión)): `config.explosion_visual_duration = 0.16`
- L35, `_apply` (texto): `var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()`
- L39, `_apply` (regla/valor): `if target.health_component.current_health > 0.0 and not target.is_queued_for_deletion():`
- L40, `_apply` (regla/valor): `if item.breading_slow_strength > 0.0:`
- L42, `_apply` (literal adicional (revisión)): `target.status_controller.add_slow(stats.effective_slow(1.0 - item.breading_slow_strength), item.breading_slow_duration * stats.get_crowd_control_multiplier())`
- L45, `_apply` (texto): `load("res://effects/status_controller.gd").apply_effect(target, effect, template)`

## effects/cayenne_trail_visual.gd

125 líneas; 0 anotaciones export; 0 uniforms; 49 candidatos.

### Candidatos / evidencia

- L9, `declaración` (regla/valor): `var duration := 3.0`
- L10, `declaración` (regla/valor): `var coverage_entries: Array[Dictionary] = []`
- L11, `declaración` (regla/valor): `var coverage_radius := 1.0`
- L19, `configure` (texto): `if not fire_settings: fire_settings = load("res://resources/statuses/fire_visual_default.tres")`
- L23, `configure` (literal adicional (revisión)): `floor_surface.z_index = 0`
- L24, `configure` (regla/valor): `var extent := Vector2(radius*2.0,radius*settings.area_y_ratio*2.0)`
- L25, `configure` (visual): `floor_surface.position = Vector2(-extent.x*0.5,-extent.y*0.8)`
- L26, `configure` (visual): `floor_surface.size = extent`
- L28, `configure` (texto): `ground_material.shader = preload("res://shaders/burning_unit.gdshader")`
- L29, `configure` (texto): `ground_material.set_shader_parameter("heat_color",settings.color)`
- L30, `configure` (texto): `ground_material.set_shader_parameter("variation",float(get_instance_id()%997)*0.13)`
- L32, `configure` (visual): `ground_material.set_shader_parameter(property,fire_settings.get(property))`
- L36, `configure` (texto): `if not texture: texture = load("res://assets/sprites/Effects/small_fire.png")`
- L38, `configure` (visual): `quad.size = Vector2.ONE`
- L39, `configure` (literal adicional (revisión)): `quad.center_offset = Vector3(0,-0.5,0)`
- L46, `configure` (regla/valor): `var direction := Vector2.from_angle(rng.randf()*TAU)`
- L47, `configure` (literal adicional (revisión)): `var point := direction*sqrt(rng.randf())*radius*0.8*Vector2(1,settings.area_y_ratio)`
- L48, `configure` (regla/valor): `var height: float = radius*settings.trail_flame_height*rng.randf_range(0.65,1.25)`
- L49, `configure` (literal adicional (revisión)): `flames.multimesh.set_instance_transform_2d(i,Transform2D(0.0,Vector2(height*texture.get_width()/texture.get_height(),height),0.0,point))`
- L51, `configure` (visual): `flames.multimesh.set_instance_custom_data(i,Color(rng.randf()*TAU,rng.randf_range(0.65,1.6),rng.randf_range(fire_settings.flip_interval_min,maxf(fire_settings.flip_interval_min,fire_settings.flip_interval_max)),0))`
- L52, `configure` (literal adicional (revisión)): `background = _batch(quad,1)`
- L54, `configure` (texto): `background_material.set_shader_parameter("size_pulse",fire_settings.size_pulse*0.5)`
- L56, `configure` (literal adicional (revisión)): `background.multimesh.set_instance_transform_2d(0,Transform2D(0.0,Vector2(radius*1.8,radius*1.1),0.0,Vector2.ZERO))`
- L57, `configure` (literal adicional (revisión)): `background.multimesh.set_instance_color(0,Color.WHITE)`
- L58, `configure` (literal adicional (revisión)): `background.multimesh.set_instance_custom_data(0,Color(rng.randf()*TAU,0.75,1.1,0))`
- L59, `configure` (literal adicional (revisión)): `move_child(background,1)`
- L60, `configure` (literal adicional (revisión)): `update_visual(0.0)`
- L71, `_batch` (literal adicional (revisión)): `batch.z_index = 0`
- L77, `_material` (texto): `shader_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")`
- L78, `_material` (texto): `shader_material.set_shader_parameter("flame_texture",texture)`
- L79, `_material` (texto): `shader_material.set_shader_parameter("opacity",opacity)`
- L81, `_material` (visual): `shader_material.set_shader_parameter(property,fire_settings.get(property))`
- L86, `update_visual` (literal adicional (revisión)): `var fade := minf(clampf(elapsed/maxf(0.01,settings.trail_fade_in),0.0,1.0),clampf((duration-elapsed)/maxf(0.01,settings.trail_fade_out),0.0,1.0))`
- L88, `update_visual` (texto): `shader_material.set_shader_parameter("elapsed",elapsed)`
- L89, `update_visual` (texto): `shader_material.set_shader_parameter("fade",fade)`
- L93, `set_coverage` (texto): `ground_material.set_shader_parameter("coverage_enabled", true)`
- L96, `_coverage_at` (regla/valor): `var density := 0.0`
- L100, `_coverage_at` (regla/valor): `var spatial := 1.0 - smoothstep(entry.radius * 0.82, entry.radius, offset.length())`
- L101, `_coverage_at` (literal adicional (revisión)): `var temporal := clampf((entry.lifetime - elapsed) / maxf(0.01, settings.trail_fade_out), 0.0, 1.0)`
- L109, `_update_coverage` (literal adicional (revisión)): `extents.resize(6)`
- L110, `_update_coverage` (literal adicional (revisión)): `weights.resize(6)`
- L111, `_update_coverage` (literal adicional (revisión)): `for index in mini(6, coverage_entries.size()):`
- L114, `_update_coverage` (literal adicional (revisión)): `weights[index] = clampf((entry.lifetime - elapsed) / maxf(0.01, settings.trail_fade_out), 0.0, 1.0)`
- L115, `_update_coverage` (texto): `ground_material.set_shader_parameter("coverage_count", mini(6, coverage_entries.size()))`
- L116, `_update_coverage` (texto): `ground_material.set_shader_parameter("coverage_extents", extents)`
- L117, `_update_coverage` (texto): `ground_material.set_shader_parameter("coverage_weights", weights)`
- L121, `_update_coverage` (literal adicional (revisión)): `flames.multimesh.set_instance_color(index, Color(1, 1, 1, minf(density, 1.0) * (1.0 + maxf(0.0, density - 1.0) * 0.14)))`
- L122, `_update_coverage` (regla/valor): `var active_radius := 0.0`
- L125, `_update_coverage` (literal adicional (revisión)): `background.multimesh.set_instance_transform_2d(0, Transform2D(0.0, Vector2(active_radius * 1.8, active_radius * 1.1), 0.0, Vector2.ZERO))`

## effects/electric_bolt_batch.gd

84 líneas; 0 anotaciones export; 0 uniforms; 38 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const CAPACITY := 1024`
- L4, `declaración` (regla/valor): `var ray_count := 7`
- L5, `declaración` (regla/valor): `var segment_count := 3`
- L6, `declaración` (regla/valor): `var count := 0`
- L7, `declaración` (regla/valor): `var submitted_frame := -1`
- L12, `configure` (literal adicional (revisión)): `capacity = maxi(1,instance_capacity)`
- L13, `configure` (literal adicional (revisión)): `ray_count = maxi(1,rays)`
- L14, `configure` (regla/valor): `segment_count = 4 if burst else 3`
- L15, `configure` (literal adicional (revisión)): `process_priority = 1001`
- L22, `configure` (literal adicional (revisión)): `for point in [Vector3(0,-0.5,0),Vector3(1,-0.5,0),Vector3(1,0.5,0),Vector3(0,0.5,0)]:`
- L25, `configure` (literal adicional (revisión)): `indices.append_array(PackedInt32Array([first,first+1,first+2,first,first+2,first+3]))`
- L26, `configure` (regla/valor): `var arrays := []`
- L39, `configure` (literal adicional (revisión)): `multimesh.visible_instance_count = 0`
- L40, `configure` (literal adicional (revisión)): `multimesh.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))`
- L41, `configure` (literal adicional (revisión)): `buffer.resize(capacity*16)`
- L43, `configure` (texto): `shader_material.shader = preload("res://shaders/electric_bolts.gdshader")`
- L44, `configure` (texto): `shader_material.set_shader_parameter("ray_count",float(ray_count))`
- L45, `configure` (texto): `shader_material.set_shader_parameter("burst_mode",burst)`
- L52, `submit_data` (literal adicional (revisión)): `count = 0`
- L56, `submit_data` (literal adicional (revisión)): `var offset := count*16`
- L58, `submit_data` (literal adicional (revisión)): `buffer[offset+1] = world_transform.y.x`
- L59, `submit_data` (literal adicional (revisión)): `buffer[offset+3] = world_transform.origin.x`
- L60, `submit_data` (literal adicional (revisión)): `buffer[offset+4] = world_transform.x.y`
- L61, `submit_data` (literal adicional (revisión)): `buffer[offset+5] = world_transform.y.y`
- L62, `submit_data` (literal adicional (revisión)): `buffer[offset+7] = world_transform.origin.y`
- L63, `submit_data` (literal adicional (revisión)): `buffer[offset+8] = tint.r`
- L64, `submit_data` (literal adicional (revisión)): `buffer[offset+9] = tint.g`
- L65, `submit_data` (literal adicional (revisión)): `buffer[offset+10] = tint.b`
- L66, `submit_data` (literal adicional (revisión)): `buffer[offset+11] = tint.a`
- L67, `submit_data` (literal adicional (revisión)): `buffer[offset+12] = data.r`
- L68, `submit_data` (literal adicional (revisión)): `buffer[offset+13] = data.g`
- L69, `submit_data` (literal adicional (revisión)): `buffer[offset+14] = data.b`
- L70, `submit_data` (literal adicional (revisión)): `buffer[offset+15] = data.a`
- L71, `submit_data` (regla/valor): `count += 1`
- L79, `_process` (literal adicional (revisión)): `multimesh.visible_instance_count = 0`
- L82, `clear` (literal adicional (revisión)): `count = 0`
- L83, `clear` (literal adicional (revisión)): `submitted_frame = -1`
- L84, `clear` (literal adicional (revisión)): `multimesh.visible_instance_count = 0`

## effects/electric_impact.gd

50 líneas; 0 anotaciones export; 0 uniforms; 18 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var duration := 0.38`
- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L5, `declaración` (regla/valor): `var radius := 40.0`
- L6, `declaración` (regla/valor): `var ray_count := 7`
- L7, `declaración` (visual): `var tint := Color("80dfff")`
- L8, `declaración` (regla/valor): `var glow := 1.0`
- L9, `declaración` (regla/valor): `var endpoints: Array[Vector2] = []`
- L14, `configure` (literal adicional (revisión)): `radius = maxf(28.0, effect.chain_radius) * Global.GAME_ENTITY_SCALE * effect.electric_visual_scale`
- L24, `_ready` (literal adicional (revisión)): `z_index = 0`
- L34, `_bolt` (literal adicional (revisión)): `draw_polyline(points,Color(tint,alpha*0.08*glow),12.0,true)`
- L35, `_bolt` (literal adicional (revisión)): `draw_polyline(points,Color(tint,alpha*0.3*glow),5.0,true)`
- L36, `_bolt` (literal adicional (revisión)): `draw_polyline(points,Color(tint.lightened(0.65),alpha),1.5,true)`
- L39, `_submit_rays` (literal adicional (revisión)): `var progress := clampf(elapsed / duration, 0.0, 1.0)`
- L44, `_draw` (literal adicional (revisión)): `var progress := clampf(elapsed / duration, 0.0, 1.0)`
- L45, `_draw` (literal adicional (revisión)): `var alpha := (1.0 - progress) * (1.0 - progress)`
- L46, `_draw` (literal adicional (revisión)): `var seed_frame := floorf(elapsed * 35.0)`
- L49, `_draw` (literal adicional (revisión)): `var wobble := sin(seed_frame * 3.7) * 7.0`
- L50, `_draw` (literal adicional (revisión)): `_bolt(PackedVector2Array([Vector2.ZERO, endpoint * 0.25 + normal * wobble, endpoint * 0.5 - normal * wobble, endpoint * 0.75 + normal * wobble, endpoint]), alpha)`

## effects/enemy_hit_feedback.gd

121 líneas; 0 anotaciones export; 0 uniforms; 61 candidatos.

Hallazgos: FX-07.

### Candidatos / evidencia

- L4, `declaración` (constante): `const MAX_PARTICLES := 128`
- L5, `declaración` (constante): `const EMISSION_INTERVAL := 0.08`
- L6, `declaración` (constante): `const CREAM := Color("fff7e6")`
- L7, `declaración` (constante): `const SHELL := Color("ead6b5")`
- L8, `declaración` (constante): `const OUTLINE := Color("695039")`
- L10, `declaración` (regla/valor): `var _particles: Array[Dictionary] = []`
- L11, `declaración` (regla/valor): `var _enemy_cooldowns: Dictionary = {}`
- L12, `declaración` (regla/valor): `var _time := 0.0`
- L13, `declaración` (regla/valor): `var active_count := 0`
- L19, `_ready` (literal adicional (revisión)): `z_index = 8`
- L21, `_ready` (visual): `quad.size = Vector2(2,2)`
- L24, `_ready` (regla/valor): `var arrays := []`
- L26, `_ready` (literal adicional (revisión)): `arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(-1,-0.5,0),Vector3(0.3,-0.9,0),Vector3(1,0.3,0),Vector3(-0.3,0.9,0)])`
- L27, `_ready` (literal adicional (revisión)): `arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0,1,2,0,2,3])`
- L31, `_ready` (literal adicional (revisión)): `_particles.append({"life": 0.0, "duration": 0.0, "position": Vector2.ZERO,`
- L32, `_ready` (literal adicional (revisión)): `"velocity": Vector2.ZERO, "size": 0.0, "angle": 0.0, "spin": 0.0, "shell": false})`
- L36, `emit_hit` (regla/valor): `if _time < float(_enemy_cooldowns.get(enemy_id, -1.0)): return`
- L38, `emit_hit` (regla/valor): `var drops := 4 if critical else randi_range(2, 3)`
- L39, `emit_hit` (regla/valor): `var total := drops + (2 if critical else 1)`
- L40, `emit_hit` (regla/valor): `var emitted := 0`
- L42, `emit_hit` (regla/valor): `if particle.life > 0.0: continue`
- L44, `emit_hit` (regla/valor): `particle.duration = randf_range(0.30, 0.40)`
- L46, `emit_hit` (visual): `particle.position = at + Vector2.from_angle(randf_range(-PI, PI)) * randf_range(4.0, 12.0)`
- L47, `emit_hit` (regla/valor): `particle.velocity = direction.rotated(randf_range(-1.1, 1.1)) * randf_range(100.0, 190.0)`
- L48, `emit_hit` (visual): `particle.size = randf_range(4.5, 7.5) * (1.25 if critical else 1.0)`
- L49, `emit_hit` (regla/valor): `particle.angle = randf_range(-PI, PI)`
- L50, `emit_hit` (regla/valor): `particle.spin = randf_range(-12.0, 12.0)`
- L52, `emit_hit` (regla/valor): `active_count += 1`
- L53, `emit_hit` (regla/valor): `emitted += 1`
- L55, `emit_hit` (literal adicional (revisión)): `set_process(active_count > 0)`
- L62, `_process` (regla/valor): `if particle.life <= 0.0: continue`
- L63, `_process` (literal adicional (revisión)): `particle.life = maxf(0.0, particle.life - delta)`
- L64, `_process` (regla/valor): `if particle.life == 0.0:`
- L65, `_process` (literal adicional (revisión)): `active_count -= 1`
- L68, `_process` (literal adicional (revisión)): `particle.velocity *= exp(-7.0 * delta)`
- L71, `_process` (literal adicional (revisión)): `set_process(active_count > 0)`
- L78, `_make_batch` (literal adicional (revisión)): `instances.instance_count = MAX_PARTICLES*2`
- L79, `_make_batch` (literal adicional (revisión)): `instances.visible_instance_count = 0`
- L80, `_make_batch` (literal adicional (revisión)): `instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))`
- L85, `_make_batch` (texto): `particle_material.shader = preload("res://shaders/mayonnaise_droplet.gdshader")`
- L91, `_update_instances` (regla/valor): `var cream_count := 0`
- L92, `_update_instances` (regla/valor): `var shell_count := 0`
- L94, `_update_instances` (regla/valor): `if particle.life <= 0.0: continue`
- L95, `_update_instances` (literal adicional (revisión)): `var alpha := minf(1.0, particle.life / particle.duration * 2.0)`
- L96, `_update_instances` (literal adicional (revisión)): `var radius: float = particle.size * (0.65 + 0.35 * particle.life / particle.duration)`
- L98, `_update_instances` (literal adicional (revisión)): `var particle_transform := Transform2D(particle.angle,Vector2.ONE*radius,0.0,particle.position)`
- L99, `_update_instances` (literal adicional (revisión)): `var index := shell_count*2`
- L102, `_update_instances` (literal adicional (revisión)): `shell_instances.set_instance_transform_2d(index+1,Transform2D(particle_transform.x*0.84,particle_transform.y*0.84,particle_transform.origin))`
- L103, `_update_instances` (literal adicional (revisión)): `shell_instances.set_instance_color(index+1,Color(SHELL,alpha))`
- L104, `_update_instances` (regla/valor): `shell_count += 1`
- L106, `_update_instances` (literal adicional (revisión)): `var index := cream_count*2`
- L107, `_update_instances` (literal adicional (revisión)): `cream_instances.set_instance_transform_2d(index,Transform2D(0,Vector2.ONE*radius,0.0,particle.position))`
- L109, `_update_instances` (literal adicional (revisión)): `cream_instances.set_instance_transform_2d(index+1,Transform2D(0,Vector2.ONE*maxf(0.5,radius-1.0),0.0,particle.position))`
- L110, `_update_instances` (literal adicional (revisión)): `cream_instances.set_instance_color(index+1,Color(CREAM,alpha))`
- L111, `_update_instances` (regla/valor): `cream_count += 1`
- L112, `_update_instances` (literal adicional (revisión)): `cream_instances.visible_instance_count = cream_count*2`
- L113, `_update_instances` (literal adicional (revisión)): `shell_instances.visible_instance_count = shell_count*2`
- L116, `clear` (literal adicional (revisión)): `for particle in _particles: particle.life = 0.0`
- L118, `clear` (literal adicional (revisión)): `active_count = 0`
- L119, `clear` (literal adicional (revisión)): `cream_instances.visible_instance_count = 0`
- L120, `clear` (literal adicional (revisión)): `shell_instances.visible_instance_count = 0`

## effects/fire_column_visual.gd

232 líneas; 0 anotaciones export; 0 uniforms; 109 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var radius := 1.0`
- L5, `declaración` (regla/valor): `var duration := 1.0`
- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L7, `declaración` (regla/valor): `var column_height := 0.0`
- L19, `declaración` (regla/valor): `var contact_spark_seeds: Array[Vector4] = []`
- L24, `declaración` (regla/valor): `var ember_seeds: Array[Vector4] = []`
- L32, `configure` (regla/valor): `var extent := Vector2(radius, radius*settings.area_y_ratio)`
- L33, `configure` (visual): `surface.position = -extent`
- L34, `configure` (visual): `surface.size = extent*2.0`
- L36, `configure` (literal adicional (revisión)): `surface.z_index = -1`
- L38, `configure` (texto): `base_material.shader = preload("res://shaders/fire_column_base.gdshader")`
- L39, `configure` (texto): `base_material.set_shader_parameter("flame_color", settings.color)`
- L40, `configure` (texto): `base_material.set_shader_parameter("core_color", settings.column_core_color)`
- L41, `configure` (texto): `base_material.set_shader_parameter("opacity", settings.opacity)`
- L48, `configure` (literal adicional (revisión)): `heat_surface.z_index = -2`
- L50, `configure` (texto): `heat_material.shader = preload("res://shaders/fire_column_heat.gdshader")`
- L51, `configure` (texto): `heat_material.set_shader_parameter("strength_pixels", settings.column_heat_distortion_pixels)`
- L52, `configure` (texto): `heat_material.set_shader_parameter("opacity", settings.column_heat_opacity)`
- L57, `configure` (texto): `if not fill_sprite.texture: fill_sprite.texture = load("res://assets/sprites/Effects/reaper_fire_column_fill.png")`
- L59, `configure` (literal adicional (revisión)): `fill_sprite.z_index = 0`
- L62, `configure` (texto): `fill_material.shader = preload("res://shaders/fire_column_fill.gdshader")`
- L63, `configure` (texto): `fill_material.set_shader_parameter("opacity", settings.column_fill_opacity)`
- L64, `configure` (texto): `fill_material.set_shader_parameter("distortion", settings.column_distortion)`
- L65, `configure` (texto): `fill_material.set_shader_parameter("flow_speed", settings.column_flow_speed)`
- L68, `configure` (literal adicional (revisión)): `rings = _batch(0)`
- L70, `configure` (texto): `ring_material.shader = preload("res://shaders/fire_column_ring.gdshader")`
- L72, `configure` (texto): `if not ring_texture: ring_texture = load("res://assets/sprites/Effects/reaper_fire_ring_v2.png")`
- L73, `configure` (texto): `ring_material.set_shader_parameter("ring_texture", ring_texture)`
- L74, `configure` (texto): `ring_material.set_shader_parameter("opacity", settings.column_ring_opacity)`
- L75, `configure` (texto): `ring_material.set_shader_parameter("center_opacity", settings.column_ring_center_opacity)`
- L76, `configure` (texto): `ring_material.set_shader_parameter("distortion", settings.column_distortion)`
- L77, `configure` (texto): `ring_material.set_shader_parameter("flow_speed", settings.column_flow_speed)`
- L81, `configure` (texto): `flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")`
- L82, `configure` (texto): `flame_material.set_shader_parameter("flame_texture", load("res://assets/sprites/Effects/small_fire.png"))`
- L83, `configure` (texto): `flame_material.set_shader_parameter("opacity", settings.opacity)`
- L84, `configure` (texto): `flame_material.set_shader_parameter("distortion_strength", settings.column_distortion)`
- L87, `configure` (literal adicional (revisión)): `var angle := lerpf(0.06, PI-0.06, float(index)/maxi(1, settings.column_base_flames-1))`
- L88, `configure` (regla/valor): `var point := Vector2(cos(angle), sin(angle)*settings.area_y_ratio)*radius*0.86`
- L89, `configure` (regla/valor): `var height := radius*randf_range(0.24,0.42)`
- L90, `configure` (literal adicional (revisión)): `base_flames.multimesh.set_instance_transform_2d(index, Transform2D(0.0, Vector2(height*0.65,height), 0.0, point+Vector2(0,-height*0.5)))`
- L91, `configure` (visual): `base_flames.multimesh.set_instance_custom_data(index, Color(randf()*TAU, randf_range(0.7,1.4), randf_range(0.5,1.4),0))`
- L94, `configure` (texto): `if not contact_sprite.texture: contact_sprite.texture = load("res://assets/sprites/Effects/reaper_fire_ring.png")`
- L97, `configure` (literal adicional (revisión)): `contact_sprite.z_index = 0`
- L99, `configure` (texto): `contact_material.shader = preload("res://shaders/fire_column_contact.gdshader")`
- L100, `configure` (texto): `contact_material.set_shader_parameter("opacity", settings.column_contact_opacity)`
- L101, `configure` (texto): `contact_material.set_shader_parameter("front_start", settings.column_contact_front_start)`
- L102, `configure` (texto): `contact_material.set_shader_parameter("distortion", settings.column_distortion)`
- L114, `configure` (texto): `spark_material.shader = preload("res://shaders/fire_column_spark.gdshader")`
- L121, `configure` (literal adicional (revisión)): `update_visual(0.0)`
- L130, `_batch` (visual): `quad.size = Vector2.ONE`
- L135, `_batch` (literal adicional (revisión)): `result.z_index = 0`
- L147, `update_visual` (visual): `fill_sprite.scale = Vector2(radius*settings.column_fill_width/fill_sprite.texture.get_width(), fill_height/fill_sprite.texture.get_height())`
- L148, `update_visual` (visual): `fill_sprite.position = Vector2(0, (radius*settings.area_y_ratio-column_height)*0.5)`
- L149, `update_visual` (texto): `fill_material.set_shader_parameter("base_roundness", radius*settings.area_y_ratio/fill_height)`
- L150, `update_visual` (texto): `fill_material.set_shader_parameter("world_height", fill_height)`
- L151, `update_visual` (texto): `fill_material.set_shader_parameter("base_depth", radius*settings.area_y_ratio)`
- L152, `update_visual` (texto): `ring_material.set_shader_parameter("body_texture", fill_sprite.texture)`
- L153, `update_visual` (texto): `ring_material.set_shader_parameter("body_height", fill_height)`
- L154, `update_visual` (texto): `ring_material.set_shader_parameter("body_depth", radius*settings.area_y_ratio)`
- L155, `update_visual` (texto): `ring_material.set_shader_parameter("body_width", radius*settings.column_fill_width)`
- L157, `update_visual` (texto): `ring_material.set_shader_parameter("column_screen_origin", pixel_transform.origin)`
- L158, `update_visual` (texto): `ring_material.set_shader_parameter("column_screen_scale", Vector2(pixel_transform.x.x,pixel_transform.y.y))`
- L160, `update_visual` (texto): `shader_material.set_shader_parameter("flare_height", settings.column_flare_height*Global.GAME_ENTITY_SCALE)`
- L161, `update_visual` (texto): `shader_material.set_shader_parameter("top_width_multiplier", settings.column_top_width_multiplier)`
- L162, `update_visual` (literal adicional (revisión)): `var contact_width := radius*2.25`
- L164, `update_visual` (visual): `contact_sprite.scale = Vector2.ONE*contact_width/contact_sprite.texture.get_width()`
- L165, `update_visual` (visual): `contact_sprite.position = Vector2(0, radius*settings.area_y_ratio-contact_height*0.5)`
- L166, `update_visual` (visual): `contact_glow.scale = contact_sprite.scale*settings.column_contact_glow_scale`
- L167, `update_visual` (visual): `contact_glow.position = contact_sprite.position`
- L168, `update_visual` (literal adicional (revisión)): `var heat_width := radius*(2.0+settings.column_heat_side_reach*2.0)`
- L169, `update_visual` (visual): `heat_surface.position = Vector2(-heat_width*0.5,-column_height)`
- L170, `update_visual` (visual): `heat_surface.size = Vector2(heat_width,fill_height+radius*0.2)`
- L171, `update_visual` (texto): `heat_material.set_shader_parameter("world_height",heat_surface.size.y)`
- L172, `update_visual` (texto): `heat_material.set_shader_parameter("base_depth", radius*(settings.area_y_ratio+0.2))`
- L173, `update_visual` (literal adicional (revisión)): `var spacing := maxf(8.0, settings.column_ring_spacing*Global.GAME_ENTITY_SCALE)`
- L174, `update_visual` (literal adicional (revisión)): `var count := maxi(2, ceili(column_height/spacing)+2)`
- L177, `update_visual` (literal adicional (revisión)): `var fade := minf(clampf(elapsed/settings.column_fade_in,0,1), clampf((duration-elapsed)/settings.column_fade_out,0,1))`
- L179, `update_visual` (texto): `shader_material.set_shader_parameter("elapsed", elapsed)`
- L180, `update_visual` (texto): `shader_material.set_shader_parameter("fade", fade)`
- L182, `update_visual` (literal adicional (revisión)): `var height := (float(index)+sin(float(index)*2.399963)*0.12+fposmod(elapsed*settings.column_flow_speed,1.0))*spacing`
- L183, `update_visual` (literal adicional (revisión)): `var phase := float(index)*2.399963`
- L187, `update_visual` (visual): `var sprite_size := Vector2(width*1.85, width*1.85*ring_texture.get_height()/ring_texture.get_width()*settings.column_ring_height_scale*(1.0+0.12*sin(phase)))`
- L188, `update_visual` (literal adicional (revisión)): `var center_height := height-depth+sprite_size.y*0.5`
- L191, `update_visual` (literal adicional (revisión)): `var drift := (sin(center_uv_y*19.0-time_value*1.8)*0.65+sin(center_uv_y*33.0+time_value*1.2)*0.35)*settings.column_distortion`
- L193, `update_visual` (literal adicional (revisión)): `var center_x := (0.015-drift)*radius*settings.column_fill_width*center_scale`
- L194, `update_visual` (regla/valor): `var anchor := Vector2(center_x, -center_height)`
- L195, `update_visual` (literal adicional (revisión)): `rings.multimesh.set_instance_transform_2d(index, Transform2D(0.0, sprite_size,0.0,anchor))`
- L201, `update_visual` (literal adicional (revisión)): `var age := fposmod(elapsed*(0.35+seed.z*0.3)+seed.x,1.0)`
- L203, `update_visual` (literal adicional (revisión)): `var angle := seed.y*TAU+elapsed*(1.2+seed.w)`
- L204, `update_visual` (regla/valor): `var point := Vector2(cos(angle)*radius*_width_at_height(height)*(0.8+seed.z*0.5), -height+sin(angle)*radius*settings.area_y_ratio)`
- L205, `update_visual` (literal adicional (revisión)): `var size := settings.column_ember_size*Global.GAME_ENTITY_SCALE*(0.5+seed.w)`
- L206, `update_visual` (literal adicional (revisión)): `embers.multimesh.set_instance_transform_2d(index, Transform2D(angle, Vector2(size,size*1.8),0.0,point))`
- L208, `update_visual` (literal adicional (revisión)): `tint.a = sin(age*PI)*fade*0.8`
- L214, `_update_contact_sparks` (literal adicional (revisión)): `var lifetime := maxf(0.1, settings.column_contact_spark_lifetime*(0.65+seed.w*0.7))`
- L215, `_update_contact_sparks` (literal adicional (revisión)): `var age := fposmod(elapsed/lifetime+seed.x,1.0)`
- L216, `_update_contact_sparks` (literal adicional (revisión)): `var angle := lerpf(0.05, PI-0.05, seed.y)`
- L217, `_update_contact_sparks` (regla/valor): `var direction := Vector2(cos(angle), sin(angle)*settings.area_y_ratio)`
- L218, `_update_contact_sparks` (literal adicional (revisión)): `var travel := radius*settings.column_contact_spark_travel*(0.35+seed.z*0.65)`
- L219, `_update_contact_sparks` (literal adicional (revisión)): `var ground := direction*(radius*0.88+travel*age)`
- L220, `_update_contact_sparks` (literal adicional (revisión)): `var leap := radius*settings.column_contact_spark_height*(0.25+seed.w*0.75)`
- L221, `_update_contact_sparks` (literal adicional (revisión)): `var point := ground-Vector2(0,4.0*leap*age*(1.0-age))`
- L222, `_update_contact_sparks` (literal adicional (revisión)): `var velocity := direction*travel-Vector2(0,4.0*leap*(1.0-2.0*age))`
- L223, `_update_contact_sparks` (literal adicional (revisión)): `var size := settings.column_contact_spark_size*Global.GAME_ENTITY_SCALE*(0.55+seed.z*0.9)*(1.0-age*0.5)`
- L224, `_update_contact_sparks` (regla/valor): `var streak := 1.0+seed.w*2.6`
- L225, `_update_contact_sparks` (literal adicional (revisión)): `contact_sparks.multimesh.set_instance_transform_2d(index,Transform2D(velocity.angle(),Vector2(size*streak,size),0.0,point))`
- L226, `_update_contact_sparks` (literal adicional (revisión)): `var tint := settings.column_core_color.lerp(settings.color,age*0.75)`
- L227, `_update_contact_sparks` (literal adicional (revisión)): `tint.a = smoothstep(0.0,0.07,age)*(1.0-smoothstep(0.5,1.0,age))*settings.column_contact_spark_opacity*fade`
- L231, `_width_at_height` (literal adicional (revisión)): `var progress := pow(clampf(height/maxf(1.0,settings.column_flare_height*Global.GAME_ENTITY_SCALE),0.0,1.0),0.8)`
- L232, `_width_at_height` (regla/valor): `return lerpf(1.0,settings.column_top_width_multiplier,progress)`

## effects/fire_spread.gd

40 líneas; 0 anotaciones export; 0 uniforms; 6 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `static var _pending: Array[Dictionary] = []`
- L9, `on_burning_started` (regla/valor): `if not is_instance_valid(player.passive_items) or player.passive_items.fire_spread_chance <= 0.0: return`
- L13, `on_burning_started` (regla/valor): `var index := 0`
- L16, `on_burning_started` (regla/valor): `index += 1`
- L31, `_try_spread` (regla/valor): `if not candidate.targetable or candidate.is_retiring or candidate.health_component.current_health <= 0.0: continue`
- L40, `_try_spread` (texto): `load("res://effects/fire_status.gd").apply(nearest, entry.key, template, entry.settings, entry.scaled)`

## effects/fire_status.gd

129 líneas; 0 anotaciones export; 0 uniforms; 36 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var remaining := 0.0`
- L5, `declaración` (regla/valor): `var tick_left := 0.0`
- L6, `declaración` (regla/valor): `var interval := 0.5`
- L7, `declaración` (regla/valor): `var elapsed := 0.0`
- L9, `declaración` (regla/valor): `var contributions: Dictionary = {}`
- L12, `apply` (regla/valor): `if enemy.status_immune or settings.duration <= 0.0: return`
- L16, `apply` (regla/valor): `if duration <= 0.0: return`
- L22, `apply` (texto): `burn = load("res://effects/fire_status.gd").new()`
- L26, `apply` (literal adicional (revisión)): `burn.hit.collision_layer = 0`
- L27, `apply` (literal adicional (revisión)): `burn.hit.collision_mask = 0`
- L36, `apply` (visual): `var tick_damage: float = source_stats.get_burning_damage() if player_fire else maxf(0.0, source_stats.get_effect_damage(settings.damage, settings.damage_scaling) * source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else settings.damage)`
- L39, `apply` (literal adicional (revisión)): `tick_damage = maxf(0.1, source_stats.get_effect_damage(settings.damage, settings.damage_scaling)) * ItemWeapon.status_damage_multiplier(template.weapon_damage_record, source_stats)`
- L42, `apply` (literal adicional (revisión)): `burn.hit.setup(tick_damage, false, 0.0, template.source)`
- L50, `apply` (literal adicional (revisión)): `burn.hit.critical_chance = 0.0`
- L51, `apply` (literal adicional (revisión)): `burn.hit.critical_multiplier = 1.0`
- L55, `apply` (visual): `var multiplier := source_stats.get_damage_percent_multiplier() if source_stats and not damage_scaled else 1.0`
- L60, `apply` (texto): `load("res://effects/fire_visual.gd").attach(enemy,burn,settings.fire_visuals,settings.color)`
- L61, `apply` (regla/valor): `if not was_burning and burn.remaining > 0.0:`
- L63, `apply` (texto): `load("res://effects/fire_spread.gd").on_burning_started(enemy, key, template, settings, damage_scaled)`
- L68, `_ready` (literal adicional (revisión)): `z_index = 3`
- L73, `_process` (regla/valor): `if not is_instance_valid(enemy) or (enemy is Enemy and enemy.is_retiring) or enemy.health_component.current_health <= 0.0:`
- L79, `_process` (literal adicional (revisión)): `var active_delta := minf(delta, maxf(0.0, remaining))`
- L83, `_process` (literal adicional (revisión)): `while tick_left <= 0.00001:`
- L85, `_process` (regla/valor): `if enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: break`
- L87, `_process` (regla/valor): `if remaining <= 0.0:`
- L93, `_refresh_contributions` (regla/valor): `var total := 0.0`
- L94, `_refresh_contributions` (literal adicional (revisión)): `remaining = 0.0`
- L95, `_refresh_contributions` (regla/valor): `var shares: Array[Dictionary] = []`
- L100, `_refresh_contributions` (literal adicional (revisión)): `for share in shares: share.weight /= maxf(0.00001, total)`
- L103, `_refresh_contributions` (literal adicional (revisión)): `hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}`
- L107, `_process_contributions` (literal adicional (revisión)): `while left > 0.000001 and not contributions.is_empty():`
- L108, `_process_contributions` (literal adicional (revisión)): `var step := minf(left, maxf(0.0, tick_left))`
- L109, `_process_contributions` (literal adicional (revisión)): `for entry in contributions.values(): step = minf(step, maxf(0.0, entry.remaining))`
- L115, `_process_contributions` (regla/valor): `if tick_left <= 0.00001:`
- L117, `_process_contributions` (regla/valor): `if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0: enemy.receive_hit(hit)`
- L119, `_process_contributions` (regla/valor): `if contributions[id].remaining <= 0.000001: contributions.erase(id)`

## effects/fire_visual.gd

149 líneas; 0 anotaciones export; 0 uniforms; 58 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var sources: Dictionary = {}`
- L8, `declaración` (regla/valor): `var elapsed := 0.0`
- L9, `declaración` (regla/valor): `var fade := 1.0`
- L14, `declaración` (regla/valor): `var layout_extent := Vector2.ZERO`
- L15, `declaración` (regla/valor): `var layout_count := -1`
- L20, `attach` (literal adicional (revisión)): `visual.name = "ExpiredFireVisual_%s" % visual.get_instance_id()`
- L23, `attach` (texto): `visual = load("res://effects/fire_visual.gd").new()`
- L24, `attach` (literal adicional (revisión)): `visual.name = "FireVisual"`
- L27, `attach` (texto): `visual.settings = config if config else load("res://resources/statuses/fire_visual_default.tres")`
- L29, `attach` (texto): `visual.fire_material.set_shader_parameter("heat_color",tint)`
- L31, `attach` (visual): `visual.fire_material.set_shader_parameter(property,visual.settings.get(property))`
- L33, `attach` (visual): `visual.flame_material.set_shader_parameter(property,visual.settings.get(property))`
- L34, `attach` (visual): `visual.background_material.set_shader_parameter(property,visual.settings.get(property))`
- L35, `attach` (texto): `visual.flame_material.set_shader_parameter("opacity",visual.settings.flame_opacity)`
- L36, `attach` (texto): `visual.background_material.set_shader_parameter("opacity",visual.settings.background_flame_opacity)`
- L37, `attach` (texto): `visual.background_material.set_shader_parameter("size_pulse",visual.settings.size_pulse*0.5)`
- L38, `attach` (literal adicional (revisión)): `visual.layout_count = -1`
- L45, `_ready` (literal adicional (revisión)): `z_index = 0`
- L49, `_ready` (texto): `fire_material.shader = preload("res://shaders/burning_unit.gdshader")`
- L50, `_ready` (texto): `fire_material.set_shader_parameter("variation",float(get_instance_id()%997)*0.13)`
- L59, `_ready` (visual): `quad.size = Vector2.ONE`
- L60, `_ready` (literal adicional (revisión)): `quad.center_offset = Vector3(0,-0.5,0)`
- L63, `_ready` (texto): `flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")`
- L66, `_ready` (literal adicional (revisión)): `flames.z_index = 0`
- L75, `_ready` (literal adicional (revisión)): `background_flame.multimesh.instance_count = 1`
- L80, `_ready` (literal adicional (revisión)): `background_flame.z_index = 0`
- L87, `_process` (regla/valor): `if not is_instance_valid(target) or target.is_queued_for_deletion() or target.health_component.current_health <= 0 or (target is Enemy and target.is_retiring):`
- L92, `_process` (regla/valor): `if not is_instance_valid(burn) or burn.is_queued_for_deletion() or burn.remaining <= 0:`
- L95, `_process` (literal adicional (revisión)): `fade = maxf(0.0,fade-delta/maxf(0.01,settings.fade_duration))`
- L96, `_process` (regla/valor): `if fade <= 0:`
- L100, `_process` (literal adicional (revisión)): `fade = minf(1.0,fade+delta*10.0)`
- L104, `_process` (regla/valor): `var extent: Vector2 = Vector2(maxf(12.0,sprite_extent.x*1.65),maxf(20.0,sprite_extent.y*1.7))*settings.coverage`
- L105, `_process` (literal adicional (revisión)): `global_rotation = 0.0`
- L108, `_process` (visual): `surface.position = Vector2(-extent.x*0.5,-extent.y*0.82)`
- L109, `_process` (visual): `surface.size = extent`
- L110, `_process` (texto): `fire_material.set_shader_parameter("elapsed",elapsed)`
- L111, `_process` (texto): `fire_material.set_shader_parameter("fade",fade)`
- L112, `_process` (visual): `flames.position = Vector2(rect.get_center().x,rect.end.y)`
- L113, `_process` (visual): `background_flame.position = flames.position`
- L116, `_process` (texto): `flame_material.set_shader_parameter("elapsed",elapsed)`
- L117, `_process` (texto): `flame_material.set_shader_parameter("fade",fade)`
- L118, `_process` (texto): `background_material.set_shader_parameter("elapsed",elapsed)`
- L119, `_process` (texto): `background_material.set_shader_parameter("fade",fade)`
- L125, `_build_flames` (texto): `if not texture: texture = load("res://assets/sprites/Effects/small_fire.png")`
- L126, `_build_flames` (texto): `flame_material.set_shader_parameter("flame_texture",texture)`
- L127, `_build_flames` (texto): `background_material.set_shader_parameter("flame_texture",texture)`
- L128, `_build_flames` (visual): `var background_size := Vector2(sprite_extent.x*settings.background_flame_width,sprite_extent.y*settings.background_flame_height)`
- L129, `_build_flames` (literal adicional (revisión)): `background_flame.multimesh.set_instance_transform_2d(0,Transform2D(0.0,background_size,0.0,Vector2.ZERO))`
- L130, `_build_flames` (literal adicional (revisión)): `background_flame.multimesh.set_instance_color(0,Color.WHITE)`
- L131, `_build_flames` (literal adicional (revisión)): `background_flame.multimesh.set_instance_custom_data(0,Color(1.7,0.75,1.1,0))`
- L138, `_build_flames` (regla/valor): `var anchor_height := rng.randf_range(-0.35,-0.02) if i < lower_count else rng.randf_range(-0.85,-0.5)`
- L139, `_build_flames` (regla/valor): `var anchor := Vector2(rng.randf_range(-0.42,0.42)*sprite_extent.x,anchor_height*sprite_extent.y)`
- L140, `_build_flames` (regla/valor): `var height: float = sprite_extent.y*settings.flame_sprite_height*rng.randf_range(0.65,1.25)`
- L141, `_build_flames` (visual): `var size := Vector2(height*texture.get_width()/texture.get_height(),height)`
- L142, `_build_flames` (literal adicional (revisión)): `flames.multimesh.set_instance_transform_2d(i,Transform2D(0.0,size,0.0,anchor))`
- L143, `_build_flames` (visual): `flames.multimesh.set_instance_color(i,Color(1,1,1,rng.randf_range(0.95,1.0)))`
- L144, `_build_flames` (regla/valor): `var flip_period := rng.randf_range(settings.flip_interval_min,maxf(settings.flip_interval_min,settings.flip_interval_max))`
- L145, `_build_flames` (visual): `flames.multimesh.set_instance_custom_data(i,Color(rng.randf()*TAU,rng.randf_range(0.65,1.6),flip_period,0))`

## effects/flash.gdshader

5 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L4, `shader` (shader interno): `COLOR = vec4(1.0, 1.0, 1.0, texture(TEXTURE, UV).a);`

## effects/ghost_cloud_visual.gd

82 líneas; 0 anotaciones export; 0 uniforms; 39 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var radius := 1.0`
- L5, `declaración` (regla/valor): `var duration := 5.0`
- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L10, `declaración` (regla/valor): `var seeds: Array[Vector4] = []`
- L11, `declaración` (regla/valor): `var puff_origins: Array[Vector2] = []`
- L19, `configure` (texto): `if not texture: texture = load("res://assets/sprites/Effects/ghost_pepper_cloud.png")`
- L22, `configure` (regla/valor): `var extent := Vector2(radius,radius*settings.area_y_ratio)`
- L23, `configure` (visual): `ground.position = -extent`
- L24, `configure` (visual): `ground.size = extent*2.0`
- L26, `configure` (literal adicional (revisión)): `ground.z_index = 0`
- L28, `configure` (texto): `ground_material.shader = preload("res://shaders/ghost_cloud_ground.gdshader")`
- L29, `configure` (texto): `ground_material.set_shader_parameter("tint",settings.color)`
- L38, `configure` (visual): `quad.size = Vector2.ONE`
- L42, `configure` (texto): `cloud_material.shader = preload("res://shaders/ghost_cloud.gdshader")`
- L43, `configure` (texto): `cloud_material.set_shader_parameter("cloud_texture",texture)`
- L44, `configure` (texto): `cloud_material.set_shader_parameter("opacity",settings.opacity)`
- L45, `configure` (texto): `cloud_material.set_shader_parameter("distortion",settings.cloud_distortion)`
- L46, `configure` (texto): `cloud_material.set_shader_parameter("billow_speed",settings.cloud_billow_speed)`
- L49, `configure` (literal adicional (revisión)): `puffs.z_index = 0`
- L52, `configure` (regla/valor): `var seed := Vector4(randf(),randf(),randf(),randf())`
- L55, `configure` (literal adicional (revisión)): `var angle := float(index)*2.399963+seed.z*1.6`
- L56, `configure` (literal adicional (revisión)): `var distance := sqrt((float(index)+seed.y)/maxi(1,settings.cloud_layer_count))*radius*0.72`
- L58, `configure` (literal adicional (revisión)): `puffs.multimesh.set_instance_custom_data(index,Color(seed.x*TAU,seed.w,0,0))`
- L59, `configure` (literal adicional (revisión)): `update_visual(0.0)`
- L63, `update_visual` (literal adicional (revisión)): `var fade := minf(clampf(elapsed/maxf(0.01,settings.cloud_fade_in),0,1),clampf((duration-elapsed)/maxf(0.01,settings.cloud_fade_out),0,1))`
- L64, `update_visual` (texto): `cloud_material.set_shader_parameter("elapsed",elapsed)`
- L65, `update_visual` (texto): `cloud_material.set_shader_parameter("fade",fade)`
- L66, `update_visual` (texto): `ground_material.set_shader_parameter("fade",fade)`
- L69, `update_visual` (literal adicional (revisión)): `var lifetime := maxf(0.3,settings.cloud_puff_lifetime*(0.7+seed.z*0.6))`
- L70, `update_visual` (literal adicional (revisión)): `var age := fposmod(elapsed*settings.cloud_billow_speed/lifetime+seed.x,1.0)`
- L71, `update_visual` (literal adicional (revisión)): `var phase := seed.x*TAU+elapsed*settings.cloud_billow_speed*(0.55+seed.w)`
- L72, `update_visual` (literal adicional (revisión)): `var life := smoothstep(0.0,0.18,age)*(1.0-smoothstep(0.65,1.0,age))`
- L74, `update_visual` (literal adicional (revisión)): `var width := radius*2.25*layer_scale*(0.85+age*0.25+sin(phase)*0.06)`
- L75, `update_visual` (literal adicional (revisión)): `var height := width*settings.area_y_ratio*(0.8+seed.w*0.35)`
- L77, `update_visual` (literal adicional (revisión)): `point += Vector2(sin(phase),cos(phase*0.73)*settings.area_y_ratio)*radius*settings.cloud_puff_drift`
- L78, `update_visual` (literal adicional (revisión)): `point.y -= radius*settings.cloud_visual_height+age*radius*0.06`
- L79, `update_visual` (regla/valor): `var stretch := Vector2(width,height)`
- L80, `update_visual` (literal adicional (revisión)): `puffs.multimesh.set_instance_transform_2d(index,Transform2D(sin(phase*0.4)*0.08,stretch,0.0,point))`
- L81, `update_visual` (visual): `var tint := Color(1.0,0.88+seed.z*0.12,0.88+seed.w*0.12,settings.cloud_puff_opacity*(0.65+seed.w*0.5)*life)`

## effects/golden_item.gdshader

17 líneas; 0 anotaciones export; 3 uniforms; 9 candidatos.

### Uniforms editables

- L3: `uniform float strength : hint_range(0.0, 1.0) = 0.55;`
- L4: `uniform bool perfect = false;`
- L5: `uniform bool overlay = false;`

### Candidatos / evidencia

- L8, `shader` (shader interno): `vec4 original = texture(TEXTURE, UV) * COLOR;`
- L9, `shader` (shader interno): `float band = pow(max(0.0, sin((UV.x + UV.y * 0.55) * 11.0 - TIME * 2.6)), 12.0);`
- L10, `shader` (shader interno): `float pulse = 0.14 + 0.07 * sin(TIME * 2.1);`
- L11, `shader` (shader interno): `vec3 gold = vec3(1.0, 0.72, 0.16);`
- L12, `shader` (shader interno): `float shimmer = strength * (pulse + band * 0.65);`
- L13, `shader` (shader interno): `float stars = pow(max(0.0, sin(UV.x * 39.0 + TIME * 1.3) * sin(UV.y * 31.0 - TIME * 1.7)), 30.0);`
- L14, `shader` (shader interno): `vec3 tint = mix(original.rgb, gold, shimmer);`
- L15, `shader` (shader interno): `if (perfect) tint += vec3(1.0, 0.88, 0.5) * stars * 0.8;`
- L16, `shader` (shader interno): `COLOR = vec4(tint, original.a * (overlay ? min(0.85, shimmer + stars * float(perfect)) : 1.0));`

## effects/golden_sparkles.gd

16 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var radius := 40.0`
- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L11, `_draw` (literal adicional (revisión)): `for index in 4:`
- L12, `_draw` (literal adicional (revisión)): `var phase := elapsed * 0.7 + index * TAU / 4.0`
- L13, `_draw` (regla/valor): `var point := Vector2(cos(phase), sin(phase) * 0.65) * radius`
- L14, `_draw` (regla/valor): `var length := 2.0 + 2.0 * pow(0.5 + 0.5 * sin(elapsed * 3.0 + index * 1.8), 3.0)`
- L15, `_draw` (literal adicional (revisión)): `var points := PackedVector2Array([point + Vector2(0, -length), point + Vector2(1, -1), point + Vector2(length, 0), point + Vector2(1, 1), point + Vector2(0, length), point + Vector2(-1, 1), point + Vector2(-length, 0), point + Vector2(-1, -1)])`
- L16, `_draw` (literal adicional (revisión)): `draw_colored_polygon(points, Color(1.0, 0.86, 0.4, 0.85))`

## effects/golden_visual.gd

36 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

### Candidatos / evidencia

- L5, `material_for` (texto): `effect.shader = load("res://effects/golden_item.gdshader")`
- L6, `material_for` (texto): `effect.set_shader_parameter("strength", clampf(0.2 + (item.golden_multiplier - 1.0) * 0.65, 0.2, 0.95))`
- L7, `material_for` (texto): `effect.set_shader_parameter("perfect", item.golden_perfect)`
- L8, `material_for` (texto): `effect.set_shader_parameter("overlay", overlay)`
- L17, `apply_weapon` (regla/valor): `if weapon.data.golden_multiplier <= 1.0: return`
- L19, `apply_weapon` (literal adicional (revisión)): `overlay.name = "GoldenOverlay"`
- L33, `apply_weapon` (texto): `var stars = load("res://effects/golden_sparkles.gd").new()`
- L34, `apply_weapon` (literal adicional (revisión)): `stars.name = "GoldenSparkles"`
- L35, `apply_weapon` (literal adicional (revisión)): `stars.radius = minf(sprite.get_rect().size.x, sprite.get_rect().size.y) * 0.6`

## effects/habanero_embers.gd

33 líneas; 0 anotaciones export; 0 uniforms; 15 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var radius := 0.0`
- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L5, `declaración` (regla/valor): `var sparks: Array[Vector4] = []`
- L9, `setup` (literal adicional (revisión)): `z_index = 0`
- L12, `setup` (regla/valor): `sparks.append(Vector4(randf()*TAU,randf_range(0.2,0.65),randf_range(0.7,1.25),randf_range(0.6,1.4)))`
- L16, `_process` (regla/valor): `if elapsed >= maxf(0.01,settings.ember_duration):`
- L22, `_draw` (literal adicional (revisión)): `var t := clampf(elapsed/maxf(0.01,settings.ember_duration),0,1)`
- L24, `_draw` (regla/valor): `var direction := Vector2.from_angle(spark.x)`
- L25, `_draw` (literal adicional (revisión)): `var distance := radius*(spark.y+settings.ember_travel*(1.0-pow(1.0-t,2.0))*spark.z)`
- L26, `_draw` (literal adicional (revisión)): `var point := direction*distance*Vector2(1,settings.area_y_ratio)`
- L27, `_draw` (literal adicional (revisión)): `point.y -= radius*0.12*sin(t*PI)*spark.w`
- L28, `_draw` (literal adicional (revisión)): `var size := settings.ember_size*Global.GAME_ENTITY_SCALE*spark.w*(1.0-t*0.7)`
- L29, `_draw` (literal adicional (revisión)): `var color := settings.color.lerp(settings.core_color,0.45*(1.0-t))`
- L30, `_draw` (literal adicional (revisión)): `color.a = settings.opacity*(1.0-t)*(1.0-t)`
- L32, `_draw` (literal adicional (revisión)): `draw_colored_polygon(PackedVector2Array([Vector2(-size*2.5,0),Vector2(0,-size*0.65),Vector2(size,0),Vector2(0,size*0.65)]),color)`

## effects/incognito_confetti.gd

41 líneas; 2 anotaciones export; 0 uniforms; 13 candidatos.

Hallazgos: FX-06.

### Ya expuesto en el editor

- L7: `@export var size_multiplier := 1.4`
- L8: `@export var animation_speed := 1.5`

### Candidatos / evidencia

- L3, `declaración` (constante): `const PALETTE := [Color("fffdf1"), Color("ead1aa"), Color("fff3d4"), Color("ffce32"), Color("f2a51b")]`
- L4, `declaración` (regla/valor): `var pieces: Array[Dictionary] = []`
- L5, `declaración` (regla/valor): `var elapsed := 0.0`
- L6, `declaración` (regla/valor): `var duration := 1.15`
- L9, `declaración` (regla/valor): `var origin := Vector2(0, -30)`
- L14, `_ready` (literal adicional (revisión)): `for index in 72:`
- L15, `_ready` (regla/valor): `var direction := Vector2.from_angle(TAU * float(index) / 72.0 + randf_range(-0.08, 0.08))`
- L16, `_ready` (texto): `pieces.append({"point": origin, "velocity": direction * randf_range(90, 260) + Vector2(0, -110), "angle": randf() * TAU, "spin": randf_range(-14, 14), "size": Vector2(randf_range(3, 7), randf_range(2, 5)), "phase": randf() * TAU, "color": PALETTE[index % PALETTE.size()]})`
- L28, `_process` (literal adicional (revisión)): `piece.velocity *= exp(-1.4 * delta)`
- L29, `_process` (regla/valor): `piece.velocity.y += 260.0 * delta`
- L34, `_draw` (literal adicional (revisión)): `var alpha := clampf((duration - elapsed) / 0.3, 0.0, 1.0)`
- L36, `_draw` (regla/valor): `var flutter := Vector2(0.35 + 0.65 * absf(cos(elapsed * 15.0 + piece.phase)), 1)`
- L40, `_draw` (literal adicional (revisión)): `draw_colored_polygon(PackedVector2Array([Vector2(-1, -0.7), Vector2(0.7, -1), Vector2(1, 0.7), Vector2(-0.6, 1)]), color)`

## effects/mayonnaise_particles.gd

102 líneas; 0 anotaciones export; 0 uniforms; 32 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const MAX_PARTICLES := 1800`
- L4, `declaración` (regla/valor): `var particles: Array[Dictionary] = []`
- L5, `declaración` (regla/valor): `var free_particles: Array[Dictionary] = []`
- L14, `emit_at` (texto): `pool = load("res://effects/mayonnaise_particles.gd").new()`
- L15, `emit_at` (literal adicional (revisión)): `pool.name = "MayonnaiseParticles"`
- L22, `_ready` (literal adicional (revisión)): `z_index = 3`
- L25, `_ready` (visual): `mesh.size = Vector2.ONE`
- L32, `_ready` (literal adicional (revisión)): `instances.instance_count = MAX_PARTICLES * 3`
- L33, `_ready` (literal adicional (revisión)): `instances.visible_instance_count = 0`
- L34, `_ready` (literal adicional (revisión)): `instances.custom_aabb = AABB(Vector3(-16384,-16384,-1),Vector3(32768,32768,2))`
- L38, `_ready` (texto): `shader_material.shader = preload("res://shaders/mayonnaise_droplet.gdshader")`
- L47, `emit_splash` (regla/valor): `var angle := direction.angle() + (PI if impact else 0.0) + randf_range(-1.35, 1.35)`
- L48, `emit_splash` (regla/valor): `var speed := settings.stream_particle_speed * Global.GAME_ENTITY_SCALE * randf_range(0.4, 1.35)`
- L49, `emit_splash` (regla/valor): `var velocity := Vector2.from_angle(angle) * speed`
- L50, `emit_splash` (regla/valor): `velocity.y *= 0.6`
- L51, `emit_splash` (regla/valor): `var life := settings.stream_particle_lifetime * randf_range(0.65, 1.15)`
- L53, `emit_splash` (visual): `particle.position = point + Vector2(randf_range(-3,3),randf_range(-2,2))`
- L57, `emit_splash` (regla/valor): `particle.radius = randf_range(1.2,2.7)*Global.GAME_ENTITY_SCALE`
- L68, `clear` (literal adicional (revisión)): `instances.visible_instance_count = 0`
- L73, `_process` (literal adicional (revisión)): `for i in range(particles.size()-1,-1,-1):`
- L76, `_process` (regla/valor): `if particle.life <= 0.0:`
- L83, `_process` (literal adicional (revisión)): `particle.velocity *= exp(-3.0 * delta)`
- L84, `_process` (regla/valor): `particle.velocity.y += 180.0 * delta`
- L91, `_update_instances` (literal adicional (revisión)): `var fade := clampf(particle.life / minf(0.12, particle.duration),0.0,1.0)`
- L92, `_update_instances` (literal adicional (revisión)): `var radius: float = particle.radius * (0.55+0.45*fade)`
- L94, `_update_instances` (literal adicional (revisión)): `var particle_transform := Transform2D(velocity.angle(),Vector2(radius*2.0*1.35,radius*2.0*0.8),0.0,particle.position)`
- L95, `_update_instances` (literal adicional (revisión)): `var index := i * 3`
- L98, `_update_instances` (literal adicional (revisión)): `instances.set_instance_transform_2d(index+1,Transform2D(particle_transform.x*0.78,particle_transform.y*0.78,particle_transform.origin))`
- L99, `_update_instances` (literal adicional (revisión)): `instances.set_instance_color(index+1,Color(particle.body,fade))`
- L100, `_update_instances` (literal adicional (revisión)): `instances.set_instance_transform_2d(index+2,Transform2D(particle_transform.x*0.35,particle_transform.y*0.35,particle_transform*Vector2(-0.08,-0.1)))`
- L101, `_update_instances` (literal adicional (revisión)): `instances.set_instance_color(index+2,Color(particle.core,fade))`
- L102, `_update_instances` (literal adicional (revisión)): `instances.visible_instance_count = particles.size() * 3`

## effects/pan_slow_burst.gd

39 líneas; 2 anotaciones export; 0 uniforms; 21 candidatos.

### Ya expuesto en el editor

- L14: `@export_range(0.1, 1.0) var y_ratio := DEFAULT_Y_RATIO`
- L15: `@export_range(0.0, 1.0) var opacity := 0.3`

### Candidatos / evidencia

- L2, `declaración` (regla/valor): `var radius := 120.0`
- L3, `declaración` (regla/valor): `var elapsed := 0.0`
- L4, `declaración` (constante): `const DURATION := 0.125`
- L6, `declaración` (visual): `var color := Color("86a9be")`
- L7, `declaración` (regla/valor): `var ring_width := 2.0`
- L8, `declaración` (regla/valor): `var spark_width := 1.5`
- L9, `declaración` (regla/valor): `var spark_length := 10.0`
- L10, `declaración` (regla/valor): `var spark_count := 16`
- L11, `declaración` (regla/valor): `var ring_start_radius := 0.3`
- L12, `declaración` (regla/valor): `var spark_start_radius := 0.45`
- L13, `declaración` (constante): `const DEFAULT_Y_RATIO := 0.55`
- L18, `contains_offset` (regla/valor): `return Vector2(offset.x, offset.y / maxf(ratio, 0.01)).length_squared() <= area_radius * area_radius`
- L21, `_ready` (literal adicional (revisión)): `z_index = 0`
- L25, `_process` (regla/valor): `if elapsed >= maxf(0.01, duration): queue_free()`
- L28, `_draw` (literal adicional (revisión)): `var progress := clampf(elapsed / maxf(0.01, duration), 0.0, 1.0)`
- L30, `_draw` (literal adicional (revisión)): `paint.a *= (1.0 - progress) * opacity`
- L31, `_draw` (regla/valor): `var projection := Vector2(1.0, y_ratio)`
- L33, `_draw` (literal adicional (revisión)): `for i in 49:`
- L34, `_draw` (literal adicional (revisión)): `ring.append(Vector2.from_angle(TAU * i / 48.0) * radius * lerpf(ring_start_radius, 1.0, progress) * projection)`
- L37, `_draw` (regla/valor): `var direction := Vector2.from_angle(TAU * i / spark_count)`
- L38, `_draw` (literal adicional (revisión)): `var point := direction * radius * lerpf(spark_start_radius, 1.0, progress)`

## effects/plate_fragments.gd

38 líneas; 0 anotaciones export; 0 uniforms; 15 candidatos.

### Candidatos / evidencia

- L2, `declaración` (regla/valor): `var pieces: Array[Dictionary] = []`
- L3, `declaración` (regla/valor): `var elapsed := 0.0`
- L4, `declaración` (regla/valor): `var duration := 0.45`
- L5, `declaración` (visual): `var edge_color := Color("c4bba7")`
- L6, `declaración` (regla/valor): `var edge_width := 0.1`
- L9, `setup` (literal adicional (revisión)): `z_index = 8`
- L10, `setup` (literal adicional (revisión)): `duration = maxf(0.01, config.plate_fragment_duration)`
- L14, `setup` (texto): `pieces.append({"point":Vector2.ZERO, "velocity":Vector2.from_angle(randf()*TAU)*randf_range(0.5,1.0)*config.plate_fragment_speed, "angle":randf()*TAU,"spin":randf_range(-12,12),"size":randf_range(3,7)*Global.GAME_ENTITY_SCALE})`
- L23, `_process` (literal adicional (revisión)): `piece.velocity *= exp(-3.0*delta)`
- L24, `_process` (regla/valor): `piece.velocity.y += 110.0*delta`
- L28, `_draw` (literal adicional (revisión)): `var alpha := clampf((duration-elapsed)/minf(duration,0.15),0.0,1.0)`
- L31, `_draw` (literal adicional (revisión)): `var points := PackedVector2Array([Vector2(-1,-0.4),Vector2(0.3,-0.7),Vector2(1,0.3),Vector2(-0.4,0.7)])`
- L32, `_draw` (literal adicional (revisión)): `draw_colored_polygon(points,Color(1,0.97,0.89,alpha))`
- L34, `_draw` (literal adicional (revisión)): `border.append(points[0])`
- L37, `_draw` (regla/valor): `if edge_width > 0.0: draw_polyline(border,outline,edge_width,true)`

## effects/rocoto_wave_visual.gd

63 líneas; 0 anotaciones export; 0 uniforms; 29 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var radius := 1.0`
- L5, `declaración` (regla/valor): `var elapsed := 0.0`
- L8, `declaración` (regla/valor): `var seeds: Array[Vector3] = []`
- L15, `configure` (regla/valor): `var extent := Vector2(radius,radius*settings.area_y_ratio)*1.15`
- L16, `configure` (visual): `surface.position = -extent`
- L17, `configure` (visual): `surface.size = extent*2.0`
- L19, `configure` (literal adicional (revisión)): `surface.z_index = 0`
- L21, `configure` (texto): `wave_material.shader = preload("res://shaders/rocoto_shockwave.gdshader")`
- L22, `configure` (texto): `wave_material.set_shader_parameter("heat_color",settings.color)`
- L23, `configure` (texto): `wave_material.set_shader_parameter("core_color",settings.shockwave_core_color)`
- L24, `configure` (texto): `wave_material.set_shader_parameter("duration",settings.wave_duration)`
- L25, `configure` (texto): `wave_material.set_shader_parameter("tail_duration",settings.shockwave_visual_tail)`
- L26, `configure` (texto): `wave_material.set_shader_parameter("rim_width",settings.shockwave_rim_width)`
- L27, `configure` (texto): `wave_material.set_shader_parameter("opacity",settings.opacity)`
- L28, `configure` (texto): `wave_material.set_shader_parameter("variation",randf()*TAU)`
- L36, `configure` (visual): `quad.size = Vector2.ONE`
- L40, `configure` (texto): `spark_material.shader = preload("res://shaders/rocoto_fragment.gdshader")`
- L43, `configure` (literal adicional (revisión)): `sparks.z_index = 0`
- L46, `configure` (regla/valor): `seeds.append(Vector3(float(index)*TAU/maxi(1,settings.shockwave_spark_count)+randf_range(-0.08,0.08),randf_range(0.65,1.1),randf_range(0.6,1.5)))`
- L47, `configure` (literal adicional (revisión)): `update_visual(0.0)`
- L51, `update_visual` (texto): `wave_material.set_shader_parameter("elapsed",elapsed)`
- L52, `update_visual` (literal adicional (revisión)): `var progress := clampf(elapsed/maxf(0.01,settings.wave_duration),0,1)`
- L53, `update_visual` (literal adicional (revisión)): `var tail := clampf((elapsed-settings.wave_duration)/maxf(0.01,settings.shockwave_visual_tail),0,1)`
- L56, `update_visual` (regla/valor): `var direction := Vector2(cos(seed.x),sin(seed.x)*settings.area_y_ratio)`
- L57, `update_visual` (literal adicional (revisión)): `var point := direction*radius*(progress+tail*0.1)*seed.y`
- L58, `update_visual` (literal adicional (revisión)): `point.y -= radius*0.08*sin(progress*PI)*seed.z`
- L60, `update_visual` (literal adicional (revisión)): `sparks.multimesh.set_instance_transform_2d(index,Transform2D(direction.angle(),Vector2(size*(1.4+progress),size),0.0,point))`
- L61, `update_visual` (literal adicional (revisión)): `var tint := settings.shockwave_core_color.lerp(settings.color,progress*0.55)`
- L62, `update_visual` (literal adicional (revisión)): `tint.a = smoothstep(0.0,0.12,progress)*(1.0-tail)*(1.0-tail)*0.6`

## effects/scotch_mine_visual.gd

119 líneas; 0 anotaciones export; 0 uniforms; 42 candidatos.

Hallazgos: FX-09.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var radius := 1.0`
- L6, `declaración` (visual): `var base_scale := 1.0`
- L12, `declaración` (regla/valor): `var flame_seeds: Array[Vector3] = []`
- L14, `declaración` (regla/valor): `var elapsed := 0.0`
- L15, `declaración` (regla/valor): `static var texture_bounds: Dictionary = {}`
- L30, `configure` (literal adicional (revisión)): `sprite.offset = Vector2(-region.size.x*0.5,-region.size.y)`
- L31, `configure` (literal adicional (revisión)): `base_scale = settings.mine_visual_width*Global.GAME_ENTITY_SCALE/maxf(1.0,region.size.x)`
- L33, `configure` (literal adicional (revisión)): `sprite.z_index = 0`
- L37, `configure` (regla/valor): `var extent := Vector2(radius,radius*settings.area_y_ratio)*1.35`
- L38, `configure` (visual): `blast.position = -extent`
- L39, `configure` (visual): `blast.size = extent*2.0`
- L41, `configure` (literal adicional (revisión)): `blast.z_index = 0`
- L43, `configure` (texto): `blast_material.shader = preload("res://shaders/habanero_blast.gdshader")`
- L44, `configure` (texto): `blast_material.set_shader_parameter("heat_color",settings.color)`
- L45, `configure` (texto): `blast_material.set_shader_parameter("core_color",settings.mine_core_color)`
- L46, `configure` (texto): `blast_material.set_shader_parameter("flame_color",settings.mine_flame_color)`
- L47, `configure` (texto): `blast_material.set_shader_parameter("opacity",0.95)`
- L48, `configure` (texto): `blast_material.set_shader_parameter("flame_strength",1.35)`
- L49, `configure` (texto): `blast_material.set_shader_parameter("variation",phase)`
- L59, `configure` (visual): `quad.size = Vector2.ONE`
- L60, `configure` (literal adicional (revisión)): `quad.center_offset = Vector3(0,-0.5,0)`
- L64, `configure` (texto): `flame_material.shader = preload("res://shaders/burning_flame_sprite.gdshader")`
- L65, `configure` (texto): `flame_material.set_shader_parameter("flame_texture",load("res://assets/sprites/Effects/small_fire.png"))`
- L66, `configure` (texto): `flame_material.set_shader_parameter("opacity",0.9)`
- L67, `configure` (texto): `flame_material.set_shader_parameter("distortion_strength",0.035)`
- L70, `configure` (literal adicional (revisión)): `flame_burst.z_index = 0`
- L74, `configure` (regla/valor): `flame_seeds.append(Vector3(randf()*TAU,randf_range(0.45,0.8),randf_range(0.45,0.9)))`
- L75, `configure` (literal adicional (revisión)): `flame_burst.multimesh.set_instance_custom_data(index,Color(randf()*TAU,1.0,0.7,0))`
- L76, `configure` (literal adicional (revisión)): `update_visual(0.0, false, 0.0)`
- L85, `detonate` (texto): `blast_material.set_shader_parameter("detonated",true)`
- L86, `detonate` (texto): `blast_material.set_shader_parameter("progress",0.0)`
- L95, `detonate` (literal adicional (revisión)): `config.opacity = 0.95`
- L96, `detonate` (texto): `var sparks = load("res://effects/habanero_embers.gd").new()`
- L105, `update_visual` (literal adicional (revisión)): `var progress := clampf(blast_time/maxf(0.01,settings.wave_duration),0,1)`
- L106, `update_visual` (texto): `blast_material.set_shader_parameter("progress",progress)`
- L107, `update_visual` (texto): `flame_material.set_shader_parameter("elapsed",blast_time)`
- L108, `update_visual` (texto): `flame_material.set_shader_parameter("fade",1.0-smoothstep(0.2,1.0,progress))`
- L111, `update_visual` (regla/valor): `var expansion := 0.2+0.8*(1.0-pow(1.0-progress,3.0))`
- L112, `update_visual` (regla/valor): `var point := Vector2(cos(seed.x),sin(seed.x)*settings.area_y_ratio)*radius*seed.y*expansion`
- L113, `update_visual` (literal adicional (revisión)): `var height := radius*seed.z*(0.7+0.3*sin(progress*PI))`
- L114, `update_visual` (literal adicional (revisión)): `flame_burst.multimesh.set_instance_transform_2d(index,Transform2D(0.0,Vector2(height*0.65,height),0.0,point))`
- L119, `update_visual` (visual): `sprite.scale = Vector2(1.0+pulse,1.0-pulse)*base_scale`

## effects/spicy_burn.gd

9 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L9, `apply` (texto): `load("res://effects/fire_status.gd").apply(enemy, "HabaneroBurn_%s" % weapon_id, template, effect, true)`

## effects/spicy_explosion.gd

78 líneas; 0 anotaciones export; 0 uniforms; 26 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var radius := 0.0`
- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L8, `declaración` (regla/valor): `var weapon_id := 0`
- L18, `configure` (literal adicional (revisión)): `hit.collision_layer = 0`
- L19, `configure` (literal adicional (revisión)): `hit.collision_mask = 0`
- L29, `_ready` (literal adicional (revisión)): `z_index = 0`
- L32, `_ready` (regla/valor): `var extent := Vector2(radius,radius*settings.area_y_ratio)*1.35`
- L33, `_ready` (visual): `surface.position = -extent`
- L34, `_ready` (visual): `surface.size = extent*2.0`
- L36, `_ready` (texto): `blast_material.shader = preload("res://shaders/habanero_blast.gdshader")`
- L39, `_ready` (texto): `blast_material.set_shader_parameter("heat_color",settings.color)`
- L40, `_ready` (texto): `blast_material.set_shader_parameter("core_color",settings.core_color)`
- L41, `_ready` (texto): `blast_material.set_shader_parameter("flame_color",settings.flame_color)`
- L42, `_ready` (texto): `blast_material.set_shader_parameter("opacity",settings.opacity)`
- L43, `_ready` (texto): `blast_material.set_shader_parameter("anticipation_opacity",settings.anticipation_opacity)`
- L44, `_ready` (texto): `blast_material.set_shader_parameter("flame_strength",settings.flame_strength)`
- L45, `_ready` (texto): `blast_material.set_shader_parameter("variation",visual_seed)`
- L56, `_process` (texto): `blast_material.set_shader_parameter("detonated",detonated)`
- L57, `_process` (literal adicional (revisión)): `var progress := elapsed/maxf(0.001,settings.anticipation)`
- L58, `_process` (regla/valor): `if detonated: progress = (elapsed-settings.anticipation)/maxf(0.001,settings.visual_duration)`
- L59, `_process` (texto): `blast_material.set_shader_parameter("progress",clampf(progress,0,1))`
- L65, `detonate` (regla/valor): `if settings.ember_count > 0:`
- L66, `detonate` (texto): `var embers = preload("res://effects/habanero_embers.gd").new()`
- L71, `detonate` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue`
- L76, `detonate` (regla/valor): `if not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0.0:`
- L77, `detonate` (texto): `load("res://effects/spicy_burn.gd").apply(enemy, weapon_id, hit, settings)`

## effects/spicy_pattern_effect.gd

420 líneas; 0 anotaciones export; 0 uniforms; 98 candidatos.

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var radius := 0.0`
- L8, `declaración` (regla/valor): `var elapsed := 0.0`
- L9, `declaración` (regla/valor): `var duration_multiplier := 1.0`
- L10, `declaración` (regla/valor): `var tick_left := 0.0`
- L11, `declaración` (regla/valor): `var velocity := Vector2.ZERO`
- L12, `declaración` (regla/valor): `var orbit_angle := 0.0`
- L13, `declaración` (regla/valor): `var orbit_radius := 0.0`
- L14, `declaración` (regla/valor): `var orbit_previous_center := Vector2.ZERO`
- L15, `declaración` (visual): `var orbit_enemy_positions: Dictionary = {}`
- L16, `declaración` (regla/valor): `var orbit_hit_cooldowns: Dictionary = {}`
- L18, `declaración` (regla/valor): `var detonation_time := 0.0`
- L19, `declaración` (regla/valor): `var hit_targets: Dictionary = {}`
- L27, `declaración` (visual): `var column_enemy_positions: Dictionary = {}`
- L28, `declaración` (regla/valor): `var column_hit_cooldowns: Dictionary = {}`
- L29, `declaración` (regla/valor): `var column_trail_distance := 0.0`
- L32, `declaración` (regla/valor): `var trail_entries: Array[Dictionary] = []`
- L33, `declaración` (regla/valor): `var trail_lifetime := 0.0`
- L34, `declaración` (regla/valor): `var trail_item_effects: Array[StatusEffect] = []`
- L35, `declaración` (regla/valor): `var trail_contacts: Dictionary = {}`
- L36, `declaración` (visual): `var trail_previous_positions: Dictionary = {}`
- L49, `configure` (literal adicional (revisión)): `hit.collision_layer = 0`
- L50, `configure` (literal adicional (revisión)): `hit.collision_mask = 0`
- L64, `configure` (visual): `sprite.scale = Vector2.ONE * settings.sprite_scale * Global.GAME_ENTITY_SCALE`
- L65, `configure` (literal adicional (revisión)): `sprite.z_index = 0`
- L66, `configure` (regla/valor): `if weapon.data.golden_multiplier > 1.0:`
- L67, `configure` (texto): `sprite.material = load("res://effects/golden_visual.gd").material_for(weapon.data)`
- L69, `configure` (texto): `var stars = load("res://effects/golden_sparkles.gd").new()`
- L70, `configure` (literal adicional (revisión)): `stars.radius = minf(sprite.get_rect().size.x, sprite.get_rect().size.y) * 0.5`
- L76, `configure` (texto): `trail_visual = load("res://effects/cayenne_trail_visual.gd").new()`
- L81, `configure` (texto): `column_visual = load("res://effects/fire_column_visual.gd").new()`
- L83, `configure` (regla/valor): `column_visual.configure(settings, radius, settings.lifetime*duration_multiplier if settings.lifetime>0.0 else INF)`
- L85, `configure` (texto): `cloud_visual = load("res://effects/ghost_cloud_visual.gd").new()`
- L89, `configure` (texto): `mine_visual = load("res://effects/scotch_mine_visual.gd").new()`
- L94, `configure` (texto): `wave_visual = load("res://effects/rocoto_wave_visual.gd").new()`
- L102, `configure` (texto): `effect_material.shader = preload("res://shaders/spicy_pattern.gdshader")`
- L104, `configure` (regla/valor): `var extent := Vector2(radius,radius*settings.area_y_ratio)`
- L105, `configure` (visual): `surface.position = -extent`
- L106, `configure` (visual): `surface.size = extent*2.0`
- L110, `configure` (texto): `effect_material.set_shader_parameter("mode",settings.mode)`
- L111, `configure` (texto): `effect_material.set_shader_parameter("tint",settings.color)`
- L112, `configure` (texto): `effect_material.set_shader_parameter("opacity",settings.opacity)`
- L119, `_ready` (literal adicional (revisión)): `z_index = 0`
- L124, `_process` (regla/valor): `if not is_instance_valid(source) or source.health_component.current_health <= 0.0 or not is_instance_valid(weapon) or weapon.is_queued_for_deletion():`
- L141, `_process` (literal adicional (revisión)): `var current_radius := radius*clampf(elapsed/settings.wave_duration,0,1)`
- L142, `_process` (literal adicional (revisión)): `var inner := maxf(0.0,radius*clampf(previous/settings.wave_duration,0,1)-settings.wave_band*Global.GAME_ENTITY_SCALE)`
- L156, `_process` (regla/valor): `if tick_left <= 0.0:`
- L160, `_process` (regla/valor): `if lifetime > 0.0 and elapsed >= lifetime: queue_free()`
- L171, `_leave_column_trail` (regla/valor): `if distance <= 0.001 or settings.column_trail_damage_multiplier <= 0.0: return`
- L179, `_leave_column_trail` (literal adicional (revisión)): `column_trail_settings.radius = settings.radius * settings.column_fill_width * 0.5 * settings.column_trail_radius_multiplier`
- L181, `_leave_column_trail` (texto): `if not config: config = load("res://resources/statuses/fire_visual_default.tres")`
- L183, `_leave_column_trail` (literal adicional (revisión)): `column_trail_settings.trail_fire_visuals.flame_count = 10`
- L184, `_leave_column_trail` (literal adicional (revisión)): `column_trail_settings.trail_fire_visuals.ember_count = 4`
- L185, `_leave_column_trail` (texto): `var patch = load("res://effects/spicy_pattern_effect.gd").new()`
- L193, `_leave_column_trail` (literal adicional (revisión)): `child.z_index = -1`
- L199, `_configure_column_trail` (regla/valor): `var effects: Array[StatusEffect] = []`
- L215, `_update_column_contacts` (visual): `var positions: Dictionary = {}`
- L216, `_update_column_contacts` (regla/valor): `var cooldowns: Dictionary = {}`
- L223, `_update_column_contacts` (regla/valor): `var padding := 0.0`
- L224, `_update_column_contacts` (regla/valor): `if shape and shape.shape is CircleShape2D and not shape.disabled:`
- L226, `_update_column_contacts` (regla/valor): `var extent := Vector2(reach + padding, reach * settings.area_y_ratio + padding)`
- L230, `_update_column_contacts` (literal adicional (revisión)): `var next_hit: float = column_hit_cooldowns.get(id, 0.0)`
- L231, `_update_column_contacts` (regla/valor): `if elapsed >= next_hit and Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= 1.0:`
- L234, `_update_column_contacts` (literal adicional (revisión)): `next_hit = elapsed + maxf(0.001, interval)`
- L245, `_valid_enemy` (regla/valor): `return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and not enemy.is_retiring and enemy.health_component.current_health > 0.0`
- L247, `_damage` (literal adicional (revisión)): `func _damage(outer: float, inner: float = 0.0, once: bool = false) -> void:`
- L271, `_update_visual` (regla/valor): `var progress := clampf(elapsed/settings.wave_duration,0,1) if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE else clampf((elapsed-detonation_time)/settings.wave_duration,0,1) if detonated else 0.0`
- L272, `_update_visual` (texto): `effect_material.set_shader_parameter("elapsed",elapsed)`
- L273, `_update_visual` (texto): `effect_material.set_shader_parameter("progress",progress)`
- L274, `_update_visual` (texto): `effect_material.set_shader_parameter("detonated",detonated)`
- L277, `_trail_at` (regla/valor): `var result: Array[Dictionary] = []`
- L283, `_trail_at` (regla/valor): `if previous != Vector2.INF:`
- L286, `_trail_at` (regla/valor): `if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= entry.radius * entry.radius:`
- L291, `_update_trail_contacts` (visual): `var positions: Dictionary = {}`
- L292, `_update_trail_contacts` (regla/valor): `var contacts: Dictionary = {}`
- L299, `_update_trail_contacts` (regla/valor): `var present: Array = []`
- L302, `_update_trail_contacts` (regla/valor): `var entries: Array[Dictionary] = []`
- L311, `_update_trail_contacts` (texto): `load("res://effects/status_controller.gd").apply_effect(enemy, effect, hit)`
- L331, `_set_trail_hit` (regla/valor): `var total := 0.0`
- L332, `_set_trail_hit` (regla/valor): `var shares: Array[Dictionary] = []`
- L336, `_set_trail_hit` (literal adicional (revisión)): `for share in shares: share.weight /= maxf(0.00001, total)`
- L339, `_set_trail_hit` (literal adicional (revisión)): `hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}`
- L341, `_set_trail_hit` (regla/valor): `var fires: Dictionary = {}`
- L352, `_set_trail_hit` (literal adicional (revisión)): `merged.damage = 0.0`
- L363, `_orbit_point` (regla/valor): `return center + Vector2(cos(angle), sin(angle) * settings.area_y_ratio) * orbit_radius`
- L375, `_process_orbit` (literal adicional (revisión)): `var steps := maxi(1, ceili(travel / maxf(1.0, radius * 0.35)))`
- L376, `_process_orbit` (visual): `var positions: Dictionary = {}`
- L377, `_process_orbit` (regla/valor): `var cooldowns: Dictionary = {}`
- L384, `_process_orbit` (literal adicional (revisión)): `var next_hit: float = orbit_hit_cooldowns.get(id, 0.0)`
- L386, `_process_orbit` (regla/valor): `if elapsed + 0.00001 < next_hit: continue`
- L387, `_process_orbit` (regla/valor): `var padding := 0.0`
- L388, `_process_orbit` (regla/valor): `if shape and shape.shape is CircleShape2D:`
- L390, `_process_orbit` (regla/valor): `var extent := Vector2(radius + padding, radius * settings.area_y_ratio + padding)`
- L394, `_process_orbit` (literal adicional (revisión)): `var fraction := float(index + 1) / steps`
- L396, `_process_orbit` (regla/valor): `if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, start, end).length_squared() <= 1.0:`
- L411, `_configure_shared_wave` (regla/valor): `var total := 0.0`
- L412, `_configure_shared_wave` (regla/valor): `var shares: Array[Dictionary] = []`
- L417, `_configure_shared_wave` (literal adicional (revisión)): `for share in shares: share.weight /= maxf(0.00001,total)`
- L420, `_configure_shared_wave` (literal adicional (revisión)): `hit.weapon_damage_record = {"wave_damage":0.0,"total_damage":0.0,"contributors":shares}`

## effects/status_controller.gd

240 líneas; 0 anotaciones export; 0 uniforms; 71 candidatos.

Hallazgos: FX-08.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var slows: Array[Dictionary] = []`
- L4, `declaración` (regla/valor): `var lightning_left := 0.0`
- L5, `declaración` (visual): `var lightning_color := Color(0.5, 0.85, 1.0)`
- L6, `declaración` (regla/valor): `var arcs: Array[Vector2] = []`
- L7, `declaración` (regla/valor): `var electric_duration := 1.5`
- L8, `declaración` (regla/valor): `var electric_elapsed := 0.0`
- L9, `declaración` (regla/valor): `var electric_ray_count := 7`
- L10, `declaración` (regla/valor): `var electric_glow := 1.0`
- L11, `declaración` (visual): `var electric_visual_scale := 1.0`
- L13, `declaración` (regla/valor): `var impact_cooldown := 0.0`
- L16, `declaración` (regla/valor): `static var burning_enemy_count := 0`
- L18, `declaración` (regla/valor): `var burning_sources: Dictionary = {}`
- L39, `has_status` (regla/valor): `if not unit or unit.health_component.current_health <= 0.0: return false`
- L43, `has_status` (regla/valor): `if is_instance_valid(burn) and not burn.is_queued_for_deletion() and burn.remaining > 0.0: return true`
- L45, `has_status` (regla/valor): `if state == Unit.State.SHOKED: return lightning_left > 0.0`
- L46, `has_status` (regla/valor): `if state == Unit.State.AIRBOURNE: return unit is Enemy and unit.launch_left > 0.0`
- L50, `has_status` (regla/valor): `if not unit.pins.is_empty() or (unit.slow_left > 0.0 and unit.slow_factor <= 0.0): return true`
- L52, `has_status` (regla/valor): `if slow.left > 0.0 and slow.factor <= 0.0: return true`
- L54, `has_status` (regla/valor): `if unit is Enemy and unit.slow_left > 0.0 and unit.slow_factor > 0.0 and unit.slow_factor < 1.0: return true`
- L56, `has_status` (regla/valor): `if slow.left > 0.0 and slow.factor > 0.0 and slow.factor < 1.0: return true`
- L65, `refresh_control_text` (texto): `control_label = load("res://scenes/ui/control_state_label.tscn").instantiate()`
- L68, `refresh_control_text` (texto): `control_label.text = " Â· ".join(names)`
- L74, `refresh_control_text` (visual): `control_label.scale = Vector2.ONE / global_scale.abs()`
- L76, `refresh_control_text` (visual): `control_label.position = anchor - Vector2(control_label.size.x * control_label.scale.x * 0.5, (control_label.size.y + 4.0) / absf(global_scale.y))`
- L82, `_ready` (literal adicional (revisión)): `z_index = 0`
- L86, `apply_effect` (regla/valor): `if not is_instance_valid(target) or target.is_queued_for_deletion() or target.health_component.current_health <= 0.0: return`
- L92, `apply_effect` (regla/valor): `var source_id := template.source.get_instance_id() if is_instance_valid(template.source) else 0`
- L95, `apply_effect` (texto): `elif not template.weapon_damage_record.is_empty(): effect_id += "_weapon_%s" % template.weapon_damage_record.get("instance_id", 0)`
- L96, `apply_effect` (texto): `load("res://effects/fire_status.gd").apply(target, "Fire_%s_%s" % [source_id, effect_id.hash()], template, effect)`
- L99, `apply_effect` (regla/valor): `var neighbors: Array[Unit] = []`
- L102, `apply_effect` (texto): `var chain_limit: int = effect.maximum_chain_targets + (template.source.passive_items.discrete_power("spark") if template.source is Player else 0)`
- L104, `apply_effect` (regla/valor): `if spread and radius > 0.0 and chain_limit > 0:`
- L105, `apply_effect` (texto): `var group := "combat_players" if target is Player else "combat_enemies"`
- L107, `apply_effect` (texto): `if group == "combat_enemies" and EnemyCrowd.members.size() > 32:`
- L112, `apply_effect` (regla/valor): `if candidate == target or not is_instance_valid(candidate) or candidate.is_queued_for_deletion() or candidate.health_component.current_health <= 0.0: continue`
- L115, `apply_effect` (literal adicional (revisión)): `offset.y /= 0.6`
- L120, `apply_effect` (regla/valor): `var status_duration := effect.duration * (source_stats.effect_duration_multiplier() if source_stats else 1.0)`
- L121, `apply_effect` (texto): `if status_duration>0 and controller.lightning_left<=0: SoundManager.play_event("electric_apply")`
- L123, `apply_effect` (literal adicional (revisión)): `controller.electric_duration = maxf(0.01, controller.lightning_left)`
- L124, `apply_effect` (literal adicional (revisión)): `controller.electric_elapsed = 0.0`
- L132, `apply_effect` (regla/valor): `if controller.impact_cooldown<=0.0:`
- L133, `apply_effect` (texto): `var burst = load("res://effects/electric_impact.gd").new()`
- L136, `apply_effect` (regla/valor): `var chain_points: Array[Vector2] = []`
- L139, `apply_effect` (literal adicional (revisión)): `controller.impact_cooldown = 0.06`
- L143, `apply_effect` (literal adicional (revisión)): `controller.electric_hit.collision_layer = 0`
- L144, `apply_effect` (literal adicional (revisión)): `controller.electric_hit.collision_mask = 0`
- L148, `apply_effect` (literal adicional (revisión)): `hit.setup(status_damage, false, 0.0, template.source)`
- L156, `apply_effect` (regla/valor): `if target is Enemy and template.source is Player and target.health_component.current_health > 0.0 and not target.is_queued_for_deletion():`
- L158, `apply_effect` (regla/valor): `if items.electric_slow_strength > 0.0 and items.electric_slow_duration > 0.0:`
- L159, `apply_effect` (literal adicional (revisión)): `controller.add_slow(source_stats.effective_slow(1.0 - items.electric_slow_strength), items.electric_slow_duration * source_stats.get_crowd_control_multiplier())`
- L165, `add_slow` (regla/valor): `if duration > 0.0:`
- L167, `add_slow` (regla/valor): `if is_equal_approx(slow.factor,clampf(factor,0.0,1.0)):`
- L171, `add_slow` (literal adicional (revisión)): `slows.append({"factor":clampf(factor, 0.0, 1.0), "left":duration})`
- L177, `movement_multiplier` (regla/valor): `var result := 1.0`
- L186, `clear` (literal adicional (revisión)): `get_parent().status_movement_multiplier = 1.0`
- L187, `clear` (literal adicional (revisión)): `lightning_left = 0.0`
- L188, `clear` (literal adicional (revisión)): `electric_elapsed = 0.0`
- L189, `clear` (literal adicional (revisión)): `impact_cooldown = 0.0`
- L192, `clear` (texto): `if child.get_script() == load("res://effects/fire_status.gd"):`
- L200, `_process` (literal adicional (revisión)): `impact_cooldown = maxf(0.0,impact_cooldown-delta)`
- L201, `_process` (literal adicional (revisión)): `for index in range(slows.size()-1, -1, -1):`
- L203, `_process` (regla/valor): `if slows[index].left <= 0.0: slows.remove_at(index)`
- L205, `_process` (literal adicional (revisión)): `lightning_left = maxf(0.0, lightning_left - delta)`
- L206, `_process` (regla/valor): `if lightning_left > 0.0: electric_elapsed += delta`
- L207, `_process` (regla/valor): `if lightning_left > 0.0: _submit_rays()`
- L210, `_process` (regla/valor): `if slows.is_empty() and lightning_left<=0.0 and impact_cooldown<=0.0 and not (is_instance_valid(control_label) and control_label.visible): set_process(false)`
- L213, `_submit_rays` (regla/valor): `if lightning_left <= 0.0: return`
- L215, `_submit_rays` (regla/valor): `if not unit or unit.health_component.current_health <= 0.0: return`
- L219, `_submit_rays` (visual): `var extent := Vector2(clampf(size.x * 0.43, 9.0, 55.0), clampf(size.y * 0.43, 12.0, 65.0)) * electric_visual_scale`
- L224, `sync_burning_enemy` (literal adicional (revisión)): `var active: bool = unit is Enemy and unit.targetable and not unit.is_retiring and not unit.is_queued_for_deletion() and unit.health_component.current_health > 0.0 and has_status(Unit.State.BURNING)`
- L235, `_set_burning_enemy_counted` (regla/valor): `burning_enemy_count = maxi(0, burning_enemy_count + (1 if active else -1))`

## fried.gd

25 líneas; 2 anotaciones export; 0 uniforms; 3 candidatos.

### Ya expuesto en el editor

- L4: `@export var variants: Array[Texture2D] = []`
- L6: `@export var drawing_width := 150.0`

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `static var _texture_regions: Dictionary = {}`
- L14, `_ready` (literal adicional (revisión)): `z_index = -3`
- L23, `_ready` (visual): `if region_rect.size.x > 0:`

## resources/arena_environment.gd

71 líneas; 11 anotaciones export; 0 uniforms; 24 candidatos.

Hallazgos: PERF-03.

### Ya expuesto en el editor

- L5: `@export var first_wave := 1`
- L6: `@export var background: Texture2D`
- L7: `@export var vessel: Texture2D`
- L8: `@export var background_size := Vector2(6144, 4096)`
- L9: `@export var background_offset := Vector2.ZERO`
- L10: `@export var vessel_size := Vector2(2900, 1900)`
- L11: `@export var vessel_offset := Vector2.ZERO`
- L12: `@export var movement_bounds := Rect2(-1000, -500, 2000, 985)`
- L13: `@export var oval := false`
- L14: `@export var corner_radius := 0.0`
- L15: `@export var camera_zoom := 1.0`

### Candidatos / evidencia

- L19, `clamp_position` (visual): `var bounded := Vector2(clampf(point.x, movement_bounds.position.x, movement_bounds.end.x),`
- L21, `clamp_position` (regla/valor): `if corner_radius <= 0.0: return bounded`
- L23, `clamp_position` (visual): `var nearest := Vector2(clampf(bounded.x, inner.position.x, inner.end.x),`
- L27, `clamp_position` (literal adicional (revisión)): `var radii := movement_bounds.size * 0.5`
- L29, `clamp_position` (regla/valor): `if normalized.length_squared() > 1.0:`
- L36, `random_spawn_position` (regla/valor): `return movement_bounds.get_center() + Vector2.RIGHT.rotated(randf() * TAU) \`
- L37, `random_spawn_position` (literal adicional (revisión)): `* sqrt(randf()) * movement_bounds.size * 0.5`
- L39, `random_spawn_position` (visual): `var point := Vector2(randf_range(movement_bounds.position.x, movement_bounds.end.x),`
- L40, `random_spawn_position` (visual): `randf_range(movement_bounds.position.y, movement_bounds.end.y))`
- L46, `boundary_clearance` (visual): `if not clamp_position(point).is_equal_approx(point): return 0.0`
- L48, `boundary_clearance` (literal adicional (revisión)): `var half := movement_bounds.size * 0.5`
- L50, `boundary_clearance` (literal adicional (revisión)): `var radius := clampf(corner_radius, 0.0, minf(half.x, half.y))`
- L52, `boundary_clearance` (regla/valor): `return maxf(0.0, radius - q.max(Vector2.ZERO).length() - minf(maxf(q.x, q.y), 0.0))`
- L54, `boundary_clearance` (regla/valor): `var best_angle := 0.0`
- L56, `boundary_clearance` (literal adicional (revisión)): `var step := PI * 0.5 / 24.0`
- L57, `boundary_clearance` (literal adicional (revisión)): `for index in 25:`
- L63, `boundary_clearance` (literal adicional (revisión)): `var low := maxf(0.0, best_angle-step)`
- L64, `boundary_clearance` (literal adicional (revisión)): `var high := minf(PI*0.5, best_angle+step)`
- L65, `boundary_clearance` (literal adicional (revisión)): `for iteration in 16:`
- L66, `boundary_clearance` (literal adicional (revisión)): `var a := lerpf(low,high,1.0/3.0)`
- L67, `boundary_clearance` (literal adicional (revisión)): `var b := lerpf(low,high,2.0/3.0)`
- L68, `boundary_clearance` (regla/valor): `if (Vector2(cos(a),sin(a))*half).distance_squared_to(offset) < (Vector2(cos(b),sin(b))*half).distance_squared_to(offset): high=b`
- L70, `boundary_clearance` (literal adicional (revisión)): `var middle := (low+high)*0.5`
- L71, `boundary_clearance` (regla/valor): `return sqrt(minf(best_distance,(Vector2(cos(middle),sin(middle))*half).distance_squared_to(offset)))`

## resources/arena_stage.gd

22 líneas; 13 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export var music_tracks: Array[AudioStream] = []`
- L6: `@export var id: StringName`
- L7: `@export var display_name: String`
- L8: `@export_multiline var description: String`
- L9: `@export var vessel: Texture2D`
- L10: `@export var background_color := Color("c8b99e")`
- L11: `@export var vessel_size := Vector2(3000, 2000)`
- L12: `@export var vessel_offset := Vector2.ZERO`
- L14: `@export var vessel_body_rect := Rect2()`
- L15: `@export var play_area: ArenaEnvironment`
- L16: `@export var mechanic_scene: PackedScene`
- L18: `@export var background_material: Material`
- L19: `@export var vessel_material: Material`


## resources/bosses/boss_encounter_settings.gd

132 líneas; 108 anotaciones export; 0 uniforms; 10 candidatos.

### Ya expuesto en el editor

- L3: `@export var boss_name := "Salchichón del Infierno"`
- L4: `@export var arena_stage: ArenaStage`
- L5: `@export var boss_scene: PackedScene`
- L6: `@export_range(1,1000000,1) var total_health := 1000.0`
- L7: `@export_range(0.1,60,0.1) var vulnerable_seconds := 8.0`
- L8: `@export_range(0.1,60,0.1) var section_seconds := 30.0`
- L9: `@export_range(0,30,0.1) var initial_wait_seconds := 3.0`
- L10: `@export_range(0,30,0.1) var departure_wait_seconds := 2.0`
- L11: `@export_range(0.1,10,0.1) var landing_warning_seconds := 1.2`
- L12: `@export_range(0.1,3,0.05) var fall_seconds := 0.4`
- L13: `@export var contact_damage := 5.0`
- L14: `@export var landing_damage := 5.0`
- L16: `@export_range(0.1,2,0.05) var landing_radius_multiplier := 1.0`
- L17: `@export var fall_height := 600.0`
- L18: `@export var landing_visual_radius_multiplier := 1.1`
- L19: `@export_range(0,2,0.01) var takeoff_anticipation_seconds := 0.22`
- L20: `@export_range(0,2,0.01) var takeoff_jump_seconds := 0.48`
- L21: `@export_range(0,0.5,0.01) var takeoff_compression := 0.22`
- L22: `@export var takeoff_height := 1800.0`
- L23: `@export_group("Boss squash and stretch")`
- L24: `@export_range(0,0.3,0.005) var idle_squash_strength := 0.045`
- L25: `@export_range(0.2,5,0.05) var idle_squash_period := 1.4`
- L26: `@export_range(0,0.5,0.01) var landing_squash_strength := 0.2`
- L27: `@export_range(0.1,2,0.05) var landing_squash_seconds := 0.55`
- L28: `@export_group("Isolated test character")`
- L29: `@export var test_health := 85.0`
- L30: `@export var test_regen := 0.0`
- L31: `@export var test_ranged_damage := 15.0`
- L32: `@export var test_damage_percent := 40.0`
- L33: `@export var test_armor := 15.0`
- L34: `@export var test_block_chance := 20.0`
- L35: `@export var test_life_steal := 20.0`
- L37: `@export_group("Phase 1 - static fire lines")`
- L38: `@export var static_line_patterns: Array[Resource] = []`
- L39: `@export_range(1,160,1) var line_width := 72.0`
- L40: `@export var line_damage := 10.0`
- L41: `@export_group("Laser glow")`
- L42: `@export_range(0,1000,10) var laser_end_overscan := 240.0`
- L43: `@export var laser_glow_strength := 1.0`
- L44: `@export var laser_flash_strength := 1.225`
- L45: `@export_range(0.05,1,0.01) var laser_flash_seconds := 0.22`
- L46: `@export_group("Phase 1 - static fire lines")`
- L48: `@export var line_target_player := true`
- L49: `@export_range(0.1,10,0.1) var line_warning_seconds := 1.2`
- L50: `@export_range(0.1,20,0.1) var line_active_seconds := 1.0`
- L51: `@export_range(0,20,0.1) var line_rest_seconds := 0.8`
- L52: `@export_group("Phase 1 - fixed turrets")`
- L53: `@export var turret_scene: PackedScene`
- L54: `@export_range(0.1,30,0.1) var turret_batch_interval := 2.0`
- L55: `@export_range(0.1,30,0.1) var turret_lifetime := 4.0`
- L56: `@export_range(0.1,10,0.1) var turret_warning_seconds := 1.2`
- L58: `@export var turret_target_player := true`
- L59: `@export var turret_line_width := 72.0`
- L60: `@export var turret_line_damage := 10.0`
- L61: `@export var turret_contact_damage := 5.0`
- L63: `@export_range(100,600,10) var turret_spawn_min_distance := 220.0`
- L64: `@export var turret_contact_radius := 42.0`
- L65: `@export var turret_visual_height := 140.0`
- L67: `@export var turret_positions := PackedVector2Array([`
- L72: `@export_group("Phase 1 - hot zones and Fueguitos")`
- L73: `@export var fueguito_profile: EnemyProfile`
- L74: `@export_range(0.1,30,0.1) var fueguito_interval := 3.0`
- L75: `@export_range(0.05,3,0.05) var fueguito_flare_seconds := 0.45`
- L76: `@export_range(0.1,30,0.1) var hot_zone_interval := 5.0`
- L77: `@export_range(1,24,1) var hot_zone_count := 12`
- L78: `@export var hot_zone_radius := 350.0`
- L79: `@export var hot_zone_damage := 2.0`
- L80: `@export_range(0.05,5,0.05) var hot_zone_damage_interval := 0.75`
- L81: `@export_range(0.05,5,0.05) var hot_zone_warning_seconds := 1.0`
- L82: `@export_range(0.05,5,0.05) var hot_zone_cooling_seconds := 1.2`
- L83: `@export_group("Phase 2 - persistent Fueguito")`
- L84: `@export var phase_two_fueguito_enabled := true`
- L85: `@export_group("Phase 2 - moving lines")`
- L86: `@export_range(0.1,10,0.1) var moving_line_interval := 3.0`
- L87: `@export_range(0.05,5,0.05) var moving_line_warning_seconds := 0.6`
- L88: `@export_range(0.1,10,0.1) var moving_line_travel_seconds := 2.4`
- L89: `@export var moving_line_width := 72.0`
- L90: `@export var moving_line_damage := 10.0`
- L92: `@export var moving_line_directions := PackedVector2Array([`
- L96: `@export var moving_line_double_attacks := PackedInt32Array([5,10])`
- L97: `@export_range(1,100,1) var moving_line_triple_from := 6`
- L99: `@export var moving_line_triple_spacing := 108.0`
- L100: `@export_range(1,12,1) var moving_line_parallel_count := 3`
- L101: `@export_group("Phase 2 - rotating turrets")`
- L102: `@export_range(0.1,30,0.1) var rotating_turret_interval := 3.0`
- L103: `@export_range(0.1,30,0.1) var rotating_turret_lifetime := 3.0`
- L104: `@export_range(0.05,5,0.05) var rotating_turret_warning_seconds := 1.2`
- L105: `@export_range(0,360,1) var rotating_turret_degrees_per_second := 30.0`
- L106: `@export_group("Phase 2 - intensified lines")`
- L107: `@export_range(0.1,10,0.1) var intensified_line_interval := 2.0`
- L109: `@export_range(0.025,1,0.025) var intensified_line_density := 0.375`
- L110: `@export_group("Phase 3 - complex lines")`
- L111: `@export_range(0.1,10,0.1) var complex_line_interval := 2.5`
- L112: `@export_range(0.05,5,0.05) var complex_moving_warning_seconds := 0.5`
- L113: `@export_range(0.1,10,0.1) var complex_moving_travel_seconds := 1.5`
- L114: `@export_range(1,12,1) var complex_moving_parallel_count := 5`
- L115: `@export var complex_moving_spacing := 108.0`
- L116: `@export_group("Phase 3 - mobile or rotating turrets")`
- L118: `@export var mobile_turret_start_positions := PackedVector2Array([`
- L121: `@export var mobile_turret_end_positions := PackedVector2Array([`
- L124: `@export_group("Phase 3 - final mixed mechanics")`
- L125: `@export_range(0.1,10,0.1) var mixed_mechanic_interval := 2.5`
- L127: `@export_storage var rotating_turret_spawn_limit := 0`
- L128: `@export_storage var rotating_turret_sequence_offset := 0`
- L129: `@export_group("Development")`
- L130: `@export var test_static_lines_first := false`
- L131: `@export var test_moving_lines_first := false`
- L132: `@export var test_complex_lines_first := false`

### Candidatos / evidencia

- L68, `declaración` (literal adicional (revisión)): `Vector2(0.18,0.23),Vector2(0.52,0.2),Vector2(0.82,0.32),`
- L69, `declaración` (literal adicional (revisión)): `Vector2(0.25,0.76),Vector2(0.62,0.7),Vector2(0.87,0.8),`
- L70, `declaración` (literal adicional (revisión)): `Vector2(0.12,0.55),Vector2(0.45,0.42),Vector2(0.78,0.16),`
- L71, `declaración` (literal adicional (revisión)): `Vector2(0.31,0.15),Vector2(0.6,0.85),Vector2(0.88,0.51)])`
- L93, `declaración` (literal adicional (revisión)): `Vector2.UP,Vector2.DOWN,Vector2(1,-1),Vector2.LEFT,Vector2.RIGHT,`
- L94, `declaración` (literal adicional (revisión)): `Vector2(-1,-1),Vector2.RIGHT,Vector2(1,1),Vector2(-1,1),Vector2.UP])`
- L119, `declaración` (literal adicional (revisión)): `Vector2(0.18,0.25),Vector2(0.82,0.75),Vector2(0.2,0.75),`
- L120, `declaración` (literal adicional (revisión)): `Vector2(0.8,0.25),Vector2(0.5,0.2),Vector2(0.15,0.5)])`
- L122, `declaración` (literal adicional (revisión)): `Vector2(0.82,0.25),Vector2(0.18,0.75),Vector2(0.8,0.25),`
- L123, `declaración` (literal adicional (revisión)): `Vector2(0.2,0.75),Vector2(0.5,0.8),Vector2(0.85,0.5)])`

## resources/bosses/static_line_pattern.gd

5 líneas; 3 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L3: `@export var label := "Fire lines"`
- L4: `@export var horizontal_positions := PackedFloat32Array()`
- L5: `@export var vertical_positions := PackedFloat32Array()`


## resources/character_passives/character_passive.gd

36 líneas; 6 anotaciones export; 0 uniforms; 2 candidatos.

### Ya expuesto en el editor

- L15: `@export var effect: Effect = Effect.STAT_CONVERSION`
- L16: `@export_enum("chili_power", "explosive_damage", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "fire_tick_speed", "crowd_control", "experience_gain", "knockback", "weapon_range", "slow_strength") var target_stat: String = "melee_damage"`
- L17: `@export_enum("chili_power", "explosive_damage", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "fire_tick_speed", "crowd_control", "experience_gain", "knockback", "weapon_range", "slow_strength") var source_stat: String = "speed"`
- L18: `@export var source_amount := 1.0`
- L19: `@export var bonus_amount := 1.0`
- L20: `@export var gain_bonus_percent := 25.0`

### Candidatos / evidencia

- L6, `declaración` (constante): `const STAT_LABELS := {`
- L25, `is_valid` (regla/valor): `return STAT_LABELS.has(target_stat) and STAT_LABELS.has(source_stat) and source_amount > 0.0`

## resources/coop_player_session.gd

37 líneas; 0 anotaciones export; 0 uniforms; 21 candidatos.

Hallazgos: COOP-02.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var slot := 0`
- L4, `declaración` (regla/valor): `var device := -1 # -1 keyboard; >=0 a single joypad, never all devices.`
- L8, `declaración` (regla/valor): `var coins := 25`
- L9, `declaración` (regla/valor): `var reserve := 0`
- L10, `declaración` (texto): `var experience = preload("res://resources/run_experience.gd").new()`
- L11, `declaración` (regla/valor): `var offers: Array[ItemBase] = []`
- L12, `declaración` (regla/valor): `var rewards: Array[ItemPassive] = []`
- L14, `declaración` (regla/valor): `var locked := [false, false, false, false]`
- L16, `declaración` (regla/valor): `var saved_shop_offers: Array[ItemBase] = []`
- L18, `declaración` (regla/valor): `var cursor := 0`
- L19, `declaración` (regla/valor): `var rerolls := 0`
- L20, `declaración` (regla/valor): `var input_vector := Vector2.ZERO`
- L25, `collect` (literal adicional (revisión)): `var bonus := mini(reserve, maxi(0, amount))`
- L27, `collect` (literal adicional (revisión)): `coins += maxi(0, amount) + bonus`
- L28, `collect` (regla/valor): `if is_instance_valid(actor): actor.passive_items.on_yolks_collected(maxi(0, amount)+bonus)`
- L32, `poll_movement` (regla/valor): `if disconnected: return Vector2.ZERO`
- L33, `poll_movement` (regla/valor): `if device < 0:`
- L34, `poll_movement` (regla/valor): `return Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W))).limit_length()`
- L35, `poll_movement` (regla/valor): `var stick := Vector2(Input.get_joy_axis(device,JOY_AXIS_LEFT_X),Input.get_joy_axis(device,JOY_AXIS_LEFT_Y))`
- L36, `poll_movement` (regla/valor): `var pad := Vector2(float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_RIGHT))-float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_LEFT)),float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_DOWN))-float(Input.is_joy_button_pressed(device,JOY_BUTTON_DPAD_UP)))`
- L37, `poll_movement` (regla/valor): `return pad.limit_length() if pad.length_squared()>0 else stick.limit_length() if stick.length()>0.2 else Vector2.ZERO`

## resources/difficulty_rules.gd

23 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

### Candidatos / evidencia

- L4, `declaración` (constante): `const STAT_MULTIPLIERS := [1.0, 1.0, 1.0, 1.12, 1.26, 1.4]`
- L6, `declaración` (constante): `const DENSITY_MULTIPLIERS := [1.0, 1.08, 1.16, 1.16, 1.24, 1.32]`
- L11, `normalize_level` (visual): `return clampi(level, 0, STAT_MULTIPLIERS.size() - 1)`
- L18, `description` (literal adicional (revisión)): `0: return "Base difficulty."`
- L19, `description` (texto): `1: return "Enemies appear 8% more frequently."`
- L20, `description` (texto): `2: return "Enemies appear 16% more frequently."`
- L21, `description` (texto): `3: return "Enemies appear 16% more frequently.\nEnemies have +12% HP and damage."`
- L22, `description` (texto): `4: return "Enemies appear 24% more frequently.\nEnemies have +26% HP and damage."`
- L23, `description` (texto): `_: return "Enemies appear 32% more frequently.\nEnemies have +40% HP and damage."`

## resources/economy_rules.gd

20 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

Hallazgos: ECO-01, ECO-02, ECO-03, ECO-09.

### Candidatos / evidencia

- L3, `declaración` (constante): `const INFLATION_PERCENT_PER_WAVE := 10`
- L4, `declaración` (constante): `const SELL_RATIO := 0.25`
- L5, `declaración` (constante): `const FIRST_SHOP_AFFORDABLE_PRICE := 12`
- L8, `shop_price` (literal adicional (revisión)): `var wave := maxi(1, completed_wave)`
- L11, `shop_price` (literal adicional (revisión)): `var inflation := base_price * INFLATION_PERCENT_PER_WAVE * wave / 100`
- L12, `shop_price` (regla/valor): `return maxi(1, base_price + wave + inflation)`
- L18, `reroll_price` (literal adicional (revisión)): `var wave := maxi(1, completed_wave)`
- L19, `reroll_price` (literal adicional (revisión)): `var increase := maxi(1, floori(wave * 0.4))`
- L20, `reroll_price` (regla/valor): `return floori(wave * 0.75) + increase * (maxi(0, rerolls) + 1)`

## resources/fire_visual_settings.gd

30 líneas; 24 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export_range(1, 20, 1) var flame_count := 12`
- L5: `@export_range(0.0, 1.0, 0.05) var flame_opacity := 0.85`
- L6: `@export_range(0.5, 2.0, 0.05) var coverage := 1.1`
- L7: `@export_range(0.0, 3.0, 0.05) var flicker_speed := 1.0`
- L8: `@export var core_color := Color("ffd16a")`
- L9: `@export_range(0, 32, 1) var ember_count := 16`
- L10: `@export_range(0.002, 0.04, 0.001) var ember_size := 0.008`
- L11: `@export_range(0.0, 1.0, 0.05) var ember_opacity := 0.65`
- L12: `@export_range(0.0, 1.0, 0.01) var heat_opacity := 0.16`
- L13: `@export_range(0.01, 1.0, 0.01) var fade_duration := 0.2`
- L15: `@export_group("Flame sprites")`
- L16: `@export var flame_texture: Texture2D`
- L17: `@export_range(0.0, 1.0, 0.05) var lower_body_fraction := 0.8`
- L19: `@export_range(0.1, 0.8, 0.01) var flame_sprite_height := 0.36`
- L20: `@export_range(0.0, 0.5, 0.01) var size_pulse := 0.22`
- L21: `@export_range(0.1, 3.0, 0.05) var flip_interval_min := 0.35`
- L22: `@export_range(0.1, 3.0, 0.05) var flip_interval_max := 0.9`
- L23: `@export_range(0.0, 0.1, 0.001) var distortion_strength := 0.018`
- L24: `@export_range(1.0, 100.0, 1.0) var distortion_frequency := 38.0`
- L25: `@export_range(0.0, 10.0, 0.1) var distortion_speed := 2.2`
- L27: `@export_group("Background flame")`
- L28: `@export_range(0.0, 1.0, 0.05) var background_flame_opacity := 0.35`
- L29: `@export_range(0.5, 2.0, 0.05) var background_flame_height := 1.3`
- L30: `@export_range(0.5, 2.0, 0.05) var background_flame_width := 1.4`


## resources/items/ayahuasca.gd

45 líneas; 0 anotaciones export; 0 uniforms; 23 candidatos.

Hallazgos: ITEM-06.

### Candidatos / evidencia

- L3, `roll_outcome` (literal adicional (revisión)): `static func roll_outcome(roll: float = -1.0, weights := PackedFloat32Array()) -> int:`
- L4, `roll_outcome` (visual): `if weights.size() != 4: weights = PackedFloat32Array([25, 25, 25, 25])`
- L5, `roll_outcome` (regla/valor): `var total := 0.0`
- L6, `roll_outcome` (literal adicional (revisión)): `for weight in weights: total += maxf(0.0, weight)`
- L7, `roll_outcome` (regla/valor): `if total <= 0.0: return 0`
- L8, `roll_outcome` (regla/valor): `var value := (randf() if roll < 0.0 else clampf(roll, 0.0, 0.999999)) * total`
- L9, `roll_outcome` (literal adicional (revisión)): `for index in 4:`
- L10, `roll_outcome` (literal adicional (revisión)): `value -= maxf(0.0, weights[index])`
- L11, `roll_outcome` (regla/valor): `if value < 0.0: return index`
- L12, `roll_outcome` (regla/valor): `return 3`
- L15, `eligible_primaries` (regla/valor): `var result: Array[String] = []`
- L17, `eligible_primaries` (regla/valor): `if player.stats.primary_display_value(stat_id) > 0.0: result.append(stat_id)`
- L20, `apply` (literal adicional (revisión)): `static func apply(player: Player, item: ItemPassive, test_outcome: int = -1, test_stat: String = "") -> Dictionary:`
- L23, `apply` (regla/valor): `var outcome := roll_outcome(-1.0, item.ayahuasca_outcome_weights) if test_outcome < 0 else test_outcome`
- L24, `apply` (texto): `var result := {"outcome": outcome, "message": ""}`
- L26, `apply` (literal adicional (revisión)): `0, 1:`
- L27, `apply` (literal adicional (revisión)): `result["rewound"] = arena.rewind_upcoming_waves(outcome + 1)`
- L28, `apply` (literal adicional (revisión)): `result.message = "Retrocedés %d oleada(s). Próxima oleada: %d.\nConservás tus armas, ítems, niveles y yemas." % [result.rewound, arena.spawner.wave_index + 1]`
- L29, `apply` (literal adicional (revisión)): `2:`
- L31, `apply` (literal adicional (revisión)): `result.message = "¡Ganaste %d niveles!\nAl continuar elegirás las mejoras antes de la siguiente oleada." % item.ayahuasca_levels`
- L32, `apply` (literal adicional (revisión)): `3:`
- L35, `apply` (literal adicional (revisión)): `result.message = "No tenés estadísticas primarias positivas para reducir."`
- L44, `apply` (literal adicional (revisión)): `result.message = "%s se redujo a la mitad: %s → %s." % [stat_id.replace("_", " ").capitalize(), ItemWeapon.format_number(before), ItemWeapon.format_number(result.after)]`

## resources/items/breading.gd

76 líneas; 0 anotaciones export; 0 uniforms; 5 candidatos.

Hallazgos: ITEM-08.

### Candidatos / evidencia

- L4, `available_tags` (regla/valor): `var result: Array[int] = []`
- L15, `add_tag` (texto): `if config == null: config = load("res://resources/items/passives/catalogue/item_081.tres")`
- L45, `add_tag` (texto): `var status := StatusEffect.new() if tag == ItemWeapon.Tag.PYRO else load("res://resources/statuses/electricity_default.tres").duplicate() as StatusEffect`
- L59, `inherit_tags` (texto): `var key := "melee_damage" if tag == ItemWeapon.Tag.MELEE else "ranged_damage"`
- L60, `inherit_tags` (literal adicional (revisión)): `result.extra_damage_scalings[key] = maxf(result.extra_damage_scalings.get(key, 0.0), donor.extra_damage_scalings.get(key, 0.0))`

## resources/items/golden_enhancement.gd

88 líneas; 0 anotaciones export; 0 uniforms; 34 candidatos.

Hallazgos: ITEM-05.

### Candidatos / evidencia

- L3, `declaración` (constante): `const BOOST_FIELDS := ["last_bite_push_percent", "last_bite_dash_reduction", "mushroom_explosion_radius", "mushroom_effects_scaling", "mushroom_health_scaling", "mushroom_damage_bonus", "mushroom_speed_percent", "mushroom_attack_speed_bonus", "mushroom_buff_duration", "mushroom_heal_health", "damage", "damage_scaling", "effects_damage_scaling", "crit_chance", "crit_damage", "max_range", "knockback", "slow_duration", "piercing", "bounces", "life_steal", "projectile_speed", "proc_chance", "effect_radius", "heal_amount", "fire_interval_reduction", "controlled_damage_percent", "flambe_damage_per_enemy", "airbourne_collision_damage_percent", "airbourne_explosion_damage_percent", "burning_regen_bonus", "regen_per_level", "electric_slow_strength", "electric_slow_duration", "projectile_count", "burst_count", "airbourne_speed", "airbourne_duration", "explosion_radius", "harpoon_pin_duration", "harpoon_capture_radius", "landing_slow_radius", "landing_slow_duration", "corn_explosion_chance", "popcorn_speed", "popcorn_range", "bonus_yolks", "pit_projectile_speed", "pit_range_multiplier", "pit_radius", "splatter_count", "splatter_speed", "splatter_range_multiplier", "stream_width", "hit_count", "launch_speed", "launch_duration", "capture_radius", "slow_radius", "close_hit_radius", "count", "radius", "lifetime", "movement_speed", "orbit_speed", "trigger_radius", "maximum_active", "column_trail_lifetime", "explosion_count", "burn_duration", "chance", "duration", "chain_radius", "maximum_chain_targets"]`
- L4, `declaración` (constante): `const NESTED_FIELDS := ["ranged_settings", "melee_settings", "spicy_pattern", "spicy_explosion_settings"]`
- L5, `declaración` (constante): `const CHANCES := ["crit_chance", "life_steal", "proc_chance", "electric_slow_strength", "corn_explosion_chance", "chance"]`
- L7, `roll_outcome` (literal adicional (revisión)): `static func roll_outcome(roll: float = -1.0, weights := PackedFloat32Array()) -> float:`
- L8, `roll_outcome` (regla/valor): `var outcomes := [-1.0, 0.10, 0.25, 0.50, 1.0]`
- L9, `roll_outcome` (visual): `if weights.size() != 5: weights = PackedFloat32Array([25, 40, 23, 10, 2])`
- L10, `roll_outcome` (regla/valor): `var total := 0.0`
- L11, `roll_outcome` (literal adicional (revisión)): `for weight in weights: total += maxf(0.0, weight)`
- L12, `roll_outcome` (regla/valor): `if total <= 0.0: return -1.0`
- L13, `roll_outcome` (regla/valor): `var value := (randf() if roll < 0.0 else clampf(roll, 0.0, 0.999999)) * total`
- L15, `roll_outcome` (literal adicional (revisión)): `value -= maxf(0.0, weights[index])`
- L16, `roll_outcome` (regla/valor): `if value < 0.0: return outcomes[index]`
- L17, `roll_outcome` (regla/valor): `return 1.0`
- L19, `improve` (literal adicional (revisión)): `static func improve(item: ItemBase, bonus: float, penalty_override: float = -1.0) -> ItemBase:`
- L21, `improve` (regla/valor): `var factor := 1.0 + bonus`
- L22, `improve` (regla/valor): `var penalty := maxf(0.0, 1.0 - bonus) if penalty_override < 0.0 else penalty_override`
- L25, `improve` (literal adicional (revisión)): `improved.golden_perfect = item.golden_perfect or bonus >= 1.0`
- L33, `improve` (literal adicional (revisión)): `improved.breading_slow_strength = minf(1.0, item.breading_slow_strength * factor)`
- L35, `improve` (regla/valor): `var breaded_statuses: Array[StatusEffect] = []`
- L43, `improve` (literal adicional (revisión)): `improved.stats.cooldown = maxf(0.05, item.stats.cooldown / factor)`
- L49, `improve` (regla/valor): `improved.final_stat_modifiers[key] = amount * (factor if amount > 0.0 else penalty)`
- L52, `improve` (literal adicional (revisión)): `for index in range(1, ItemPassive.STAT_SLOT_COUNT + 1):`
- L53, `improve` (texto): `var field := "add_value" + ("" if index == 1 else "_%d" % index)`
- L55, `improve` (regla/valor): `improved.set(field, value * (factor if value >= 0.0 else penalty))`
- L59, `improve` (literal adicional (revisión)): `improved.two_for_one_chance = minf(1.0, item.two_for_one_chance * factor)`
- L60, `improve` (literal adicional (revisión)): `improved.minimum_discount_percent = mini(90, floori(item.minimum_discount_percent * factor))`
- L61, `improve` (literal adicional (revisión)): `improved.maximum_discount_percent = mini(90, floori(item.maximum_discount_percent * factor))`
- L62, `improve` (regla/valor): `var statuses: Array[StatusEffect] = []`
- L81, `_scale_magnitudes` (visual): `if key in CHANCES: scaled = minf(1.0, scaled)`
- L82, `_scale_magnitudes` (literal adicional (revisión)): `resource.set(key, floori(scaled + 0.00001) if value is int else scaled)`
- L83, `_scale_magnitudes` (literal adicional (revisión)): `elif key == "landing_slow_factor" or key == "slow_factor":`
- L84, `_scale_magnitudes` (literal adicional (revisión)): `resource.set(key, maxf(0.0, 1.0 - (1.0 - float(value)) * factor))`
- L86, `_scale_magnitudes` (literal adicional (revisión)): `resource.set(key, 1.0 - (1.0 - float(value)) * penalty)`
- L87, `_scale_magnitudes` (literal adicional (revisión)): `elif key == "plate_break_chance":`

## resources/items/item_base.gd

47 líneas; 6 anotaciones export; 0 uniforms; 6 candidatos.

### Ya expuesto en el editor

- L12: `@export var item_name: String`
- L13: `@export var item_icon: Texture2D`
- L15: `@export_range(0.25, 2.0, 0.05) var icon_scale := 1.0`
- L16: `@export var item_tier: Global.UpgradeTier`
- L17: `@export var item_type: ItemType`
- L18: `@export var item_cost: int`

### Candidatos / evidencia

- L4, `declaración` (constante): `const ECONOMY_RULES = preload("res://resources/economy_rules.gd")`
- L20, `declaración` (regla/valor): `var golden_multiplier := 1.0`
- L21, `declaración` (regla/valor): `var golden_penalty_multiplier := 1.0`
- L37, `scale_icon` (literal adicional (revisión)): `target.set_meta("item_icon_scale", clampf(factor, 0.25, 2.0))`
- L46, `_refresh_icon_scale` (literal adicional (revisión)): `target.pivot_offset = target.size * 0.5`
- L47, `_refresh_icon_scale` (texto): `target.scale = Vector2.ONE * float(target.get_meta("item_icon_scale", 1.0))`

## resources/items/passives/catalogue.gd

12 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

Hallazgos: BASE-07.

### Candidatos / evidencia

- L4, `declaración` (constante): `const ACTIVE_IDS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 34, 40, 42, 44, 45, 46, 47, 56, 57, 58, 60, 61, 62, 63, 64, 65, 66, 67, 69, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 96, 97, 98, 99, 100]`
- L5, `declaración` (regla/valor): `static var _cached: Array[ItemPassive] = []`
- L10, `items` (texto): `var item = load("res://resources/items/passives/catalogue/item_%03d.tres" % id)`

## resources/items/passives/catalogue_passive.gd

104 líneas; 58 anotaciones export; 0 uniforms; 13 candidatos.

### Ya expuesto en el editor

- L3: `@export var catalogue_id := 0`
- L4: `@export_multiline var description := ""`
- L5: `@export var effect_key := ""`
- L6: `@export var ready_for_shop := false`
- L7: `@export_multiline var pending_reason := ""`
- L8: `@export_range(0.0, 1.0, 0.001) var proc_chance := 0.0`
- L9: `@export_range(0.0, 1000.0, 1.0) var effect_radius := 80.0`
- L10: `@export_range(0.0, 100.0, 0.01) var heal_amount := 0.1`
- L12: `@export_range(0, 99, 1) var max_copies := 0`
- L13: `@export_range(0.0, 1.0, 0.01) var fire_interval_reduction := 0.0`
- L14: `@export_range(0.0, 10.0, 0.01) var fire_duration_reduction := 0.0`
- L15: `@export_range(0.0, 1000.0, 1.0) var controlled_damage_percent := 0.0`
- L16: `@export_range(0.0, 1000.0, 1.0) var airbourne_collision_damage_percent := 0.0`
- L17: `@export_range(0.0, 1000.0, 1.0) var airbourne_explosion_damage_percent := 0.0`
- L18: `@export_range(0.0, 100.0, 0.1) var burning_regen_bonus := 0.0`
- L19: `@export_range(0.0, 100.0, 0.1) var regen_per_level := 0.0`
- L20: `@export_range(0.0, 1.0, 0.01) var electric_slow_strength := 0.0`
- L21: `@export_range(0.0, 30.0, 0.1) var electric_slow_duration := 0.0`
- L22: `@export_range(0, 90, 1) var minimum_discount_percent := 10`
- L23: `@export_range(0, 90, 1) var maximum_discount_percent := 90`
- L24: `@export_range(0.0, 1.0, 0.0001) var two_for_one_chance := 0.02`
- L26: `@export var discount_band_weights := PackedFloat32Array([50.0, 28.0, 14.0, 6.0])`
- L28: `@export var golden_outcome_weights := PackedFloat32Array([25.0, 40.0, 23.0, 10.0, 2.0])`
- L29: `@export var flambe_damage_per_enemy := 10.0`
- L30: `@export var ayahuasca_outcome_weights := PackedFloat32Array([25.0, 25.0, 25.0, 25.0])`
- L31: `@export_range(1, 100, 1) var ayahuasca_levels := 10`
- L32: `@export_group("Hongo desconocido")`
- L33: `@export var mushroom_interval := 5.0`
- L34: `@export var mushroom_explosion_radius := 220.0`
- L35: `@export var mushroom_effects_scaling := 1.0`
- L36: `@export var mushroom_health_scaling := 0.1`
- L37: `@export var mushroom_damage_bonus := 100.0`
- L38: `@export var mushroom_speed_percent := 50.0`
- L39: `@export var mushroom_attack_speed_bonus := 100.0`
- L40: `@export var mushroom_buff_duration := 4.0`
- L41: `@export var mushroom_health_loss := 0.5`
- L42: `@export var mushroom_burn_duration := 4.0`
- L43: `@export var mushroom_burn_tick_health := 0.01`
- L44: `@export var mushroom_shock_health := 0.05`
- L45: `@export var mushroom_heal_health := 0.1`
- L46: `@export_group("Último bocado")`
- L47: `@export var last_bite_health_threshold := 0.25`
- L48: `@export var last_bite_push_percent := 50.0`
- L49: `@export var last_bite_dash_reduction := 0.5`
- L50: `@export_group("Giro de tortilla")`
- L51: `@export_range(0.0, 1.0, 0.01) var relaunch_speed_multiplier := 0.75`
- L52: `@export_range(0.0, 1.0, 0.01) var relaunch_duration_multiplier := 0.5`
- L53: `@export_range(0, 20, 1) var relaunch_maximum := 2`
- L54: `@export_group("Rebozado")`
- L55: `@export var breading_extra_scaling := 0.25`
- L56: `@export var breading_chili_damage_percent := 10.0`
- L57: `@export var breading_pet_damage_percent := 10.0`
- L58: `@export_range(0.0, 1.0, 0.01) var breading_proc_chance := 0.1`
- L59: `@export var breading_explosion_radius := 40.0`
- L60: `@export var breading_explosion_damage_ratio := 0.25`
- L61: `@export_range(0.0, 1.0, 0.01) var breading_slow_strength := 0.2`
- L62: `@export var breading_slow_duration := 1.0`
- L63: `@export_group("")`

### Candidatos / evidencia

- L66, `get_shop_price` (texto): `return 1 if effect_key == "chocolate_coin" else super.get_shop_price(completed_wave)`
- L77, `apply_passive_values` (literal adicional (revisión)): `if effect_key == "alcohol":`
- L83, `available_for` (regla/valor): `if max_copies > 0 and is_instance_valid(player.passive_items) and player.passive_items.count(effect_key) >= max_copies: return false`
- L84, `available_for` (texto): `return ready_for_shop and (effect_key != "extra_slot" or player.passive_items.count("extra_slot") < 3)`
- L87, `roll_sale_discount` (literal adicional (revisión)): `var minimum := clampi(minimum_discount_percent, 1, 90)`
- L88, `roll_sale_discount` (literal adicional (revisión)): `var maximum := clampi(maximum_discount_percent, minimum, 90)`
- L89, `roll_sale_discount` (regla/valor): `var ranges := [Vector2i(10, 30), Vector2i(31, 50), Vector2i(51, 70), Vector2i(71, 90)]`
- L90, `roll_sale_discount` (regla/valor): `var total := 0.0`
- L93, `roll_sale_discount` (visual): `if index < discount_band_weights.size(): total += maxf(0.0, discount_band_weights[index])`
- L94, `roll_sale_discount` (regla/valor): `if total <= 0: return randi_range(minimum, maximum)`
- L100, `roll_sale_discount` (literal adicional (revisión)): `var weight := maxf(0.0, discount_band_weights[index])`
- L101, `roll_sale_discount` (regla/valor): `if weight <= 0: continue`
- L103, `roll_sale_discount` (regla/valor): `if roll <= 0: return randi_range(low, high)`

## resources/items/passives/item_passive.gd

64 líneas; 23 anotaciones export; 0 uniforms; 9 candidatos.

### Ya expuesto en el editor

- L6: `@export_group("Stat 1")`
- L7: `@export var add_value: float = 0.0`
- L8: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id: String = "none"`
- L9: `@export_group("Stat 2")`
- L10: `@export var add_value_2: float = 0.0`
- L11: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_2: String = "none"`
- L12: `@export_group("Stat 3")`
- L13: `@export var add_value_3: float = 0.0`
- L14: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_3: String = "none"`
- L15: `@export_group("Stat 4")`
- L16: `@export var add_value_4: float = 0.0`
- L17: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_4: String = "none"`
- L18: `@export_group("Stat 5")`
- L19: `@export var add_value_5: float = 0.0`
- L20: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_5: String = "none"`
- L21: `@export_group("Stat 6")`
- L22: `@export var add_value_6: float = 0.0`
- L23: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_6: String = "none"`
- L24: `@export_group("Stat 7")`
- L25: `@export var add_value_7: float = 0.0`
- L26: `@export_enum("none", "health", "damage_percent", "melee_damage", "ranged_damage", "attack_speed", "speed", "luck", "block_chance", "hp_regen", "life_steal", "harvesting", "armor", "critical_chance", "pickup_range", "piercing", "bounces", "area_of_effect", "critical_multiplier", "block_effectiveness", "effects", "chili_power", "explosive_damage", "fire_tick_speed", "experience_gain", "slow_strength", "weapon_range", "knockback", "crowd_control") var add_stats_id_7: String = "none"`
- L27: `@export_group("On hit")`
- L28: `@export var on_hit_effects: Array[StatusEffect] = []`

### Candidatos / evidencia

- L4, `declaración` (constante): `const STAT_SLOT_COUNT := 7`
- L31, `get_stat_changes` (regla/valor): `var changes: Array[Dictionary] = []`
- L32, `get_stat_changes` (literal adicional (revisión)): `for index in range(1, STAT_SLOT_COUNT + 1):`
- L33, `get_stat_changes` (regla/valor): `var suffix := "" if index == 1 else "_%d" % index`
- L36, `get_stat_changes` (regla/valor): `if value != 0.0 and CharacterPassive.STAT_LABELS.has(stat_id):`
- L41, `get_description` (regla/valor): `var lines: PackedStringArray = []`
- L43, `get_description` (literal adicional (revisión)): `var positive: bool = change.value > 0.0`
- L45, `get_description` (regla/valor): `var description := "[code]" + "\n".join(lines) + "[/code]"`
- L47, `get_description` (literal adicional (revisión)): `description += "\nOn hit: %s" % ("Fire" if effect.kind == StatusEffect.Kind.FIRE else "Electricity")`

## resources/items/unknown_mushroom.gd

104 líneas; 0 anotaciones export; 0 uniforms; 43 candidatos.

Hallazgos: ITEM-07.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L5, `declaración` (regla/valor): `var next_activation := 5.0`
- L6, `declaración` (regla/valor): `var buffs: Dictionary = {}`
- L7, `declaración` (regla/valor): `var activation_count := 0`
- L11, `configuration` (literal adicional (revisión)): `if record.item.effect_key == "unknown_mushroom": return record.item`
- L15, `reset` (literal adicional (revisión)): `for stat_id in buffs: manager.player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)`
- L17, `reset` (literal adicional (revisión)): `elapsed = 0.0`
- L18, `reset` (literal adicional (revisión)): `activation_count = 0`
- L20, `reset` (regla/valor): `next_activation = maxf(0.1, item.mushroom_interval) if item else 5.0`
- L25, `_process` (regla/valor): `if manager.player.health_component.current_health <= 0.0: return`
- L36, `advance` (literal adicional (revisión)): `_age_buffs(maxf(0.0, next_activation - elapsed))`
- L39, `advance` (literal adicional (revisión)): `next_activation += maxf(0.1, item.mushroom_interval)`
- L40, `advance` (literal adicional (revisión)): `_age_buffs(maxf(0.0, destination - elapsed))`
- L46, `_age_buffs` (regla/valor): `if buffs[stat_id] <= 0.00001:`
- L47, `_age_buffs` (literal adicional (revisión)): `manager.player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)`
- L50, `trigger` (literal adicional (revisión)): `func trigger(item: ItemPassive, outcome: int = -1) -> int:`
- L51, `trigger` (regla/valor): `if outcome < 0: outcome = randi_range(0, 8)`
- L54, `trigger` (regla/valor): `if health.current_health <= 0.0: return -1`
- L55, `trigger` (regla/valor): `activation_count += 1`
- L57, `trigger` (literal adicional (revisión)): `0:`
- L59, `trigger` (literal adicional (revisión)): `template.setup(maxf(0.0, player.stats.effects * item.mushroom_effects_scaling + health.max_health * item.mushroom_health_scaling), false, 0.0, player)`
- L67, `trigger` (literal adicional (revisión)): `settings.explosion_damage_multiplier = 1.0`
- L68, `trigger` (literal adicional (revisión)): `settings.explosion_visual_duration = 0.22`
- L70, `trigger` (texto): `var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()`
- L75, `trigger` (literal adicional (revisión)): `1, 2, 3:`
- L76, `trigger` (texto): `var stat_id: String = ["damage_percent", "speed", "attack_speed"][outcome - 1]`
- L78, `trigger` (literal adicional (revisión)): `player.stats.set_temporary_stat_bonus("mushroom_" + stat_id, stat_id, 0.0)`
- L79, `trigger` (regla/valor): `var bonus: float = item.mushroom_damage_bonus if outcome == 1 else item.mushroom_attack_speed_bonus`
- L80, `trigger` (texto): `if outcome == 2: bonus = maxf(0.0, player.stats.unmodified_stat("speed")) * item.mushroom_speed_percent / 100.0`
- L83, `trigger` (literal adicional (revisión)): `4:`
- L84, `trigger` (literal adicional (revisión)): `health.take_damage(health.current_health * clampf(item.mushroom_health_loss * item.golden_penalty_multiplier, 0.0, 0.999999))`
- L85, `trigger` (literal adicional (revisión)): `5, 6:`
- L88, `trigger` (literal adicional (revisión)): `template.setup(0.0, false, 0.0, null)`
- L90, `trigger` (regla/valor): `status.kind = StatusEffect.Kind.FIRE if outcome == 5 else StatusEffect.Kind.ELECTRICITY`
- L91, `trigger` (regla/valor): `status.duration = (item.mushroom_burn_duration if outcome == 5 else 1.0) * item.golden_penalty_multiplier`
- L92, `trigger` (regla/valor): `status.damage = health.max_health * (item.mushroom_burn_tick_health if outcome == 5 else item.mushroom_shock_health) * item.golden_penalty_multiplier`
- L93, `trigger` (literal adicional (revisión)): `status.chain_radius = 0.0`
- L94, `trigger` (literal adicional (revisión)): `status.maximum_chain_targets = 0`
- L95, `trigger` (texto): `status.color = Color("ff7235") if outcome == 5 else Color("63dcff")`
- L97, `trigger` (regla/valor): `if status.duration > 0.0:`
- L98, `trigger` (texto): `load("res://effects/status_controller.gd").apply_effect(player, status, template, false)`
- L100, `trigger` (literal adicional (revisión)): `7, 8:`
- L102, `trigger` (regla/valor): `health.heal(health.max_health * item.mushroom_heal_health if outcome == 7 else health.max_health)`

## resources/items/upgrades/item_upgrades.gd

12 líneas; 3 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export var value: float`
- L5: `@export var description: String`
- L6: `@export var stat_id: String`


## resources/items/weapons/item_weapon.gd

201 líneas; 24 anotaciones export; 0 uniforms; 49 candidatos.

Hallazgos: COM-08, COM-09, ARM-04.

### Ya expuesto en el editor

- L12: `@export var tags: Array[Tag] = []`
- L14: `@export var breading_tags: Array[Tag] = []`
- L15: `@export var extra_damage_scalings: Dictionary = {}`
- L16: `@export var breading_chili_damage_percent := 0.0`
- L17: `@export var breading_pet_damage_percent := 0.0`
- L18: `@export var breading_explosion_radius := 0.0`
- L19: `@export var breading_explosion_damage_ratio := 0.0`
- L20: `@export var breading_slow_strength := 0.0`
- L21: `@export var breading_slow_duration := 0.0`
- L22: `@export var breading_status_effects: Array[StatusEffect] = []`
- L23: `@export var scales_with_effects := false`
- L25: `@export var effects_damage_scaling := 1.0`
- L29: `@export var damage_scaling_stat := DamageScalingStat.AUTO`
- L31: `@export var unlock_id: String`
- L32: `@export var selection_only := false`
- L34: `@export_storage var type: Type`
- L35: `@export var scene: PackedScene`
- L36: `@export var stats: WeaponStats`
- L37: `@export var upgrade_to: ItemWeapon`
- L38: `@export_multiline var attack_description: String`
- L40: `@export var final_stat_modifiers: Dictionary = {}`
- L41: `@export var health_drain_per_second := 0.0`
- L42: `@export var max_health_drain_percent_per_second := 0.0`
- L43: `@export var on_hit_effects: Array[StatusEffect] = []`

### Candidatos / evidencia

- L11, `declaración` (constante): `const TAG_LABELS := ["Melee", "Ranged", "Explosive", "Pyro", "Electric", "Chili", "Control", "Pet"]`
- L72, `get_effective_damage` (literal adicional (revisión)): `if scales_with_effects and stat_id != "effects": flat += player_stats.effects * effects_damage_scaling`
- L74, `get_effective_damage` (regla/valor): `var percent := player_stats.get_damage_percent_multiplier(has_tag(Tag.CHILI), force_explosive or has_tag(Tag.EXPLOSIVE)) if player_stats else 1.0`
- L75, `get_effective_damage` (regla/valor): `return maxf(1.0, flat * percent) * (get_breading_tag_multiplier() if player_stats else 1.0)`
- L80, `explosion_damage_ratio` (regla/valor): `var ratio := 0.0`
- L85, `explosion_damage_ratio` (regla/valor): `return item.get_effective_damage(player_stats, true) / maxf(0.00001, item.get_effective_damage(player_stats))`
- L86, `explosion_damage_ratio` (regla/valor): `return player_stats.get_damage_percent_multiplier(false, true) / maxf(0.00001, player_stats.get_damage_percent_multiplier())`
- L90, `status_damage_multiplier` (regla/valor): `var multiplier := 0.0`
- L98, `get_effective_critical_multiplier` (texto): `return maxf(1.0, stats.crit_damage * maxf(0.0, 1.0 + player_stats.unmodified_stat("critical_multiplier") / 100.0)) * player_stats.final_multiplier("critical_multiplier")`
- L101, `get_effective_cooldown` (regla/valor): `var bonus := player_stats.attack_speed if player_stats else 0.0`
- L102, `get_effective_cooldown` (regla/valor): `var duration := stats.cooldown / (1.0 + bonus / 100.0) if bonus >= 0.0 else stats.cooldown * (1.0 + absf(bonus) / 100.0)`
- L103, `get_effective_cooldown` (regla/valor): `return maxf(0.05, duration)`
- L106, `get_effective_critical_chance` (regla/valor): `if has_tag(Tag.CHILI) and (player_stats == null or not player_stats.chili_crit_enabled): return 0.0`
- L107, `get_effective_critical_chance` (texto): `return clampf((stats.crit_chance + (player_stats.unmodified_stat("critical_chance") / 100.0 if player_stats else 0.0)) * (player_stats.final_multiplier("critical_chance") if player_stats else 1.0), 0.0, 1.0)`
- L118, `get_effective_life_steal` (regla/valor): `return maxf(0.0, stats.life_steal + (player_stats.life_steal / 100.0 if player_stats else 0.0))`
- L121, `format_number` (regla/valor): `return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")`
- L124, `get_effective_range` (regla/valor): `return maxf(1.0, stats.max_range + (player_stats.weapon_range if player_stats else 0.0))`
- L133, `get_damage_description` (texto): `var icon := "damage_melee" if stat_id == "melee_damage" else "damage_ranged"`
- L134, `get_damage_description` (texto): `if stat_id == "effects": components.append("%s%% Effects" % format_number(stats.damage_scaling * 100.0))`
- L135, `get_damage_description` (literal adicional (revisión)): `else: components.append("%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img]" % [format_number(stats.damage_scaling * 100.0), icon])`
- L136, `get_damage_description` (texto): `if scales_with_effects and stat_id != "effects": components.append("%s%% Effects" % format_number(effects_damage_scaling * 100.0))`
- L138, `get_damage_description` (texto): `var icon := "damage_melee" if key == "melee_damage" else "damage_ranged"`
- L139, `get_damage_description` (literal adicional (revisión)): `components.append("%s%% [img width=22 height=22 color=green]res://assets/sprites/UI/%s.svg[/img]" % [format_number(float(extra_damage_scalings[key]) * 100.0), icon])`
- L144, `get_description` (texto): `var description := "Damage: [color=green]%s[/color]\nCooldown: [color=green]%s s[/color]\nRange: [color=green]%s[/color]\nCritical chance: [color=green]%s%%[/color]" % [get_damage_description(player_stats), format_number(get_effective_cooldown(player_stats)), get_range_description(player_stats), format_number(get_effective_critical_chance(player_stats) * 100.0)]`
- L146, `get_description` (literal adicional (revisión)): `if stats.unlimited_piercing: description += "\nPiercing: [color=green]Unlimited[/color]"`
- L147, `get_description` (regla/valor): `elif get_effective_piercing(player_stats) > 0: description += "\nPiercing: [color=green]%d[/color]" % get_effective_piercing(player_stats)`
- L148, `get_description` (regla/valor): `if get_effective_bounces(player_stats) > 0: description += "\nBounces: [color=green]%d[/color]" % get_effective_bounces(player_stats)`
- L150, `get_description` (regla/valor): `if breading_chili_damage_percent > 0.0: description += "\n+%s%% damage per equipped Chili (includes self)" % format_number(breading_chili_damage_percent)`
- L151, `get_description` (regla/valor): `if breading_pet_damage_percent > 0.0: description += "\n+%s%% damage per equipped Pet (includes self)" % format_number(breading_pet_damage_percent)`
- L152, `get_description` (literal adicional (revisión)): `if not attack_description.is_empty(): description += "\n" + attack_description`
- L154, `get_description` (regla/valor): `description += "\n%s: %s%s%% final" % [str(stat_id).replace("_", " ").capitalize(), "+" if float(final_stat_modifiers[stat_id]) > 0.0 else "", format_number(final_stat_modifiers[stat_id])]`
- L155, `get_description` (regla/valor): `if health_drain_per_second > 0.0: description += "\nHealth cost: %s HP/s" % format_number(health_drain_per_second)`
- L156, `get_description` (regla/valor): `if max_health_drain_percent_per_second > 0.0: description += "\nHealth cost: %s%% max HP/s" % format_number(max_health_drain_percent_per_second)`
- L160, `get_effective_piercing` (regla/valor): `return maxi(0, stats.piercing + (player_stats.piercing if player_stats else 0))`
- L163, `get_effective_bounces` (regla/valor): `if stats.unlimited_piercing: return 0`
- L164, `get_effective_bounces` (regla/valor): `return maxi(0, stats.bounces + (player_stats.bounces if player_stats else 0))`
- L170, `get_breading_tag_multiplier` (regla/valor): `if breading_chili_damage_percent == 0.0 and breading_pet_damage_percent == 0.0: return 1.0`
- L171, `get_breading_tag_multiplier` (regla/valor): `if not is_instance_valid(Global.player): return 1.0`
- L172, `get_breading_tag_multiplier` (regla/valor): `var bonus := 0.0`
- L177, `get_breading_tag_multiplier` (regla/valor): `return 1.0 + bonus / 100.0`
- L180, `get_breading_burning_damage` (regla/valor): `var extra := 0.0`
- L182, `get_breading_burning_damage` (regla/valor): `return maxf(0.1, base_damage + extra) * get_breading_tag_multiplier()`
- L186, `get_status_damage_description` (regla/valor): `var result := ""`
- L191, `get_status_damage_description` (regla/valor): `if effect.kind == StatusEffect.Kind.FIRE: amount = maxf(0.1, amount)`
- L193, `get_status_damage_description` (regla/valor): `var formula := "%s + %s%% Effects" % [format_number(effect.damage), format_number(effect.damage_scaling * 100.0)]`
- L194, `get_status_damage_description` (texto): `var label := "Burning / tick" if effect.kind == StatusEffect.Kind.FIRE else "Electricity"`
- L195, `get_status_damage_description` (literal adicional (revisión)): `result += "\n%s: [color=green]%s[/color] (%s)" % [label, format_number(amount), formula]`
- L199, `get_status_damage_description` (literal adicional (revisión)): `result += " — every %s s, for %s s" % [format_number(interval), format_number(duration)]`
- L200, `get_status_damage_description` (regla/valor): `if effect.chance < 1.0: result += " — %s%% chance" % format_number(effect.chance * 100.0)`

## resources/items/weapons/melee_catalogue.gd

7 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L4, `items` (regla/valor): `var result: Array[ItemWeapon] = []`
- L5, `items` (regla/valor): `for tier in range(1,5 if all_tiers else 2):`
- L6, `items` (texto): `result.append(load("res://resources/items/weapons/melee/spark_lighter/item_spark_lighter_%d.tres" % tier))`

## resources/items/weapons/melee_settings.gd

67 líneas; 63 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L5: `@export_group("Animation")`
- L6: `@export_range(0.01, 5.0, 0.01) var animation_speed := 1.0`
- L7: `@export_range(0.01, 10.0, 0.01) var timing_reference := 0.95`
- L8: `@export_range(0.0, 10.0, 0.005) var preparation_duration := 0.1`
- L9: `@export_range(0.001, 10.0, 0.005) var forward_duration := 0.2`
- L10: `@export_range(0.001, 10.0, 0.005) var return_duration := 0.1`
- L11: `@export_range(0.0, 10.0, 0.005) var contact_duration := 0.045`
- L12: `@export_range(0.0, 10.0, 0.005) var pause_duration := 0.1`
- L13: `@export_group("Motion")`
- L14: `@export var reach_multiplier := 1.0`
- L15: `@export var windup_offset := -12.0`
- L16: `@export var raised_angle := 0.0`
- L17: `@export var sweep_start_angle := -90.0`
- L18: `@export var sweep_end_angle := 90.0`
- L19: `@export var semicircle_radius_multiplier := 0.75`
- L20: `@export var fallback_angle := 60.0`
- L21: `@export var cutter_return_angle := 12.0`
- L22: `@export var repeated_retract_multiplier := 0.7`
- L23: `@export var lateral_offset := 12.0`
- L24: `@export var scrape_start := Vector2(20,-18)`
- L25: `@export var scrape_end := Vector2(-15,18)`
- L26: `@export var scrape_rotation := 0.12`
- L27: `@export var blend_rotation := 0.22`
- L28: `@export var blend_offset := 6.0`
- L29: `@export_group("Repeated hits")`
- L30: `@export_range(1, 30, 1) var hit_count := 1`
- L31: `@export_group("Glove")`
- L32: `@export_range(0.0, 5.0, 0.01) var direct_damage_multiplier := 0.15`
- L33: `@export_range(0.0, 10.0, 0.05) var collision_damage_multiplier := 1.0`
- L34: `@export var launch_speed := 520.0`
- L35: `@export_range(0.01, 10.0, 0.01) var launch_duration := 0.45`
- L36: `@export_group("Hammer")`
- L37: `@export var early_damage_multiplier := 0.35`
- L38: `@export var final_damage_multiplier := 1.75`
- L39: `@export var early_knockback := 2.2`
- L40: `@export var final_knockback := 0.0`
- L41: `@export_group("Grater")`
- L42: `@export var capture_radius := 70.0`
- L43: `@export_group("Pan")`
- L44: `@export var slow_radius := 120.0`
- L45: `@export_range(0.0, 1.0, 0.01) var slow_factor := 0.5`
- L46: `@export var close_hit_radius := 35.0`
- L47: `@export_group("Pan visual effect")`
- L48: `@export_range(0.01, 5.0, 0.005) var effect_duration := 0.125`
- L49: `@export_range(0.0, 1.0, 0.01) var effect_opacity := 0.3`
- L50: `@export_range(0.1, 1.0, 0.01) var effect_y_ratio := 0.55`
- L51: `@export var effect_color := Color("86a9be")`
- L52: `@export var ring_width := 2.0`
- L53: `@export var spark_width := 1.5`
- L54: `@export var spark_length := 10.0`
- L55: `@export_range(0, 64, 1) var spark_count := 16`
- L56: `@export var ring_start_radius := 0.3`
- L57: `@export var spark_start_radius := 0.45`
- L58: `@export var status_text := "Slowed"`
- L59: `@export_range(0.0, 10.0, 0.05) var status_text_duration := 1.3`
- L60: `@export var status_text_color := Color("86a9be")`
- L61: `@export_group("Rotating blade visual")`
- L62: `@export var rotor_speed := 12.0`
- L63: `@export var rotor_radius := 23.0`
- L64: `@export var rotor_center := Vector2(52,0)`
- L65: `@export var rotor_arc := 1.2`
- L66: `@export var rotor_width := 1.5`
- L67: `@export var rotor_color := Color(0.25,0.25,0.22,0.65)`


## resources/items/weapons/pet_catalogue.gd

4 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L4, `items` (texto): `return [load("res://resources/items/weapons/pets/item_sausage_dog.tres"), load("res://resources/items/weapons/pets/item_toaster_cat.tres")]`

## resources/items/weapons/ranged_catalogue.gd

11 líneas; 0 anotaciones export; 0 uniforms; 4 candidatos.

Hallazgos: BASE-08.

### Candidatos / evidencia

- L4, `declaración` (constante): `const IDS := ["bomb_corn", "toothpick_shotgun", "pressure_cooker", "meatball_machinegun", "pepper_bazooka", "anchovy_doublebarrel", "baguette_harpoon", "plate_launcher", "olive_launcher", "fusilli_launcher", "kitchen_torch"]`
- L7, `items` (regla/valor): `var result: Array[ItemWeapon] = []`
- L9, `items` (regla/valor): `for tier in range(1, 5 if all_tiers else 2):`
- L10, `items` (texto): `result.append(load("res://resources/items/weapons/range/%s/item_%s_%d.tres" % [id, id, tier]))`

## resources/items/weapons/ranged_settings.gd

90 líneas; 84 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export_range(1, 16, 1) var projectile_count := 1`
- L5: `@export_range(0.0, 180.0, 1.0) var spread_degrees := 0.0`
- L6: `@export_range(1, 12, 1) var burst_count := 1`
- L7: `@export_range(0.01, 1.0, 0.01) var burst_interval := 0.1`
- L8: `@export var lock_burst_aim := false`
- L9: `@export_group("Airbourne")`
- L10: `@export var applies_airbourne := false`
- L11: `@export var airbourne_speed := 520.0`
- L12: `@export var airbourne_duration := 0.45`
- L14: `@export_range(0.0, 5.0, 0.05) var airbourne_damage_multiplier := 0.35`
- L15: `@export_group("Explosion")`
- L16: `@export var explodes := false`
- L17: `@export var explode_on_impact := true`
- L18: `@export_range(0.05, 10.0, 0.05) var fuse := 0.8`
- L19: `@export_range(1.0, 400.0, 1.0) var explosion_radius := 70.0`
- L20: `@export_range(0.1, 1.0, 0.05) var area_y_ratio := 0.6`
- L21: `@export_range(0.0, 5.0, 0.05) var explosion_damage_multiplier := 1.0`
- L22: `@export var explosion_texture: Texture2D`
- L23: `@export var explosion_color := Color("f6bc65")`
- L24: `@export_range(0.05, 2.0, 0.01) var explosion_visual_duration := 0.18`
- L25: `@export_group("Plate break")`
- L26: `@export_range(0.0, 1.0, 0.01) var plate_break_chance := 0.8`
- L27: `@export_range(0, 40, 1) var plate_fragment_count := 12`
- L28: `@export var plate_fragment_duration := 0.45`
- L29: `@export var plate_fragment_speed := 180.0`
- L30: `@export var plate_fragment_edge_color := Color("c4bba7")`
- L31: `@export_range(0.0, 1.0, 0.01) var plate_fragment_edge_width := 0.1`
- L32: `@export_group("Baguette harpoon")`
- L33: `@export var harpoon_pin_duration := 0.5`
- L34: `@export var harpoon_embed_duration := 0.1`
- L35: `@export var harpoon_embed_angle := -0.25`
- L36: `@export var harpoon_capture_radius := 16.0`
- L37: `@export_group("Pressure cooker landing")`
- L38: `@export var landing_slow_radius := 110.0`
- L39: `@export_range(0.0, 1.0, 0.05) var landing_slow_factor := 0.6`
- L40: `@export var landing_slow_duration := 1.5`
- L41: `@export var landing_visual_duration := 0.3`
- L42: `@export var pot_inflate_amount := 0.2`
- L43: `@export var pot_sprite_scale := 0.5`
- L44: `@export_group("Corn impact")`
- L45: `@export_range(0.0, 1.0, 0.01) var corn_explosion_chance := 0.3`
- L46: `@export_range(0.0, 5.0, 0.05) var corn_contact_damage_multiplier := 0.25`
- L47: `@export_group("Popcorn follow-up")`
- L48: `@export var popcorn_scene: PackedScene`
- L49: `@export var popcorn_speed := 700.0`
- L50: `@export var popcorn_range := 240.0`
- L51: `@export_range(0.0, 5.0, 0.05) var popcorn_damage_multiplier := 1.0`
- L52: `@export_group("Landed explosives")`
- L54: `@export var lob_height := 45.0`
- L55: `@export var egg_contact_push := 1.25`
- L56: `@export_range(0.01, 1.0, 0.01) var egg_fall_duration := 0.1`
- L57: `@export_range(0.0, 2.0, 0.01) var pre_explosion_shake_duration := 0.2`
- L58: `@export_range(0.0, 10.0, 0.1) var pre_explosion_shake_amount := 2.0`
- L59: `@export_range(1.0, 100.0, 1.0) var pre_explosion_shake_frequency := 35.0`
- L60: `@export_range(0, 20, 1) var bonus_yolks := 1`
- L61: `@export_group("Contact remnant")`
- L62: `@export var leaves_pit := false`
- L63: `@export var pit_texture: Texture2D`
- L64: `@export var pit_projectile_scene: PackedScene`
- L65: `@export var pit_projectile_speed := 700.0`
- L66: `@export_range(0.0, 1.0, 0.01) var pit_range_multiplier := 0.5`
- L67: `@export_range(0.0, 90.0, 1.0) var pit_deviation_degrees := 45.0`
- L68: `@export_range(0.1, 20.0, 0.1) var pit_duration := 3.0`
- L69: `@export_range(1.0, 100.0, 1.0) var pit_radius := 16.0`
- L70: `@export_range(0.0, 3.0, 0.05) var pit_damage_multiplier := 0.5`
- L71: `@export_range(0.05, 3.0, 0.05) var pit_hit_interval := 0.5`
- L72: `@export_group("Ketchup splatter")`
- L73: `@export_range(1, 16, 1) var splatter_count := 3`
- L74: `@export_range(0.0, 3.0, 0.05) var splatter_damage_multiplier := 0.25`
- L75: `@export_range(0.0, 180.0, 1.0) var splatter_spread_degrees := 50.0`
- L76: `@export var splatter_speed := 700.0`
- L78: `@export_range(0.0, 1.0, 0.01) var splatter_range_multiplier := 0.1`
- L79: `@export_group("Continuous stream")`
- L80: `@export_range(1.0, 80.0, 0.5) var stream_width := 10.0`
- L81: `@export var stream_color := Color("fff0be")`
- L82: `@export var stream_core_color := Color("fffdf0")`
- L83: `@export var stream_edge_color := Color("c5b587")`
- L84: `@export_range(0.0, 10.0, 0.1) var stream_wobble := 1.6`
- L85: `@export_range(0.0, 30.0, 0.1) var stream_flow_speed := 8.0`
- L86: `@export_range(0.01, 1.0, 0.01) var stream_particle_interval := 0.06`
- L87: `@export_range(0, 40, 1) var stream_muzzle_particles := 3`
- L88: `@export_range(0, 60, 1) var stream_impact_particles := 10`
- L89: `@export_range(0.05, 2.0, 0.01) var stream_particle_lifetime := 0.4`
- L90: `@export_range(0.0, 500.0, 5.0) var stream_particle_speed := 100.0`


## resources/items/weapons/spicy/aura_settings.gd

23 líneas; 18 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6`
- L5: `@export var color := Color(1.0, 0.31, 0.08, 1.0)`
- L6: `@export_range(0.0, 1.0, 0.01) var opacity := 0.22`
- L7: `@export_range(0.0, 10.0, 0.1) var breathing_speed := 2.0`
- L8: `@export_range(0.0, 1.0, 0.01) var breathing_strength := 0.2`
- L10: `@export_group("Orbiting embers")`
- L11: `@export_range(0, 32, 1) var orbit_particle_count := 16`
- L12: `@export_range(0.0, 3.0, 0.05) var orbit_speed := 0.65`
- L13: `@export_range(0.005, 0.08, 0.005) var orbit_particle_size := 0.025`
- L14: `@export_range(0.0, 1.0, 0.05) var orbit_opacity := 0.4`
- L15: `@export_range(0.0, 1.0, 0.05) var ring_opacity := 0.25`
- L16: `@export var ember_color := Color("ff7435")`
- L18: `@export_group("Central embers")`
- L19: `@export_range(0, 32, 1) var central_particle_count := 24`
- L20: `@export_range(0.003, 0.04, 0.001) var central_particle_size := 0.008`
- L21: `@export_range(0.0, 0.5, 0.01) var central_travel := 0.14`
- L22: `@export_range(0.1, 3.0, 0.05) var central_lifetime := 0.9`
- L23: `@export_range(0.0, 1.0, 0.05) var central_opacity := 0.45`


## resources/items/weapons/spicy/explosion_settings.gd

25 líneas; 21 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export_range(1, 20) var explosion_count := 3`
- L5: `@export_range(0.05, 3.0, 0.01) var explosion_interval := 0.32`
- L6: `@export var minimum_distance := 60.0`
- L7: `@export var explosion_radius := 95.0`
- L8: `@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6`
- L9: `@export_range(0.0, 2.0, 0.01) var anticipation := 0.25`
- L10: `@export_range(0.05, 2.0, 0.01) var visual_duration := 0.3`
- L11: `@export var color := Color(1.0, 0.33, 0.035, 1.0)`
- L12: `@export_range(0.0, 1.0, 0.01) var opacity := 0.75`
- L13: `@export_range(0.0, 30.0, 0.1) var burn_duration := 3.0`
- L14: `@export_range(0.05, 5.0, 0.05) var burn_interval := 0.5`
- L15: `@export_range(0.0, 5.0, 0.05) var burn_damage_multiplier := 0.35`
- L17: `@export_group("Explosion visuals")`
- L18: `@export var core_color := Color("fff1ad")`
- L19: `@export var flame_color := Color("ff501d")`
- L20: `@export_range(0.0, 1.0, 0.05) var anticipation_opacity := 0.4`
- L21: `@export_range(0.0, 2.0, 0.05) var flame_strength := 1.0`
- L22: `@export_range(0, 48, 1) var ember_count := 20`
- L23: `@export var ember_duration := 0.4`
- L24: `@export var ember_travel := 0.55`
- L25: `@export var ember_size := 3.0`


## resources/items/weapons/spicy/pattern_settings.gd

132 líneas; 107 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L5: `@export var mode := Mode.TRAIL`
- L6: `@export_range(1, 20) var count := 1`
- L7: `@export var radius := 55.0`
- L8: `@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6`
- L9: `@export var lifetime := 3.0`
- L10: `@export_range(0.05, 5.0, 0.05) var tick_interval := 0.5`
- L11: `@export var fire_ticks := false`
- L12: `@export var movement_speed := 120.0`
- L14: `@export var orbit_speed := 2.4`
- L16: `@export var orbit_center_offset := Vector2.ZERO`
- L17: `@export var trail_spacing := 24.0`
- L18: `@export var arming_time := 0.6`
- L19: `@export var trigger_radius := 40.0`
- L20: `@export var spiral_step_degrees := 22.5`
- L21: `@export var spiral_seed_gap_degrees := 15.0`
- L22: `@export var wave_duration := 0.6`
- L23: `@export var wave_band := 14.0`
- L24: `@export_range(1, 50) var maximum_active := 8`
- L25: `@export var color := Color(1.0, 0.35, 0.05, 1.0)`
- L26: `@export_range(0.0, 1.0, 0.01) var opacity := 0.65`
- L28: `@export var column_height := 288.0`
- L30: `@export_range(1.0, 3.0, 0.05) var column_hit_radius_multiplier := 1.5`
- L31: `@export_group("Column short fire trail")`
- L32: `@export_range(0.1, 3.0, 0.05) var column_trail_lifetime := 1.1`
- L34: `@export_range(0.1, 2.0, 0.05) var column_trail_radius_multiplier := 1.0`
- L35: `@export_range(4.0, 80.0, 1.0) var column_trail_spacing := 18.0`
- L36: `@export_range(0.0, 1.0, 0.05) var column_trail_damage_multiplier := 0.25`
- L37: `@export_group("")`
- L38: `@export var sprite_scale := 0.22`
- L40: `@export_group("Trail fire visuals")`
- L42: `@export var trail_fire_visuals: Resource`
- L43: `@export_range(0.1, 2.0, 0.05) var trail_flame_height := 0.65`
- L44: `@export_range(0.01, 1.0, 0.01) var trail_fade_in := 0.12`
- L45: `@export_range(0.01, 2.0, 0.01) var trail_fade_out := 0.4`
- L47: `@export_group("Fire column visuals")`
- L48: `@export var column_ring_texture: Texture2D`
- L49: `@export var column_fill_texture: Texture2D`
- L50: `@export_range(0.0, 1.0, 0.01) var column_ring_center_opacity := 0.28`
- L51: `@export_range(0.0, 1.0, 0.01) var column_fill_opacity := 0.96`
- L52: `@export_range(1.0, 4.0, 0.05) var column_fill_width := 2.8`
- L53: `@export_range(1.0, 4.0, 0.05) var column_top_width_multiplier := 2.1`
- L55: `@export_range(100.0, 1200.0, 10.0) var column_flare_height := 500.0`
- L56: `@export_range(1.0, 3.0, 0.05) var column_ring_height_scale := 1.7`
- L58: `@export_range(8.0, 80.0, 1.0) var column_ring_spacing := 48.0`
- L59: `@export var column_top_margin := 160.0`
- L60: `@export_range(0.0, 1.0, 0.01) var column_ring_opacity := 0.24`
- L61: `@export_range(0.0, 0.2, 0.005) var column_distortion := 0.025`
- L62: `@export var column_flow_speed := 1.8`
- L63: `@export var column_core_color := Color(1.0, 0.87, 0.35, 1.0)`
- L64: `@export_range(0, 64) var column_base_flames := 8`
- L65: `@export_range(0, 64) var column_ember_count := 28`
- L66: `@export var column_ember_size := 2.5`
- L67: `@export_range(0.01, 1.0, 0.01) var column_fade_in := 0.18`
- L68: `@export_range(0.01, 2.0, 0.01) var column_fade_out := 0.4`
- L70: `@export_group("Fire column contact and heat")`
- L71: `@export var column_contact_texture: Texture2D`
- L72: `@export_range(1.0, 1.8, 0.05) var column_contact_glow_scale := 1.2`
- L73: `@export_range(0.0, 1.0, 0.05) var column_contact_glow_opacity := 0.3`
- L74: `@export_range(0.0, 1.0, 0.01) var column_contact_opacity := 0.95`
- L75: `@export_range(0.0, 1.0, 0.01) var column_contact_front_start := 0.56`
- L76: `@export_range(0.0, 2.0, 0.05) var column_heat_side_reach := 0.6`
- L77: `@export_range(0.0, 20.0, 0.5) var column_heat_distortion_pixels := 3.0`
- L78: `@export_range(0.0, 1.0, 0.01) var column_heat_opacity := 0.55`
- L80: `@export_group("Fire column contact sparks")`
- L81: `@export_range(0, 192) var column_contact_spark_count := 72`
- L82: `@export_range(0.1, 2.0, 0.05) var column_contact_spark_lifetime := 0.75`
- L84: `@export var column_contact_spark_travel := 1.2`
- L85: `@export var column_contact_spark_height := 0.8`
- L86: `@export var column_contact_spark_size := 3.2`
- L87: `@export_range(0.0, 1.0, 0.01) var column_contact_spark_opacity := 0.95`
- L89: `@export_group("Cloud visuals")`
- L90: `@export var cloud_texture: Texture2D`
- L91: `@export_range(1, 48) var cloud_layer_count := 18`
- L92: `@export var cloud_billow_speed := 0.65`
- L93: `@export_range(0.0, 0.1, 0.002) var cloud_distortion := 0.018`
- L94: `@export var cloud_visual_height := 0.08`
- L95: `@export_range(0.01, 2.0, 0.01) var cloud_fade_in := 0.35`
- L96: `@export_range(0.01, 2.0, 0.01) var cloud_fade_out := 0.65`
- L98: `@export_range(0.05, 1.0, 0.01) var cloud_puff_min_scale := 0.28`
- L99: `@export_range(0.05, 1.0, 0.01) var cloud_puff_max_scale := 0.48`
- L100: `@export_range(0.0, 1.0, 0.01) var cloud_puff_opacity := 0.42`
- L101: `@export_range(0.0, 0.5, 0.01) var cloud_puff_drift := 0.15`
- L102: `@export_range(0.3, 8.0, 0.1) var cloud_puff_lifetime := 3.0`
- L104: `@export_group("Cloud placement")`
- L106: `@export_range(0.0, 2.0, 0.05) var cloud_min_separation := 0.85`
- L107: `@export_range(8, 128) var cloud_spawn_attempts := 48`
- L109: `@export_group("Mine placement and visuals")`
- L110: `@export var mine_texture: Texture2D`
- L112: `@export var mine_texture_rect := Rect2()`
- L114: `@export var mine_spawn_growth_per_copy := 0.2`
- L115: `@export var mine_visual_width := 40.0`
- L116: `@export_range(0.1, 1.0, 0.01) var mine_visible_fraction := 0.5`
- L117: `@export_range(0.0, 0.3, 0.01) var mine_squash_strength := 0.08`
- L118: `@export var mine_squash_speed := 3.5`
- L119: `@export var mine_core_color := Color(1.0, 0.95, 0.7, 1.0)`
- L120: `@export var mine_flame_color := Color(1.0, 0.25, 0.04, 1.0)`
- L121: `@export_range(0, 48) var mine_blast_flame_count := 16`
- L122: `@export_range(0, 96) var mine_ember_count := 32`
- L123: `@export var mine_ember_duration := 0.4`
- L124: `@export var mine_ember_travel := 0.75`
- L125: `@export var mine_ember_size := 3.0`
- L127: `@export_group("Shockwave visuals")`
- L128: `@export_range(0.0, 1.0, 0.01) var shockwave_visual_tail := 0.18`
- L129: `@export var shockwave_core_color := Color(1.0, 0.95, 0.72, 1.0)`
- L130: `@export_range(0.01, 0.15, 0.005) var shockwave_rim_width := 0.035`
- L131: `@export_range(0, 96) var shockwave_spark_count := 36`
- L132: `@export var shockwave_spark_size := 3.2`


## resources/items/weapons/spicy_catalogue.gd

13 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const IDS := ["bell_pepper", "jalapeno", "habanero", "cayenne", "poblano", "carolina_reaper", "ghost_pepper", "aji_amarillo", "scotch_bonnet", "rocoto"]`
- L6, `items` (regla/valor): `var result: Array[ItemWeapon] = []`
- L8, `items` (texto): `var item := load("res://resources/items/weapons/spicy/item_%s.tres" % id) as ItemWeapon`

## resources/items/weapons/weapon_stats.gd

33 líneas; 29 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export var damage := 1.0`
- L5: `@export_range(0.0, 3.0, 0.05) var damage_scaling := 1.0`
- L6: `@export_range(.0, 1.0) var accuracy := 1.0`
- L7: `@export_range(.05, 3.0, .01) var cooldown := 1.0`
- L8: `@export_range(.0, 1.0) var crit_chance := .05`
- L9: `@export var crit_damage := 1.5`
- L10: `@export var max_range := 150.0`
- L12: `@export var unlimited_range := false`
- L13: `@export var unlimited_piercing := false`
- L14: `@export var knockback := .0`
- L15: `@export_range(0.0, 10.0, 0.05) var slow_duration := 0.5`
- L16: `@export_range(0, 100, 1) var piercing := 0`
- L17: `@export_range(0, 100, 1) var bounces := 0`
- L18: `@export_range(.0, 1.0) var life_steal := .0`
- L19: `@export var recoil := 25.0`
- L20: `@export_range(.01, 3.0, .01) var recoil_duration := .1`
- L21: `@export_range(.1, 3.0) var attack_duration := .2`
- L22: `@export_range(.1, 3.0) var back_duration := .15`
- L23: `@export var projectile_scene: PackedScene`
- L24: `@export var projectile_speed := 1500.0`
- L25: `@export_group("Ranged effects")`
- L26: `@export var ranged_settings: RangedSettings`
- L27: `@export_group("Spicy aura")`
- L28: `@export var aura_settings: SpicyAuraSettings`
- L29: `@export var spicy_explosion_settings: SpicyExplosionSettings`
- L30: `@export var spicy_pattern: SpicyPatternSettings`
- L31: `@export_group("Melee effects and animation")`
- L32: `@export var melee_settings: MeleeSettings = MeleeSettings.new()`
- L33: `@export_range(0.1, 1.0, 0.01) var animation_cooldown_fraction := 0.9`


## resources/rewards/incognito_loot_settings.gd

60 líneas; 10 anotaciones export; 0 uniforms; 26 candidatos.

Hallazgos: ITEM-09.

### Ya expuesto en el editor

- L3: `@export_group("Base chances")`
- L4: `@export_range(0,1,0.01) var common := 0.65`
- L5: `@export_range(0,1,0.01) var rare := 0.25`
- L6: `@export_range(0,1,0.01) var epic := 0.09`
- L7: `@export_range(0,1,0.01) var legendary := 0.01`
- L8: `@export_group("Luck milestones")`
- L9: `@export var equal_tiers_luck := 500.0`
- L10: `@export var no_common_luck := 1500.0`
- L11: `@export var no_rare_luck := 3000.0`
- L12: `@export var all_legendary_luck := 5000.0`

### Candidatos / evidencia

- L15, `probabilities` (regla/valor): `var base: Array[float] = [maxf(0,common),maxf(0,rare),maxf(0,epic),maxf(0,legendary)]`
- L16, `probabilities` (literal adicional (revisión)): `var total := base[0]+base[1]+base[2]+base[3]`
- L17, `probabilities` (regla/valor): `if total<=0.0: base.assign([1.0,0.0,0.0,0.0])`
- L19, `probabilities` (literal adicional (revisión)): `for index in 4: base[index]/=total`
- L20, `probabilities` (regla/valor): `var milestones := [0.0,maxf(1,equal_tiers_luck)]`
- L21, `probabilities` (literal adicional (revisión)): `milestones.append(maxf(milestones.back()+1,no_common_luck))`
- L22, `probabilities` (literal adicional (revisión)): `milestones.append(maxf(milestones.back()+1,no_rare_luck))`
- L23, `probabilities` (literal adicional (revisión)): `milestones.append(maxf(milestones.back()+1,all_legendary_luck))`
- L24, `probabilities` (regla/valor): `var chances := [base,[0.25,0.25,0.25,0.25],[0.0,1.0/3,1.0/3,1.0/3],[0.0,0.0,0.5,0.5],[0.0,0.0,0.0,1.0]]`
- L25, `probabilities` (literal adicional (revisión)): `luck = maxf(0,luck)`
- L26, `probabilities` (literal adicional (revisión)): `for stage in range(1,milestones.size()):`
- L28, `probabilities` (literal adicional (revisión)): `var blend: float = (luck-milestones[stage-1])/(milestones[stage]-milestones[stage-1])`
- L29, `probabilities` (regla/valor): `var result: Array[float] = []`
- L30, `probabilities` (literal adicional (revisión)): `for tier in 4: result.append(lerpf(chances[stage-1][tier],chances[stage][tier],blend))`
- L32, `probabilities` (regla/valor): `return [0.0,0.0,0.0,1.0]`
- L37, `roll_tier` (literal adicional (revisión)): `for tier in 4:`
- L39, `roll_tier` (regla/valor): `if roll<0.0: return tier`
- L40, `roll_tier` (regla/valor): `return 3`
- L43, `select_item` (regla/valor): `var available := []`
- L44, `select_item` (texto): `for item in load("res://resources/items/passives/catalogue.gd").items():`
- L46, `select_item` (regla/valor): `if item.max_copies>0:`
- L47, `select_item` (regla/valor): `var waiting := 0`
- L49, `select_item` (regla/valor): `if entry.item.get_offer_key()==item.get_offer_key(): waiting+=1`
- L56, `select_item` (literal adicional (revisión)): `while candidates.is_empty() and tier>0:`
- L57, `select_item` (literal adicional (revisión)): `tier-=1`
- L60, `select_item` (visual): `return candidates[random.randi_range(0,candidates.size()-1) if random else randi_range(0,candidates.size()-1)]`

## resources/run_experience.gd

41 líneas; 0 anotaciones export; 0 uniforms; 16 candidatos.

Hallazgos: BASE-03.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var level := 1`
- L7, `declaración` (regla/valor): `var experience := 0`
- L8, `declaración` (regla/valor): `var fractional_experience := 0.0`
- L9, `declaración` (regla/valor): `var pending_levels: Array[int] = []`
- L13, `required_experience` (regla/valor): `return (level + 3) * (level + 3)`
- L16, `reset` (literal adicional (revisión)): `level = 1`
- L17, `reset` (literal adicional (revisión)): `experience = 0`
- L18, `reset` (literal adicional (revisión)): `fractional_experience = 0.0`
- L22, `add_experience` (literal adicional (revisión)): `func add_experience(amount: int, gain_percent: float = 0.0) -> void:`
- L23, `add_experience` (regla/valor): `if amount <= 0: return`
- L24, `add_experience` (literal adicional (revisión)): `var earned := amount * maxf(0.0, 1.0 + gain_percent / 100.0) + fractional_experience`
- L25, `add_experience` (literal adicional (revisión)): `var whole := floori(earned + 0.0000001)`
- L26, `add_experience` (literal adicional (revisión)): `fractional_experience = maxf(0.0, earned - whole)`
- L30, `add_experience` (regla/valor): `level += 1`
- L36, `grant_levels` (regla/valor): `if amount <= 0: return`
- L38, `grant_levels` (regla/valor): `level += 1`

## resources/shop_rarity.gd

29 líneas; 0 anotaciones export; 0 uniforms; 12 candidatos.

Hallazgos: ECO-04.

### Candidatos / evidencia

- L4, `declaración` (constante): `const LAST_BASE_WAVE := 20`
- L5, `declaración` (constante): `const STARTS := [2, 9, 15]`
- L6, `declaración` (constante): `const CAPS := [0.60, 0.20, 0.05]`
- L9, `cumulative` (literal adicional (revisión)): `var wave := clampi(completed_wave, 1, LAST_BASE_WAVE)`
- L10, `cumulative` (regla/valor): `var values: Array[float] = []`
- L11, `cumulative` (literal adicional (revisión)): `for index in 3:`
- L12, `cumulative` (regla/valor): `values.append(0.0 if wave < STARTS[index] else minf(CAPS[index], CAPS[index] * float(wave - STARTS[index] + 1) / float(LAST_BASE_WAVE - STARTS[index] + 1)))`
- L17, `probabilities` (regla/valor): `return [1.0 - c[0], c[0] - c[1], c[1] - c[2], c[2]]`
- L24, `roll_tier` (regla/valor): `if legendary_roll < c[2]: return 3`
- L26, `roll_tier` (regla/valor): `if epic_roll < (c[1] - c[2]) / (1.0 - c[2]): return 2`
- L28, `roll_tier` (regla/valor): `if rare_roll < (c[0] - c[1]) / (1.0 - c[1]): return 1`
- L29, `roll_tier` (regla/valor): `return 0`

## resources/shop_weapon_bias.gd

67 líneas; 0 anotaciones export; 0 uniforms; 15 candidatos.

Hallazgos: ECO-06, ECO-10.

### Candidatos / evidencia

- L3, `declaración` (constante): `const OWNED_FAMILY_CHANCE := 0.40`
- L4, `declaración` (constante): `const SHARED_TAG_WEIGHT := 1.0`
- L7, `equipped` (regla/valor): `var result: Array[ItemWeapon] = []`
- L14, `families` (regla/valor): `var result: Array[String] = []`
- L20, `shared_tags` (regla/valor): `var result: Array[int] = []`
- L27, `tag_weight` (regla/valor): `var weight := 1.0`
- L33, `weighted_weapon` (regla/valor): `var total := 0.0`
- L38, `weighted_weapon` (regla/valor): `if roll <= 0.0: return item`
- L57, `useful_tier` (visual): `if capacity <= 0 or held.size() < capacity or held.is_empty(): return true`
- L58, `useful_tier` (literal adicional (revisión)): `var family := held[0].get_offer_key()`
- L59, `useful_tier` (literal adicional (revisión)): `var lowest := held[0].item_tier`
- L60, `useful_tier` (regla/valor): `var unfinished := 0`
- L64, `useful_tier` (regla/valor): `if weapon.item_tier < 3: unfinished += 1`
- L65, `useful_tier` (regla/valor): `if unfinished > 1: return true`
- L67, `useful_tier` (regla/valor): `return lowest < 3 and item.item_tier >= lowest`

## resources/status_effect.gd

28 líneas; 17 anotaciones export; 0 uniforms; 2 candidatos.

Hallazgos: COM-07.

### Ya expuesto en el editor

- L7: `@export var kind := Kind.FIRE`
- L9: `@export var damage := 2.0`
- L10: `@export var damage_scaling := 1.0`
- L13: `@export var configured_fire_damage := false`
- L14: `@export_range(0.0, 30.0, 0.1) var duration := 3.0`
- L15: `@export_range(0.05, 10.0, 0.05) var tick_interval := 0.5`
- L17: `@export var chain_radius := 65.0`
- L18: `@export_range(0, 100) var maximum_chain_targets := 3`
- L19: `@export var color := Color(1.0, 0.35, 0.05)`
- L20: `@export_range(0.0, 1.0, 0.01) var chance := 1.0`
- L21: `@export_group("Fire visuals")`
- L22: `@export var fire_visuals: FireVisualConfig`
- L23: `@export_group("Electric visuals")`
- L25: `@export_range(0.05, 2.0, 0.01) var electric_impact_duration := 0.38`
- L26: `@export_range(1, 20, 1) var electric_ray_count := 7`
- L27: `@export_range(0.0, 3.0, 0.05) var electric_glow_strength := 1.0`
- L28: `@export_range(0.25, 3.0, 0.05) var electric_visual_scale := 1.0`

### Candidatos / evidencia

- L3, `declaración` (constante): `const FireVisualConfig = preload("res://resources/fire_visual_settings.gd")`
- L6, `declaración` (constante): `const BASE_FIRE_INTERVAL := 0.5`

## resources/ui/ui_palette.gd

43 líneas; 36 anotaciones export; 0 uniforms; 1 candidatos.

### Ya expuesto en el editor

- L5: `@export var display_name := "Cream & yolk"`
- L6: `@export_group("Surfaces")`
- L7: `@export var background := Color("f2e4cb")`
- L8: `@export var surface := Color("fff7e6")`
- L9: `@export var inset := Color("e7d5b4")`
- L10: `@export var outline := Color("695039")`
- L11: `@export_group("Content")`
- L12: `@export var text := Color("443528")`
- L13: `@export var muted := Color("766450")`
- L14: `@export var positive := Color("34704c")`
- L15: `@export var negative := Color("a33836")`
- L16: `@export var accent := Color("a06a18")`
- L17: `@export var hud_text := Color("fff7e6")`
- L18: `@export var health_fill := Color("e45d68")`
- L19: `@export var experience_fill := Color("619bb5")`
- L20: `@export_group("Actions")`
- L21: `@export var button := Color("dbc7a3")`
- L22: `@export var primary := Color("f5bd4f")`
- L23: `@export var danger := Color("df8b78")`
- L24: `@export var focus := Color("176f80")`
- L25: `@export var hover_surface := Color("b9dfe2")`
- L26: `@export var hover_selected := Color("8ac5cd")`
- L27: `@export var locked_surface := Color("766450")`
- L28: `@export var disabled := Color("dfd8c9")`
- L29: `@export var disabled_text := Color("80796e")`
- L30: `@export_group("Rarity borders")`
- L31: `@export var common := Color("237653")`
- L32: `@export var rare := Color("596577")`
- L33: `@export var epic := Color("7043a3")`
- L34: `@export var legendary := Color("a15b0f")`
- L35: `@export_group("Geometry")`
- L36: `@export_range(0, 28) var radius := 16`
- L37: `@export_range(1, 5) var border_width := 2`
- L38: `@export_range(3, 8) var focus_width := 5`
- L39: `@export_range(0, 12) var shadow_size := 3`
- L40: `@export var shadow_color := Color(0, 0, 0, 0.2)`

### Candidatos / evidencia

- L43, `rarity` (regla/valor): `return [common, rare, epic, legendary][clampi(tier, 0, 3)]`

## resources/unit_stats.gd

312 líneas; 46 anotaciones export; 0 uniforms; 72 candidatos.

Hallazgos: COM-01, COM-02, COM-06, COM-10, COM-11.

### Ya expuesto en el editor

- L11: `@export var unlock_id: String`
- L12: `@export var name: String`
- L13: `@export var type: UnitType`
- L14: `@export var icon: Texture2D`
- L16: `@export var starting_weapon: ItemWeapon`
- L17: `@export var character_passives: Array[CharacterPassive] = []`
- L18: `@export var health := 1.0`
- L19: `@export var initial_health := 1.0`
- L21: `@export var health_increase_per_wave := 1.0`
- L23: `@export var damage := 1.0`
- L24: `@export var damage_percent := 0.0`
- L25: `@export var melee_damage := 0.0`
- L26: `@export var ranged_damage := 0.0`
- L27: `@export var attack_speed := 0.0`
- L28: `@export_range(0, 100, 1) var piercing := 0`
- L29: `@export_range(0, 100, 1) var bounces := 0`
- L30: `@export var initial_damage := 1.0`
- L31: `@export var damage_increase_per_wave := 1.0`
- L32: `@export var speed := 300.0`
- L33: `@export var luck := 1.0`
- L34: `@export var initial_luck := 1.0`
- L35: `@export var block_chance := 0.0`
- L36: `@export var initial_block_chance := 0.0`
- L37: `@export var experience_gain := 0.0`
- L38: `@export var experience_reward := 1`
- L39: `@export var coin_drop := 1`
- L41: `@export var hp_regen := .0`
- L42: `@export var life_steal := .0`
- L43: `@export var armor := 0.0`
- L45: `@export var critical_chance := 0.0`
- L47: `@export var area_of_effect := 0.0`
- L48: `@export var critical_multiplier := 0.0`
- L50: `@export_range(0.0, 100.0, 0.1) var block_effectiveness := 50.0`
- L52: `@export var effects := 0.0`
- L53: `@export var chili_power := 0.0`
- L54: `@export var explosive_damage := 0.0`
- L56: `@export var crowd_control := 0.0`
- L58: `@export var slow_strength := 0.0`
- L60: `@export var knockback := 0.0`
- L62: `@export var fire_tick_speed := 0.0`
- L64: `@export var fire_interval_reduction := 0.0`
- L65: `@export var fire_duration_reduction := 0.0`
- L66: `@export var attack_effects: Array[Resource] = []`
- L68: `@export var weapon_range := 0.0`
- L69: `@export var pickup_range := 0.0`
- L70: `@export var harvesting := .0`

### Candidatos / evidencia

- L74, `reset_player_stats` (literal adicional (revisión)): `conditional_push_multiplier = 1.0`
- L80, `reset_player_stats` (literal adicional (revisión)): `hp_regen = 0`
- L81, `reset_player_stats` (literal adicional (revisión)): `life_steal = 0`
- L82, `reset_player_stats` (literal adicional (revisión)): `armor = 0`
- L83, `reset_player_stats` (literal adicional (revisión)): `critical_chance = 0`
- L84, `reset_player_stats` (literal adicional (revisión)): `area_of_effect = 0`
- L85, `reset_player_stats` (literal adicional (revisión)): `critical_multiplier = 0`
- L86, `reset_player_stats` (literal adicional (revisión)): `block_effectiveness = 50`
- L87, `reset_player_stats` (literal adicional (revisión)): `effects = 0`
- L88, `reset_player_stats` (literal adicional (revisión)): `chili_power = 0`
- L89, `reset_player_stats` (literal adicional (revisión)): `explosive_damage = 0`
- L90, `reset_player_stats` (literal adicional (revisión)): `crowd_control = 0`
- L91, `reset_player_stats` (literal adicional (revisión)): `slow_strength = 0`
- L92, `reset_player_stats` (literal adicional (revisión)): `knockback = 0`
- L93, `reset_player_stats` (literal adicional (revisión)): `fire_tick_speed = 0`
- L94, `reset_player_stats` (literal adicional (revisión)): `fire_interval_reduction = 0`
- L95, `reset_player_stats` (literal adicional (revisión)): `fire_duration_reduction = 0`
- L97, `reset_player_stats` (literal adicional (revisión)): `experience_gain = 0`
- L98, `reset_player_stats` (literal adicional (revisión)): `weapon_range = 0`
- L99, `reset_player_stats` (literal adicional (revisión)): `pickup_range = 0`
- L100, `reset_player_stats` (literal adicional (revisión)): `harvesting = 0`
- L101, `reset_player_stats` (literal adicional (revisión)): `piercing = 0`
- L102, `reset_player_stats` (literal adicional (revisión)): `bounces = 0`
- L105, `reset_player_stats` (regla/valor): `var energy_shakes := 0.0`
- L106, `reset_player_stats` (regla/valor): `var infernal_reduction_multiplier := 1.0`
- L109, `reset_player_stats` (regla/valor): `var conditional_push_multiplier := 1.0`
- L112, `reset_player_stats` (regla/valor): `var final_stat_modifiers: Dictionary = {}`
- L113, `reset_player_stats` (regla/valor): `var _before_final: Dictionary = {}`
- L116, `final_multiplier` (regla/valor): `return maxf(0.0, 1.0 + float(final_stat_modifiers.get(stat_id, 0.0)) / 100.0)`
- L131, `get_crowd_control_multiplier` (regla/valor): `return maxf(0.0, 1.0 + crowd_control / 100.0)`
- L137, `get_push_force` (texto): `return maxf(0.0, base_force + unmodified_stat("knockback")) * get_push_multiplier()`
- L140, `effective_slow` (texto): `return 1.0 - clampf((1.0 - factor) * maxf(0.0, 1.0 + unmodified_stat("slow_strength") / 100.0) * final_multiplier("slow_strength") * get_crowd_control_multiplier(), 0.0, 1.0)`
- L143, `effective_slow` (regla/valor): `var _base_stat_values: Dictionary = {}`
- L144, `effective_slow` (regla/valor): `var _stat_gains: Dictionary = {}`
- L145, `effective_slow` (regla/valor): `var _temporary_stat_bonuses: Dictionary = {}`
- L150, `set_temporary_stat_bonus` (texto): `if previous.get("stat", "") == stat_id and is_equal_approx(float(previous.get("amount", 0.0)), amount): return`
- L162, `initialize_character_passives` (literal adicional (revisión)): `_stat_gains[stat_id] = 0.0`
- L184, `get_stat_gain_multiplier` (regla/valor): `var percent := 0.0`
- L188, `get_stat_gain_multiplier` (regla/valor): `return maxf(0.0, 1.0 + percent / 100.0)`
- L194, `apply_stat_change` (regla/valor): `_stat_gains[stat_id] += amount * get_stat_gain_multiplier(stat_id) if amount > 0.0 else amount`
- L199, `_recalculate_character_stats` (regla/valor): `var source_values: Dictionary = {}`
- L210, `_recalculate_character_stats` (regla/valor): `if bonus > 0.0: bonus *= get_stat_gain_multiplier(passive.target_stat)`
- L213, `_recalculate_character_stats` (regla/valor): `if energy_shakes > 0:`
- L215, `_recalculate_character_stats` (literal adicional (revisión)): `attack_speed += maxf(0.0, (speed * final_multiplier("speed") / maxf(1.0, base_speed) - 1.0) * 100.0) * 2.0 * energy_shakes`
- L218, `_recalculate_character_stats` (literal adicional (revisión)): `melee_damage = 0.0`
- L219, `_recalculate_character_stats` (literal adicional (revisión)): `ranged_damage = 0.0`
- L230, `_apply_final_modifiers` (literal adicional (revisión)): `set(stat_id, ((1.0 + original / 100.0) * factor - 1.0) * 100.0)`
- L231, `_apply_final_modifiers` (literal adicional (revisión)): `elif stat_id == "attack_speed":`
- L232, `_apply_final_modifiers` (regla/valor): `var rate := (1.0 + original / 100.0 if original >= 0.0 else 1.0 / (1.0 + absf(original) / 100.0)) * factor`
- L233, `_apply_final_modifiers` (regla/valor): `set(stat_id, (rate - 1.0) * 100.0 if rate >= 1.0 else -(1.0 / maxf(0.0001, rate) - 1.0) * 100.0)`
- L248, `get_incoming_damage_multiplier` (regla/valor): `return 1.0 / (1.0 + armor * 0.06) if armor >= 0.0 else 1.0 + absf(armor) * 0.06`
- L251, `get_block_chance` (regla/valor): `return clampf(block_chance, 0.0, 70.0)`
- L254, `get_pickup_distance` (regla/valor): `return maxf(1.0, base_distance * (1.0 + pickup_range / 100.0))`
- L257, `get_area_radius_multiplier` (regla/valor): `return sqrt(maxf(0.0, 1.0 + area_of_effect / 100.0))`
- L259, `get_effect_damage` (literal adicional (revisión)): `func get_effect_damage(base_damage: float, coefficient: float = 1.0) -> float:`
- L260, `get_effect_damage` (regla/valor): `return maxf(0.0, base_damage + effects * coefficient)`
- L266, `get_damage_percent_multiplier` (texto): `return maxf(0.0, 1.0 + percent / 100.0) * final_multiplier("damage_percent")`
- L269, `get_burning_damage` (regla/valor): `return maxf(0.1, effects * 0.25)`
- L271, `get_fire_interval` (literal adicional (revisión)): `func get_fire_interval(_base_interval: float = 0.5) -> float:`
- L272, `get_fire_interval` (regla/valor): `return maxf(0.05, maxf(0.05, StatusEffect.BASE_FIRE_INTERVAL - fire_interval_reduction) / maxf(0.05, 1.0 + fire_tick_speed / 100.0))`
- L275, `get_fire_duration` (regla/valor): `return maxf(0.0, base_duration * effect_duration_multiplier() - fire_duration_reduction)`
- L286, `primary_display_value` (literal adicional (revisión)): `return get_block_chance() if stat_id == "block_chance" else float(get(stat_id))`
- L289, `halve_primary_stat` (texto): `if not stat_id in load("res://scenes/ui/stats/stats_container.gd").PRIMARY: return false`
- L291, `halve_primary_stat` (regla/valor): `if original <= 0.0: return false`
- L292, `halve_primary_stat` (literal adicional (revisión)): `var target := original * 0.5`
- L297, `halve_primary_stat` (regla/valor): `var low := 0.0`
- L298, `halve_primary_stat` (literal adicional (revisión)): `var high := maxf(1.0, absf(float(get(stat_id))))`
- L299, `halve_primary_stat` (literal adicional (revisión)): `for index in 40:`
- L303, `halve_primary_stat` (regla/valor): `high *= 2.0`
- L305, `halve_primary_stat` (literal adicional (revisión)): `for index in 40:`
- L306, `halve_primary_stat` (literal adicional (revisión)): `var middle := (low + high) * 0.5`
- L311, `halve_primary_stat` (literal adicional (revisión)): `adjust_owned_item_gains({stat_id: -(low + high) * 0.5})`

## resources/unlocks/unlock_achievement.gd

10 líneas; 7 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export var id: String`
- L5: `@export var metric: String`
- L6: `@export var goal := 1.0`
- L7: `@export var requirement: String`
- L8: `@export var reward_label: String`
- L9: `@export var reward_characters: PackedStringArray`
- L10: `@export var reward_weapons: PackedStringArray`


## resources/upgrade_rarity.gd

30 líneas; 0 anotaciones export; 0 uniforms; 12 candidatos.

Hallazgos: ECO-05.

### Candidatos / evidencia

- L5, `declaración` (constante): `const LAST_BASE_LEVEL := 20`
- L6, `declaración` (constante): `const STARTS := [3, 10, 15]`
- L7, `declaración` (constante): `const CAPS := [0.60, 0.20, 0.05]`
- L10, `cumulative` (literal adicional (revisión)): `var level := clampi(character_level, 1, LAST_BASE_LEVEL)`
- L11, `cumulative` (regla/valor): `var values: Array[float] = []`
- L12, `cumulative` (literal adicional (revisión)): `for index in 3:`
- L13, `cumulative` (regla/valor): `values.append(0.0 if level < STARTS[index] else minf(CAPS[index], CAPS[index] * float(level - STARTS[index] + 1) / float(LAST_BASE_LEVEL - STARTS[index] + 1)))`
- L18, `probabilities` (regla/valor): `return [1.0 - c[0], c[0] - c[1], c[1] - c[2], c[2]]`
- L25, `roll_tier` (regla/valor): `if legendary_roll < c[2]: return 3`
- L27, `roll_tier` (regla/valor): `if epic_roll < (c[1] - c[2]) / (1.0 - c[2]): return 2`
- L29, `roll_tier` (regla/valor): `if rare_roll < (c[0] - c[1]) / (1.0 - c[1]): return 1`
- L30, `roll_tier` (regla/valor): `return 0`

## resources/wave/enemy_profile.gd

18 líneas; 11 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L5: `@export var id: StringName`
- L6: `@export var scene: PackedScene`
- L7: `@export var population := Population.COMMON`
- L8: `@export_range(0.1, 3.0) var visual_scale := 1.0`
- L9: `@export_range(0.0, 1.0) var knockback_resistance := 0.0`
- L10: `@export var spawn_margin := 80.0`
- L11: `@export var minimum_player_distance := 120.0`
- L12: `@export var health_growth_multiplier := 1.0`
- L13: `@export var damage_growth_multiplier := 1.0`
- L14: `@export var speed_growth_per_wave := 0.0`
- L15: `@export var resistance_growth_per_wave := 0.0`


## resources/wave/scheduled_spawn.gd

11 líneas; 6 anotaciones export; 0 uniforms; 0 candidatos.

### Ya expuesto en el editor

- L4: `@export var enemy: EnemyProfile`
- L5: `@export_range(0.0, 600.0, 0.1) var second := 0.0`
- L6: `@export_range(1, 500, 1) var count := 1`
- L7: `@export_enum("Anywhere", "Edges", "Interior") var spawn_zone := 0`
- L8: `@export_range(20.0, 1000.0, 5.0) var edge_width := 200.0`
- L11: `@export var telegraph := false`


## resources/wave/spawn_group.gd

44 líneas; 20 anotaciones export; 0 uniforms; 6 candidatos.

### Ya expuesto en el editor

- L4: `@export var label := "Group"`
- L5: `@export var enemies: Array[EnemyProfile] = []`
- L7: `@export var weights: Array[float] = []`
- L9: `@export var spawn_zone := SpawnZone.ANYWHERE`
- L11: `@export_range(20.0, 1000.0, 5.0) var edge_width := 200.0`
- L12: `@export_range(0.0, 180.0) var start_second := 0.0`
- L13: `@export_range(0.05, 60.0) var interval := 1.0`
- L14: `@export_range(1, 100) var minimum_count := 1`
- L15: `@export_range(1, 100) var maximum_count := 1`
- L16: `@export var repetitions := -1`
- L17: `@export var duration := -1.0`
- L18: `@export_range(0.0, 1.0) var activation_probability := 1.0`
- L19: `@export_range(0.0, 5.0) var interval_reduction := 0.0`
- L20: `@export_range(0.05, 60.0) var minimum_interval := 0.25`
- L21: `@export var priority := 0`
- L23: `@export var guaranteed := false`
- L25: `@export var school := false`
- L26: `@export_range(0.0, 1.0) var school_probability := 0.0`
- L27: `@export var affected_by_density := true`
- L28: `@export_range(0.0, 500.0) var school_radius := 140.0`

### Candidatos / evidencia

- L31, `select_enemy` (regla/valor): `var total := 0.0`
- L33, `select_enemy` (visual): `if enemies[i] and enemies[i].is_valid(): total += maxf(0.0, weights[i] if i < weights.size() else 1.0)`
- L34, `select_enemy` (regla/valor): `if total <= 0.0: return null`
- L38, `select_enemy` (visual): `var weight := maxf(0.0, weights[i] if i < weights.size() else 1.0)`
- L40, `select_enemy` (regla/valor): `if weight > 0.0 and roll < 0.0: return enemies[i]`
- L44, `interval_at` (regla/valor): `return maxf(minimum_interval, interval - maxf(0.0, elapsed - start_second) * interval_reduction)`

## resources/wave/wave_data.gd

36 líneas; 19 anotaciones export; 0 uniforms; 1 candidatos.

### Ya expuesto en el editor

- L6: `@export_range(1, 100) var number := 1`
- L7: `@export_range(0.1, 600.0, 0.1) var wave_time := 30.0`
- L8: `@export var wave_type := WaveType.NORMAL`
- L10: `@export var boss_encounter: Resource`
- L12: `@export var music_tracks: Array[AudioStream] = []`
- L16: `@export var arena_mode := ArenaMode.BASE`
- L17: `@export var fixed_arena: ArenaStage`
- L18: `@export var scheduled_spawns: Array[ScheduledSpawnResource] = []`
- L20: `@export_range(0, 10) var density_multiplier := 0`
- L21: `@export var groups: Array[SpawnGroup] = []`
- L22: `@export var events: Array[SpawnGroup] = []`
- L23: `@export_range(1, 500) var common_limit := 35`
- L24: `@export_range(0, 10) var hazard_limit := 0`
- L25: `@export_range(0, 10) var boss_limit := 0`
- L26: `@export_range(0, 20) var reward_limit := 2`
- L27: `@export var health_multiplier := 1.0`
- L28: `@export var damage_multiplier := 1.0`
- L29: `@export var speed_multiplier := 1.0`
- L30: `@export var resistance_multiplier := 1.0`

### Candidatos / evidencia

- L3, `declaración` (constante): `const ScheduledSpawnResource = preload("res://resources/wave/scheduled_spawn.gd")`

## resources/wave/wave_unit_data.gd

11 líneas; 4 anotaciones export; 0 uniforms; 1 candidatos.

### Ya expuesto en el editor

- L4: `@export var unit_scene: PackedScene`
- L5: `@export var weight := 1.0`
- L7: `@export_range(0, 5) var minimum_difficulty := 0`
- L8: `@export_range(1, 100) var first_wave := 1`

### Candidatos / evidencia

- L11, `is_eligible` (regla/valor): `return unit_scene != null and weight > 0.0 and difficulty >= minimum_difficulty and wave >= first_wave`

## scenes/arena/arena.gd

724 líneas; 5 anotaciones export; 0 uniforms; 79 candidatos.

Hallazgos: BASE-04, WORLD-05, WORLD-06, DEV-01.

### Ya expuesto en el editor

- L5: `@export var normal_color: Color`
- L6: `@export var block_color: Color`
- L7: `@export var critical_color: Color`
- L8: `@export var hp_reg_color: Color`
- L10: `@export var test_tiny_egg_consumables := true`

### Candidatos / evidencia

- L42, `declaración` (regla/valor): `var last_warning_second := -1`
- L54, `declaración` (texto): `var run_experience = preload("res://resources/run_experience.gd").new()`
- L58, `_ready` (texto): `coop=preload("res://scenes/coop/local_coop.tscn").instantiate()`
- L61, `_ready` (texto): `projectile_pool = load("res://scenes/projectiles/projectile_pool.gd").new()`
- L63, `_ready` (texto): `stress_test = load("res://scenes/arena/stress_test.tscn").instantiate()`
- L66, `_ready` (texto): `boss_encounter = load("res://scenes/bosses/boss_encounter.gd").new()`
- L70, `_ready` (texto): `damage_feedback = load("res://scenes/ui/player_damage_feedback.tscn").instantiate()`
- L76, `_ready` (texto): `incognito_rewards = load("res://scenes/ui/incognito_rewards.tscn").instantiate()`
- L88, `_ready` (texto): `var unlock_notice = load("res://scenes/ui/unlock_notice.tscn").instantiate()`
- L89, `_ready` (literal adicional (revisión)): `unlock_notice.name = "UnlockPresentation"`
- L96, `_ready` (literal adicional (revisión)): `_apply_wave_environment(1)`
- L100, `_apply_wave_environment` (literal adicional (revisión)): `last_warning_second = -1`
- L110, `_configure_environment` (literal adicional (revisión)): `$Camera2D.configure_view(Rect2(environment.background_offset - environment.background_size * 0.5, environment.background_size), Vector2.ONE * environment.camera_zoom, true, environment_controller.overview_playable_bounds())`
- L121, `_process` (texto): `wave_index_label.text = "STRESS TEST"`
- L122, `_process` (texto): `wave_timer_label.text = ""`
- L134, `_process` (texto): `wave_index_label.text = spawner.get_wave_text()`
- L135, `_process` (texto): `wave_timer_label.text = spawner.get_wave_timer_text()`
- L137, `_process` (regla/valor): `if wave_active and seconds_left >= 1 and seconds_left <= 5 and seconds_left != last_warning_second:`
- L140, `_process` (visual): `var timer_color: Color = UITheme.palette.health_fill if seconds_left <= 5 else UITheme.palette.hud_text`
- L142, `_process` (texto): `wave_timer_label.add_theme_color_override("font_color",timer_color)`
- L161, `create_floating_text` (regla/valor): `var random_pos := randf_range(0, TAU) * 35`
- L172, `start_new_wave` (regla/valor): `spawner.wave_index += 1`
- L186, `show_upgrades` (literal adicional (revisión)): `shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)`
- L188, `show_upgrades` (literal adicional (revisión)): `shop_panel.set_pending_level_rewards(0)`
- L192, `show_upgrades` (literal adicional (revisión)): `var earned_level: int = run_experience.pending_levels[0]`
- L194, `show_upgrades` (texto): `upgrade_panel.get_node("HBoxContainer/VBoxContainer/Label").text = "Level %d\nChoose upgrade (%d remaining)" % [earned_level, run_experience.pending_levels.size()]`
- L203, `_on_experience_level_gained` (literal adicional (revisión)): `player.stats.apply_stat_change("health", 1.0)`
- L205, `_on_experience_level_gained` (literal adicional (revisión)): `player.health_component.heal(maxf(0.0, player.stats.health - previous_max))`
- L209, `_update_experience_bar` (texto): `experience_bar.health_value.text = "LV %d  %d / %d" % [run_experience.level, run_experience.experience, run_experience.required_experience()]`
- L214, `spawn_coins` (regla/valor): `var random_angle := randf_range(0, TAU)`
- L215, `spawn_coins` (regla/valor): `var offset := Vector2.RIGHT.rotated(random_angle) * 35`
- L218, `spawn_coins` (regla/valor): `if reward > 0 and is_instance_valid(Global.player):`
- L219, `spawn_coins` (texto): `var chance: float = 0.02 * Global.player.passive_items.power("double_yolk")`
- L221, `spawn_coins` (literal adicional (revisión)): `chance=0.0`
- L222, `spawn_coins` (texto): `for session in coop.sessions: chance+=0.02*session.actor.passive_items.power("double_yolk")/coop.sessions.size()`
- L223, `spawn_coins` (regla/valor): `reward += floori(chance) + (1 if randf() < fposmod(chance, 1.0) else 0)`
- L230, `spawn_yolk_burst` (literal adicional (revisión)): `func spawn_yolk_burst(origin: Vector2, count: int, minimum_distance: float = 150.0, maximum_distance: float = 320.0, duration: float = 0.5) -> void:`
- L233, `spawn_yolk_burst` (literal adicional (revisión)): `for index in maxi(0,count):`
- L234, `spawn_yolk_burst` (regla/valor): `var angle := TAU*float(index)/maxi(1,count)+randf_range(-0.1,0.1)`
- L235, `spawn_yolk_burst` (regla/valor): `var distance := randf_range(maxf(0,minimum_distance),maxf(minimum_distance,maximum_distance))`
- L238, `spawn_yolk_burst` (texto): `var pickup := load("res://scenes/coins/burst_yolk.tscn").instantiate() as Coins`
- L239, `spawn_yolk_burst` (literal adicional (revisión)): `pickup.value=1`
- L240, `spawn_yolk_burst` (regla/valor): `pickup.launch(origin,destination,duration*randf_range(0.85,1.15),randf_range(40,85))`
- L244, `spawn_yolk_at` (literal adicional (revisión)): `func spawn_yolk_at(spawn_pos: Vector2, value: int = 1) -> void:`
- L272, `clear_arena` (literal adicional (revisión)): `Global.yolk_reserve = 0`
- L276, `clear_arena` (literal adicional (revisión)): `Global.yolk_reserve += maxi(0, coin.value)`
- L294, `_on_create_damage_text` (regla/valor): `var displayed_damage: float = hitbox.damage * (unit.stats.get_incoming_damage_multiplier() if unit is Player else 1.0)`
- L365, `_on_spawner_on_wave_completed` (literal adicional (revisión)): `shop_panel.set_next_stage(environment_controller.prepare_wave(spawner.wave_index + 1), spawner.wave_index + 1)`
- L366, `_on_spawner_on_wave_completed` (texto): `wave_timer_label.text = str(0)`
- L367, `_on_spawner_on_wave_completed` (regla/valor): `await get_tree().create_timer(1).timeout`
- L378, `_continue_wave_rewards` (texto): `final_label.text = "YOU WIN!"`
- L380, `_continue_wave_rewards` (regla/valor): `if Global.level_reached < 5: Global.level_reached += 1`
- L423, `_on_enemy_died` (literal adicional (revisión)): `Progression.record("kills", 1.0)`
- L433, `play_incognito_death` (texto): `confetti.set_script(load("res://effects/incognito_confetti.gd"))`
- L434, `play_incognito_death` (visual): `confetti.position = to_local(enemy.global_position)`
- L452, `_on_stress_test_selected` (literal adicional (revisión)): `func _on_stress_test_selected(population: int = 1000) -> void:`
- L455, `_on_stress_test_selected` (literal adicional (revisión)): `_on_level_selected(0,true)`
- L458, `_on_boss_test_selected` (literal adicional (revisión)): `_on_level_selected(0, false, true)`
- L471, `_on_level_selected` (regla/valor): `var selected: ItemWeapon = Global.main_weapon_selected if Global.is_valid_starting_weapon(Global.main_weapon_selected) else starting_weapons[0]`
- L475, `_on_level_selected` (literal adicional (revisión)): `Global.yolk_reserve = 0`
- L494, `_on_level_selected` (literal adicional (revisión)): `if test_tiny_egg_consumables and player.stats.name=="Tiny Egg" and not stress_mode and not boss_mode:`
- L495, `_on_level_selected` (literal adicional (revisión)): `player.passive_items.golden_yolks=2`
- L496, `_on_level_selected` (literal adicional (revisión)): `player.passive_items.breading_charges=2`
- L500, `_on_level_selected` (regla/valor): `if damage_adjustment>0:`
- L501, `_on_level_selected` (literal adicional (revisión)): `damage_adjustment /= maxf(0.0001,player.stats.get_stat_gain_multiplier("damage_percent"))`
- L540, `_on_player_died` (visual): `var corpse_size: float = 110.0 * $Camera2D.zoom.x`
- L545, `_on_player_died` (literal adicional (revisión)): `Global.yolk_reserve = 0`
- L569, `_finish_defeat` (texto): `final_label.text = "YOU LOSE!"`
- L570, `_finish_defeat` (texto): `final_label.add_theme_color_override("font_color", UITheme.palette.hud_text)`
- L571, `_finish_defeat` (literal adicional (revisión)): `$GameUI.layer = 3`
- L578, `_reset_damage_feedback` (literal adicional (revisión)): `$GameUI.layer = 1`
- L594, `_on_final_button_pressed` (literal adicional (revisión)): `_apply_wave_environment(1)`
- L596, `_on_final_button_pressed` (literal adicional (revisión)): `spawner.wave_index = 1`
- L661, `_on_pause_panel_on_exit_pressed` (literal adicional (revisión)): `_apply_wave_environment(1)`
- L663, `_on_pause_panel_on_exit_pressed` (literal adicional (revisión)): `spawner.wave_index = 1`
- L698, `rewind_upcoming_waves` (literal adicional (revisión)): `var previous_next := spawner.wave_index + 1`
- L699, `rewind_upcoming_waves` (literal adicional (revisión)): `spawner.wave_index = maxi(0, spawner.wave_index - maxi(0, amount))`
- L700, `rewind_upcoming_waves` (literal adicional (revisión)): `var next_wave := spawner.wave_index + 1`
- L721, `_on_boss_test_defeated` (texto): `final_label.text = "BOSS TEST COMPLETE!"`

## scenes/arena/camera_2d.gd

84 líneas; 1 anotaciones export; 0 uniforms; 19 candidatos.

Hallazgos: WORLD-04.

### Ya expuesto en el editor

- L3: `@export var overview_padding := Vector2(32,32)`

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var follow_zoom := Vector2.ONE`
- L7, `declaración` (regla/valor): `var world_bounds := Rect2()`
- L8, `declaración` (regla/valor): `var overview_bounds := Rect2()`
- L9, `declaración` (regla/valor): `var shake_left := 0.0`
- L10, `declaración` (regla/valor): `var shake_length := 0.0`
- L11, `declaración` (regla/valor): `var shake_power := 0.0`
- L39, `toggle_view` (literal adicional (revisión)): `_process(0)`
- L44, `start_shake` (literal adicional (revisión)): `shake_power = maxf(0, strength)`
- L45, `start_shake` (literal adicional (revisión)): `shake_length = maxf(0.01, duration)`
- L52, `laser_coverage_bounds` (literal adicional (revisión)): `var overview_size := viewport_size/maxf(fit,0.001)`
- L54, `laser_coverage_bounds` (visual): `return world_bounds.merge(Rect2(overview_bounds.get_center()-overview_size*0.5,overview_size)).merge(Rect2(global_position-current_size*0.5,current_size))`
- L57, `clear_shake` (literal adicional (revisión)): `shake_left = 0`
- L72, `_process` (literal adicional (revisión)): `var half_view := get_viewport_rect().size / zoom * 0.5`
- L77, `_process` (regla/valor): `if shake_left > 0:`
- L78, `_process` (literal adicional (revisión)): `shake_left = maxf(0, shake_left - delta)`
- L79, `_process` (literal adicional (revisión)): `var phase := (shake_length - shake_left) * 80.0`
- L80, `_process` (literal adicional (revisión)): `offset = Vector2(sin(phase), sin(phase * 1.37)) * shake_power * (shake_left / shake_length)`
- L83, `_process` (literal adicional (revisión)): `var half_view := get_viewport_rect().size / zoom * 0.5`
- L84, `_process` (literal adicional (revisión)): `get_parent().environment_controller.cover_camera_background(Rect2(global_position-half_view,half_view*2).grow(32))`

## scenes/arena/environment_controller.gd

140 líneas; 3 anotaciones export; 0 uniforms; 25 candidatos.

Hallazgos: WORLD-03.

### Ya expuesto en el editor

- L4: `@export var stages: Array[ArenaStage]`
- L5: `@export var debug_forced_stage := 0`
- L7: `@export var overview_playable_margin := Vector2(140,160)`

### Candidatos / evidencia

- L13, `declaración` (regla/valor): `var selected_stages: Dictionary = {}`
- L16, `declaración` (regla/valor): `var background_phase := 0.0`
- L22, `_process` (texto): `flat_background.material.set_shader_parameter("phase", background_phase)`
- L27, `_ready` (literal adicional (revisión)): `flat_background.name = "WorldBackground"`
- L28, `_ready` (literal adicional (revisión)): `flat_background.z_index = -100`
- L33, `_ready` (texto): `var debug_layer=preload("res://scenes/arena/debug_stage_selector.tscn").instantiate()`
- L38, `_ready` (literal adicional (revisión)): `debug_stage_selector.select(clampi(debug_forced_stage, 0, stages.size()))`
- L39, `_ready` (literal adicional (revisión)): `debug_stage_selector.tooltip_text = "Se aplica al iniciar la próxima oleada. No se guarda."`
- L62, `_on_debug_stage_selected` (literal adicional (revisión)): `var next_wave: int = arena.spawner.wave_index + 1`
- L76, `prepare_wave` (visual): `if OS.is_debug_build() and debug_forced_stage > 0 and debug_forced_stage <= stages.size():`
- L77, `prepare_wave` (literal adicional (revisión)): `selected_stages[wave] = stages[debug_forced_stage - 1]`
- L88, `prepare_wave` (regla/valor): `var mode: int = config.arena_mode if config else 0`
- L89, `prepare_wave` (regla/valor): `if mode == 1 and config.fixed_arena != null and config.fixed_arena.is_valid():`
- L91, `prepare_wave` (regla/valor): `elif mode == 2:`
- L93, `prepare_wave` (visual): `if not specials.is_empty(): selected = specials[stage_random.randi_range(0, specials.size()-1)]`
- L109, `overview_playable_bounds` (visual): `var framed := Rect2(current.movement_bounds.position-margin,current.movement_bounds.size+margin*2)`
- L113, `overview_playable_bounds` (literal adicional (revisión)): `framed = framed.merge(body.grow(40))`
- L117, `overview_playable_bounds` (regla/valor): `return Rect2(center-half,half*2)`
- L121, `cover_camera_background` (visual): `var base := Rect2(current.background_offset-current.background_size*0.5,current.background_size)`
- L123, `cover_camera_background` (visual): `flat_background.position = to_local(covered.position)`
- L124, `cover_camera_background` (visual): `flat_background.size = covered.size`
- L133, `apply_stage` (visual): `flat_background.position = current.background_offset - current.background_size * 0.5`
- L134, `apply_stage` (visual): `flat_background.size = current.background_size`
- L138, `apply_stage` (visual): `vessel.position = current_stage.vessel_offset`
- L139, `apply_stage` (visual): `vessel.scale = current_stage.vessel_size / vessel.texture.get_size()`

## scenes/arena/mechanics/bubble_effect.gd

69 líneas; 0 anotaciones export; 0 uniforms; 23 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var burst_duration := 0.05`
- L7, `declaración` (visual): `var sprite_scale := 1.0`
- L8, `declaración` (regla/valor): `var red_phase_start := 0.75`
- L9, `declaración` (regla/valor): `var explosion_elapsed := 0.0`
- L14, `_ready` (texto): `dome.texture = preload("res://assets/sprites/arena/oil_bubble.png")`
- L17, `_ready` (texto): `splash.texture = preload("res://assets/sprites/arena/oil_splash.png")`
- L20, `_ready` (literal adicional (revisión)): `sprite_scale = radius * 2.0 / (dome.texture.get_width() * 0.90 * 1.1)`
- L21, `_ready` (literal adicional (revisión)): `dome.position.y = -radius * 0.20`
- L22, `_ready` (literal adicional (revisión)): `splash.position.y = -radius * 0.20`
- L26, `_ready` (texto): `oil_material.shader = preload("res://shaders/oil_translucency.gdshader")`
- L49, `explode` (literal adicional (revisión)): `explosion_elapsed = 0.0`
- L57, `update_visuals` (literal adicional (revisión)): `var progress := clampf(elapsed / warning_duration, 0, 1)`
- L58, `update_visuals` (literal adicional (revisión)): `var growth := lerpf(0.1, 1.0, 1.0 - pow(1.0 - minf(progress / 0.75, 1), 2))`
- L59, `update_visuals` (regla/valor): `var vibration := Vector2.ONE`
- L60, `update_visuals` (regla/valor): `if progress > 0.75:`
- L61, `update_visuals` (literal adicional (revisión)): `var charge := (progress - 0.75) / 0.25`
- L62, `update_visuals` (literal adicional (revisión)): `growth = lerpf(1.0, 1.1, charge)`
- L63, `update_visuals` (literal adicional (revisión)): `var wobble := sin(elapsed * 65.0) * 0.035 * charge`
- L64, `update_visuals` (literal adicional (revisión)): `vibration = Vector2(1.0 + wobble, 1.0 - wobble)`
- L65, `update_visuals` (visual): `dome.scale = Vector2.ONE * sprite_scale * growth * vibration`
- L67, `update_visuals` (literal adicional (revisión)): `var progress := clampf(explosion_elapsed / burst_duration, 0, 1)`
- L68, `update_visuals` (visual): `splash.scale = Vector2.ONE * sprite_scale * lerpf(0.8, 1.1, progress)`
- L69, `update_visuals` (literal adicional (revisión)): `splash.modulate.a = 1.0 - progress`

## scenes/arena/mechanics/flame_transition.gd

56 líneas; 0 anotaciones export; 0 uniforms; 29 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var duration := 0.45`
- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L9, `_ready` (literal adicional (revisión)): `z_index = 0`
- L11, `_ready` (literal adicional (revisión)): `sparks.amount = 18`
- L14, `_ready` (literal adicional (revisión)): `sparks.explosiveness = 0.85`
- L16, `_ready` (literal adicional (revisión)): `sparks.spread = 38`
- L17, `_ready` (literal adicional (revisión)): `sparks.initial_velocity_min = 70`
- L18, `_ready` (literal adicional (revisión)): `sparks.initial_velocity_max = 160`
- L19, `_ready` (literal adicional (revisión)): `sparks.gravity = Vector2(0, -80)`
- L20, `_ready` (literal adicional (revisión)): `sparks.scale_amount_min = 0.35`
- L21, `_ready` (literal adicional (revisión)): `sparks.scale_amount_max = 0.85`
- L23, `_ready` (literal adicional (revisión)): `texture.width = 24`
- L24, `_ready` (literal adicional (revisión)): `texture.height = 24`
- L26, `_ready` (literal adicional (revisión)): `texture.fill_from = Vector2(0.5, 0.5)`
- L27, `_ready` (literal adicional (revisión)): `texture.fill_to = Vector2(1.0, 0.5)`
- L29, `_ready` (literal adicional (revisión)): `glow.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])`
- L33, `_ready` (literal adicional (revisión)): `colors.offsets = PackedFloat32Array([0, 0.35, 1])`
- L34, `_ready` (literal adicional (revisión)): `colors.colors = PackedColorArray([Color("fff1b3"), Color("ffac39"), Color(0.95, 0.22, 0.05, 0)])`
- L39, `_process` (visual): `sparks.speed_scale = 0.0 if Global.game_paused else 1.0`
- L46, `_draw` (literal adicional (revisión)): `var progress := clampf(elapsed / maxf(0.05, duration), 0, 1)`
- L48, `_draw` (regla/valor): `var alpha := 1.0 - smoothstep(0.65, 1.0, progress)`
- L49, `_draw` (literal adicional (revisión)): `draw_circle(Vector2(0, -10), 55 * strength, Color(1.0, 0.48, 0.10, 0.18 * alpha))`
- L50, `_draw` (literal adicional (revisión)): `var points := PackedVector2Array([Vector2(-42, 6), Vector2(-53, -28), Vector2(-30, -75), Vector2(-27, -38), Vector2(0, -145), Vector2(14, -60), Vector2(35, -103), Vector2(48, -40), Vector2(35, 6)])`
- L51, `_draw` (literal adicional (revisión)): `for i in points.size(): points[i] *= maxf(0.08, strength)`
- L52, `_draw` (literal adicional (revisión)): `draw_colored_polygon(points, Color(0.98, 0.28, 0.06, alpha))`
- L53, `_draw` (literal adicional (revisión)): `for i in points.size(): points[i] *= Vector2(0.62, 0.72)`
- L54, `_draw` (literal adicional (revisión)): `draw_colored_polygon(points, Color(1.0, 0.70, 0.15, alpha))`
- L55, `_draw` (literal adicional (revisión)): `for i in points.size(): points[i] *= Vector2(0.52, 0.52)`
- L56, `_draw` (literal adicional (revisión)): `draw_colored_polygon(points, Color(1.0, 0.96, 0.72, alpha))`

## scenes/arena/mechanics/griddle_mechanic.gd

80 líneas; 19 anotaciones export; 0 uniforms; 20 candidatos.

### Ya expuesto en el editor

- L3: `@export var initial_delay := 0.8`
- L4: `@export var minimum_interval := 0.9`
- L5: `@export var maximum_interval := 1.5`
- L6: `@export var radius := 350.0`
- L7: `@export var damage := 2.0`
- L8: `@export var warning_duration := 1.0`
- L9: `@export var active_duration := 12.0`
- L10: `@export var cooling_duration := 1.2`
- L11: `@export var damage_interval := 0.75`
- L12: `@export_range(1, 12) var maximum_zones := 6`
- L13: `@export_range(0.0, 200.0) var minimum_zone_gap := 8.0`
- L14: `@export var breathing_period := 2.5`
- L15: `@export_range(0.2, 0.9) var damage_core_ratio := 0.60`
- L16: `@export_group("Heat distortion")`
- L17: `@export var distortion_enabled := true`
- L18: `@export_range(0.0, 20.0) var distortion_strength_pixels := 5.5`
- L19: `@export_range(0.0, 10.0) var distortion_vertical_pixels := 1.5`
- L20: `@export_range(0.0, 600.0) var distortion_height := 180.0`
- L21: `@export_range(0.0, 5.0) var distortion_speed := 1.0`

### Candidatos / evidencia

- L22, `declaración` (regla/valor): `var next_zone := 0.0`
- L26, `start` (literal adicional (revisión)): `z_index = -2`
- L29, `start` (literal adicional (revisión)): `screen_copy.name = "HeatScreenCopy"`
- L32, `start` (literal adicional (revisión)): `screen_copy.z_index = 4`
- L34, `start` (literal adicional (revisión)): `next_zone = maxf(0.05, initial_delay)`
- L39, `_process` (regla/valor): `if next_zone <= 0.0:`
- L45, `spawn_zone` (literal adicional (revisión)): `var effective_radius := maxf(10.0, radius)`
- L46, `spawn_zone` (regla/valor): `var point := Vector2.INF`
- L47, `spawn_zone` (literal adicional (revisión)): `for attempt in 32:`
- L53, `spawn_zone` (texto): `var zone = preload("res://scenes/arena/mechanics/hot_zone_effect.gd").new()`
- L56, `spawn_zone` (literal adicional (revisión)): `zone.damage = maxf(0, damage)`
- L57, `spawn_zone` (literal adicional (revisión)): `zone.warning_duration = maxf(0.05, warning_duration)`
- L58, `spawn_zone` (literal adicional (revisión)): `zone.active_duration = maxf(0.05, active_duration)`
- L59, `spawn_zone` (literal adicional (revisión)): `zone.cooling_duration = maxf(0.05, cooling_duration)`
- L60, `spawn_zone` (literal adicional (revisión)): `zone.damage_interval = maxf(0.05, damage_interval)`
- L66, `spawn_zone` (regla/valor): `zone.shape_phase = random.randf_range(0, TAU)`
- L67, `spawn_zone` (regla/valor): `zone.breathing_offset = random.randf_range(0, TAU)`
- L68, `spawn_zone` (literal adicional (revisión)): `zone.breathing_period = maxf(0.1, breathing_period)`
- L69, `spawn_zone` (literal adicional (revisión)): `zone.damage_core_ratio = clampf(damage_core_ratio, 0.2, 0.9)`
- L77, `is_zone_position_free` (literal adicional (revisión)): `var separation: float = new_radius * damage_core_ratio + child.radius * child.damage_core_ratio + maxf(0, minimum_zone_gap)`

## scenes/arena/mechanics/hot_zone_effect.gd

88 líneas; 0 anotaciones export; 0 uniforms; 40 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var active_duration := 12.0`
- L6, `declaración` (regla/valor): `var cooling_duration := 1.2`
- L7, `declaración` (regla/valor): `var damage_interval := 0.75`
- L8, `declaración` (regla/valor): `var next_tick := 0.0`
- L10, `declaración` (regla/valor): `var distortion_strength_pixels := 5.5`
- L11, `declaración` (regla/valor): `var distortion_vertical_pixels := 1.5`
- L12, `declaración` (regla/valor): `var distortion_height := 180.0`
- L13, `declaración` (regla/valor): `var distortion_speed := 1.0`
- L16, `declaración` (regla/valor): `var shape_phase := 0.0`
- L17, `declaración` (regla/valor): `var breathing_offset := 0.0`
- L18, `declaración` (regla/valor): `var breathing_period := 2.5`
- L19, `declaración` (regla/valor): `var damage_core_ratio := 0.60`
- L23, `_ready` (texto): `ground = make_visual(preload("res://shaders/hot_zone_ground.gdshader"))`
- L24, `_ready` (visual): `ground.position = -Vector2.ONE * radius`
- L25, `_ready` (visual): `ground.size = Vector2.ONE * radius * 2`
- L26, `_ready` (texto): `ground.material.set_shader_parameter("shape_phase", shape_phase)`
- L27, `_ready` (texto): `ground.material.set_shader_parameter("damage_core_ratio", damage_core_ratio)`
- L28, `_ready` (texto): `ground.material.set_shader_parameter("zone_radius", radius)`
- L30, `_ready` (texto): `ground.material.set_shader_parameter("arena_rect", Vector4(bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y))`
- L31, `_ready` (texto): `ground.material.set_shader_parameter("arena_corner", mechanic.area.corner_radius)`
- L33, `_ready` (texto): `air = make_visual(preload("res://shaders/hot_zone_air.gdshader"))`
- L34, `_ready` (visual): `air.position = -Vector2(radius, radius + distortion_height)`
- L35, `_ready` (visual): `air.size = Vector2(radius * 2, radius * 2 + distortion_height)`
- L37, `_ready` (literal adicional (revisión)): `air.z_index = 5`
- L38, `_ready` (texto): `air.material.set_shader_parameter("strength_pixels", distortion_strength_pixels)`
- L39, `_ready` (texto): `air.material.set_shader_parameter("vertical_strength_pixels", distortion_vertical_pixels)`
- L59, `_process` (regla/valor): `if next_tick <= 0.0:`
- L61, `_process` (literal adicional (revisión)): `next_tick = maxf(0.05, damage_interval)`
- L68, `update_visuals` (regla/valor): `var intensity := 1.0`
- L70, `update_visuals` (literal adicional (revisión)): `intensity = lerpf(0.15, 0.45, clampf(elapsed / warning_duration, 0, 1))`
- L72, `update_visuals` (literal adicional (revisión)): `intensity = 1.0 - clampf((elapsed - warning_duration - active_duration) / cooling_duration, 0, 1)`
- L73, `update_visuals` (texto): `ground.material.set_shader_parameter("phase", elapsed)`
- L74, `update_visuals` (texto): `ground.material.set_shader_parameter("intensity", intensity)`
- L75, `update_visuals` (texto): `ground.material.set_shader_parameter("zone_center", global_position)`
- L76, `update_visuals` (regla/valor): `var breath := 0.5 + 0.5 * sin(elapsed * TAU / breathing_period + breathing_offset)`
- L77, `update_visuals` (texto): `ground.material.set_shader_parameter("breath", breath)`
- L79, `update_visuals` (literal adicional (revisión)): `air.visible = state != State.WARNING and intensity > 0`
- L80, `update_visuals` (texto): `air.material.set_shader_parameter("phase", elapsed * distortion_speed)`
- L81, `update_visuals` (texto): `air.material.set_shader_parameter("intensity", intensity * lerpf(0.65, 1.0, breath))`
- L84, `shape_radius` (regla/valor): `return 0.75 + 0.13 * sin(angle * 3.0 + shape_phase) + 0.08 * cos(angle * 2.0 - shape_phase * 0.7)`

## scenes/arena/mechanics/pan_mechanic.gd

119 líneas; 8 anotaciones export; 0 uniforms; 24 candidatos.

### Ya expuesto en el editor

- L4: `@export var spawn_delay := 1.0`
- L5: `@export var active_duration := 5.0`
- L6: `@export var rest_duration := 1.0`
- L7: `@export var flare_duration := 0.45`
- L8: `@export_range(1, 32) var maximum_active := 16`
- L9: `@export var separation_distance := 120.0`
- L10: `@export var separation_force := 150.0`
- L11: `@export var profile: EnemyProfile`

### Candidatos / evidencia

- L13, `declaración` (regla/valor): `var phase_time := 0.0`
- L14, `declaración` (visual): `var batch_size := 1`
- L15, `declaración` (regla/valor): `var pending := 0`
- L16, `declaración` (regla/valor): `var hazards: Array[Enemy] = []`
- L17, `declaración` (regla/valor): `var spawn_points: Array[Vector2] = []`
- L27, `_process` (regla/valor): `if phase_time >= maxf(0.05, spawn_delay): begin_batch()`
- L29, `_process` (regla/valor): `if phase_time >= maxf(0.05, flare_duration): materialize_batch()`
- L32, `_process` (regla/valor): `if phase_time >= maxf(0.05, active_duration): retire_batch()`
- L34, `_process` (regla/valor): `if phase_time >= maxf(0.05, flare_duration): state = State.RESTING; phase_time = 0`
- L36, `_process` (regla/valor): `if phase_time >= maxf(0.0, rest_duration - flare_duration * 2.0):`
- L37, `_process` (literal adicional (revisión)): `batch_size = mini(batch_size + 1, maximum_active)`
- L41, `create_flare` (texto): `var flare = preload("res://scenes/arena/mechanics/flame_transition.gd").new()`
- L42, `create_flare` (literal adicional (revisión)): `flare.duration = maxf(0.05, flare_duration)`
- L50, `begin_batch` (literal adicional (revisión)): `for attempt in 32:`
- L62, `begin_batch` (literal adicional (revisión)): `phase_time = 0`
- L71, `materialize_batch` (literal adicional (revisión)): `enemy.stats.coin_drop = 0`
- L72, `materialize_batch` (literal adicional (revisión)): `enemy.stats.experience_reward = 0`
- L79, `materialize_batch` (literal adicional (revisión)): `pending = 0`
- L81, `materialize_batch` (literal adicional (revisión)): `phase_time = 0`
- L95, `retire_batch` (literal adicional (revisión)): `phase_time = 0`
- L100, `separate_hazards` (literal adicional (revisión)): `for j in range(i + 1, hazards.size()):`
- L105, `separate_hazards` (visual): `var direction := offset / distance if distance > 0.01 else Vector2.RIGHT.rotated(TAU * float(i + j) / maxf(1, hazards.size()))`
- L106, `separate_hazards` (literal adicional (revisión)): `var push := direction * maxf(0, separation_force) * (1.0 - distance / maxf(1, separation_distance)) * delta * 0.5`
- L116, `stop` (literal adicional (revisión)): `pending = 0`

## scenes/arena/mechanics/pot_mechanic.gd

54 líneas; 11 anotaciones export; 0 uniforms; 15 candidatos.

### Ya expuesto en el editor

- L3: `@export var initial_delay := 0.5`
- L4: `@export var minimum_interval := 0.25`
- L5: `@export var maximum_interval := 0.55`
- L6: `@export var radii := PackedFloat32Array([55.0, 85.0, 120.0])`
- L7: `@export var damages := PackedFloat32Array([2.0, 4.0, 6.0])`
- L8: `@export var explosion_times := PackedFloat32Array([1.8, 2.8, 4.0])`
- L9: `@export_range(0.1, 5.0) var animation_speed := 1.5`
- L10: `@export var burst_duration := 0.075`
- L11: `@export_range(1, 30) var maximum_bubbles := 12`
- L12: `@export var minimum_gap := 12.0`
- L13: `@export_range(0.1, 0.95) var red_phase_start := 0.75`

### Candidatos / evidencia

- L14, `declaración` (regla/valor): `var next_bubble := 0.0`
- L18, `start` (literal adicional (revisión)): `z_index = -2`
- L19, `start` (literal adicional (revisión)): `next_bubble = maxf(0.05, initial_delay)`
- L24, `_process` (regla/valor): `if next_bubble <= 0.0:`
- L28, `spawn_bubble` (literal adicional (revisión)): `func spawn_bubble(size_index: int = -1) -> StageAreaEffect:`
- L30, `spawn_bubble` (visual): `var index := clampi(size_index, 0, radii.size() - 1) if size_index >= 0 else random.randi_range(0, radii.size() - 1)`
- L31, `spawn_bubble` (literal adicional (revisión)): `var radius := maxf(10.0, radii[index])`
- L32, `spawn_bubble` (regla/valor): `var point := Vector2.INF`
- L33, `spawn_bubble` (literal adicional (revisión)): `for attempt in 24:`
- L37, `spawn_bubble` (texto): `var bubble = preload("res://scenes/arena/mechanics/bubble_effect.gd").new()`
- L41, `spawn_bubble` (visual): `bubble.damage = maxf(0, damages[mini(index, damages.size() - 1)]) if not damages.is_empty() else 0.0`
- L42, `spawn_bubble` (visual): `bubble.warning_duration = maxf(0.1, explosion_times[mini(index, explosion_times.size() - 1)]) if not explosion_times.is_empty() else 1.8`
- L43, `spawn_bubble` (literal adicional (revisión)): `bubble.warning_duration /= maxf(0.1, animation_speed)`
- L44, `spawn_bubble` (literal adicional (revisión)): `bubble.burst_duration = maxf(0.05, burst_duration / maxf(0.1, animation_speed))`
- L52, `is_bubble_position_free` (literal adicional (revisión)): `var separation: float = new_radius + child.radius + maxf(0, minimum_gap)`

## scenes/arena/mechanics/stage_area_effect.gd

33 líneas; 0 anotaciones export; 0 uniforms; 7 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var radius := 100.0`
- L6, `declaración` (regla/valor): `var damage := 3.0`
- L7, `declaración` (regla/valor): `var warning_duration := 1.2`
- L8, `declaración` (regla/valor): `var elapsed := 0.0`
- L16, `_ready` (literal adicional (revisión)): `damage_hitbox.collision_layer = 0`
- L17, `_ready` (literal adicional (revisión)): `damage_hitbox.collision_mask = 0`
- L20, `_ready` (literal adicional (revisión)): `damage_hitbox.setup(damage, false, 0.0, self)`

## scenes/arena/mechanics/stage_mechanic.gd

60 líneas; 0 anotaciones export; 0 uniforms; 11 candidatos.

### Candidatos / evidencia

- L14, `start` (literal adicional (revisión)): `process_priority = 50`
- L28, `live_units` (regla/valor): `var result: Array[Unit] = []`
- L36, `is_live` (regla/valor): `return is_instance_valid(unit) and not unit.is_queued_for_deletion() and unit.health_component.current_health > 0.0 and (not unit is Enemy or not unit.is_retiring)`
- L43, `random_interval` (regla/valor): `return random.randf_range(maxf(0.05, minimum), maxf(0.05, maxf(minimum, maximum)))`
- L46, `random_effect_position` (literal adicional (revisión)): `for attempt in 32:`
- L48, `random_effect_position` (visual): `var point := Vector2(random.randf_range(bounds.position.x, bounds.end.x), random.randf_range(bounds.position.y, bounds.end.y))`
- L50, `random_effect_position` (literal adicional (revisión)): `for step in 16:`
- L51, `random_effect_position` (literal adicional (revisión)): `var sample := point + Vector2.from_angle(TAU * step / 16.0) * radius`
- L54, `random_effect_position` (regla/valor): `return Vector2.INF`
- L57, `live_effect_count` (regla/valor): `var count := 0`
- L59, `live_effect_count` (regla/valor): `if child is StageAreaEffect and not child.is_queued_for_deletion(): count += 1`

## scenes/arena/mechanics/stage_mechanics_controller.gd

29 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.

Hallazgos: WORLD-07.


## scenes/arena/mechanics/tray_mechanic.gd

195 líneas; 20 anotaciones export; 0 uniforms; 59 candidatos.

### Ya expuesto en el editor

- L4: `@export var initial_delay := 1.5`
- L5: `@export var minimum_interval := 2.0`
- L6: `@export var maximum_interval := 3.0`
- L7: `@export var tracking_duration := 2.5`
- L8: `@export var tracking_speed := 320.0`
- L9: `@export_range(0.1, 10.0) var tracking_smoothing := 1.8`
- L10: `@export var lock_duration := 1.0`
- L11: `@export var fall_duration := 0.046666667`
- L12: `@export var shadow_anticipation_duration := 0.50`
- L13: `@export_range(0.5, 1.0) var shadow_raised_scale := 0.80`
- L14: `@export var hold_duration := 0.18`
- L15: `@export var retract_duration := 0.5`
- L16: `@export var impact_size := Vector2(360, 450)`
- L17: `@export var fall_height := 140.0`
- L18: `@export var peek_height := 100.0`
- L19: `@export var push_speed := 750.0`
- L20: `@export var push_duration := 0.45`
- L21: `@export_range(0.0, 100.0) var player_damage_percent := 40.0`
- L22: `@export var shake_strength := 10.0`
- L23: `@export var shake_duration := 0.22`

### Candidatos / evidencia

- L24, `declaración` (constante): `const TEXTURE = preload("res://assets/sprites/arena/giant_spatula.png")`
- L25, `declaración` (constante): `const HEAD_PIXELS = Rect2(260, 84, 500, 620)`
- L27, `declaración` (regla/valor): `var next_event := 0.0`
- L28, `declaración` (regla/valor): `var phase_time := 0.0`
- L29, `declaración` (regla/valor): `var impact := Rect2()`
- L30, `declaración` (regla/valor): `var pushes: Array[Dictionary] = []`
- L35, `declaración` (visual): `var peek_position := Vector2.ZERO`
- L36, `declaración` (regla/valor): `var retreat_start := Vector2.ZERO`
- L42, `start` (literal adicional (revisión)): `next_event = maxf(0.05, initial_delay)`
- L46, `start` (literal adicional (revisión)): `damage_hitbox.collision_layer = 0`
- L47, `start` (literal adicional (revisión)): `damage_hitbox.collision_mask = 0`
- L56, `start` (literal adicional (revisión)): `spatula.z_index = 6`
- L63, `start` (literal adicional (revisión)): `shadow.z_index = -1`
- L66, `start` (texto): `shadow_material.shader = preload("res://shaders/spatula_shadow.gdshader")`
- L73, `target_position` (literal adicional (revisión)): `var size := impact_size.min(bounds.size - Vector2.ONE * (area.corner_radius * 2 + 20)).max(Vector2.ONE * 10)`
- L75, `target_position` (regla/valor): `var margin := Vector2.ONE * (area.corner_radius + 10)`
- L77, `target_position` (visual): `return Vector2(clampf(center.x - size.x * 0.37, bounds.position.x + margin.x, bounds.end.x - margin.x - size.x), clampf(center.y - size.y * 0.5, bounds.position.y + margin.y, bounds.end.y - margin.y - size.y))`
- L80, `bottom_y` (visual): `return camera.get_screen_center_position().y + camera.get_viewport_rect().size.y / camera.zoom.y * 0.5`
- L84, `begin_strike` (visual): `impact.size = impact_size.min(area.movement_bounds.size - Vector2.ONE * (area.corner_radius * 2 + 20)).max(Vector2.ONE * 10)`
- L85, `begin_strike` (visual): `impact.position = target_position()`
- L86, `begin_strike` (literal adicional (revisión)): `phase_time = 0`
- L96, `_process` (regla/valor): `if next_event <= 0: begin_strike()`
- L101, `_process` (literal adicional (revisión)): `var smooth_target := impact.position.lerp(target_position(), 1.0 - exp(-tracking_smoothing * delta))`
- L102, `_process` (visual): `impact.position = impact.position.move_toward(smooth_target, maxf(0, tracking_speed) * delta)`
- L103, `_process` (regla/valor): `if phase_time >= maxf(0.05, tracking_duration):`
- L106, `_process` (literal adicional (revisión)): `phase_time = 0`
- L108, `_process` (regla/valor): `if phase_time >= maxf(0.05, lock_duration): state = State.FALLING; phase_time = 0`
- L110, `_process` (regla/valor): `if phase_time >= maxf(0.01, fall_duration):`
- L114, `_process` (literal adicional (revisión)): `phase_time = 0`
- L116, `_process` (regla/valor): `if phase_time >= maxf(0.05, hold_duration):`
- L119, `_process` (literal adicional (revisión)): `phase_time = 0`
- L121, `_process` (regla/valor): `if phase_time >= maxf(0.05, retract_duration):`
- L129, `contains_head` (regla/valor): `return texture_image.get_pixel(int(pixel.x), int(pixel.y)).a >= 0.60`
- L135, `strike` (texto): `load("res://effects/arena_bursts.gd").emit_at(self, impact.get_center(), true, impact.size)`
- L138, `strike` (literal adicional (revisión)): `pushes.append({"unit": weakref(unit), "velocity": Vector2.UP * maxf(0, push_speed), "remaining": maxf(0.05, push_duration), "duration": maxf(0.05, push_duration)})`
- L140, `strike` (literal adicional (revisión)): `damage_hitbox.setup(unit.health_component.max_health * player_damage_percent / 100.0, false, 0, self)`
- L146, `_apply_pushes` (literal adicional (revisión)): `for index in range(pushes.size() - 1, -1, -1):`
- L151, `_apply_pushes` (literal adicional (revisión)): `var strength: float = (push.remaining - step * 0.5) / push.duration`
- L154, `_apply_pushes` (regla/valor): `if push.remaining <= 0: pushes.remove_at(index)`
- L156, `place_sprite` (literal adicional (revisión)): `func place_sprite(sprite: Sprite2D, head_position: Vector2, multiplier: float = 1.0) -> void:`
- L157, `place_sprite` (visual): `sprite.scale = impact.size / HEAD_PIXELS.size * multiplier`
- L158, `place_sprite` (visual): `sprite.position = head_position - HEAD_PIXELS.position * sprite.scale`
- L165, `update_visuals` (regla/valor): `shadow.modulate.a = 0.65 if state == State.TRACKING else 1.0`
- L168, `update_visuals` (literal adicional (revisión)): `var progress := clampf(phase_time / 0.45, 0, 1)`
- L169, `update_visuals` (literal adicional (revisión)): `place_sprite(spatula, Vector2(impact.position.x, bottom_y() + 40 - (peek_height + 40) * progress))`
- L171, `update_visuals` (literal adicional (revisión)): `var anticipation_time := minf(maxf(0.01, shadow_anticipation_duration), maxf(0.05, lock_duration))`
- L172, `update_visuals` (literal adicional (revisión)): `var progress := clampf((phase_time - maxf(0.05, lock_duration) + anticipation_time) / anticipation_time, 0, 1)`
- L173, `update_visuals` (literal adicional (revisión)): `place_sprite(spatula, peek_position.lerp(impact.position - Vector2(0, fall_height), progress), lerpf(1, 1.12, progress))`
- L174, `update_visuals` (literal adicional (revisión)): `var anticipation := smoothstep(0.0, 1.0, progress)`
- L175, `update_visuals` (literal adicional (revisión)): `place_shadow(lerpf(1.0, shadow_raised_scale, anticipation))`
- L176, `update_visuals` (literal adicional (revisión)): `shadow.modulate.a = lerpf(1.0, 0.65, anticipation)`
- L178, `update_visuals` (literal adicional (revisión)): `var progress := clampf(phase_time / maxf(0.01, fall_duration), 0, 1)`
- L179, `update_visuals` (literal adicional (revisión)): `place_sprite(spatula, impact.position - Vector2(0, fall_height * (1.0 - progress * progress)), lerpf(1.12, 1, progress))`
- L180, `update_visuals` (literal adicional (revisión)): `place_shadow(lerpf(shadow_raised_scale, 1.0, progress * progress))`
- L181, `update_visuals` (literal adicional (revisión)): `shadow.modulate.a = lerpf(0.65, 1.0, progress)`
- L184, `update_visuals` (literal adicional (revisión)): `var progress := clampf(phase_time / maxf(0.05, retract_duration), 0, 1)`
- L185, `update_visuals` (literal adicional (revisión)): `place_sprite(spatula, retreat_start.lerp(Vector2(retreat_start.x, maxf(bottom_y(), area.movement_bounds.end.y) + 50), progress))`
- L186, `update_visuals` (literal adicional (revisión)): `shadow.modulate.a = 1.0 - progress`
- L190, `place_shadow` (literal adicional (revisión)): `place_sprite(shadow, impact.get_center() - impact.size * multiplier * 0.5, multiplier)`

## scenes/arena/mechanics/wok_mechanic.gd

45 líneas; 3 anotaciones export; 0 uniforms; 13 candidatos.

### Ya expuesto en el editor

- L4: `@export var safe_zone_bounds := Rect2(-86.328, -101.562, 657.617, 451.953)`
- L5: `@export var maximum_force := 450.0`
- L6: `@export_range(1.0, 3.0) var force_exponent := 1.5`

### Candidatos / evidencia

- L10, `start` (literal adicional (revisión)): `z_index = -2`
- L15, `force_at` (literal adicional (revisión)): `var distance := (offset / (safe_zone_bounds.size * 0.5).max(Vector2.ONE)).length()`
- L16, `force_at` (regla/valor): `if distance <= 1.0: return Vector2.ZERO`
- L17, `force_at` (literal adicional (revisión)): `var outer_distance := ((point - area.movement_bounds.get_center()) / (area.movement_bounds.size * 0.5)).length()`
- L18, `force_at` (literal adicional (revisión)): `var penetration := distance - 1.0`
- L19, `force_at` (literal adicional (revisión)): `var strength := clampf(penetration / maxf(0.01, penetration + maxf(0, 1.0 - outer_distance)), 0, 1)`
- L20, `force_at` (regla/valor): `return -offset.normalized() * maxf(0, maximum_force) * pow(strength, force_exponent)`
- L32, `apply_force` (regla/valor): `if unit is Enemy and unit.get_movement_multiplier()<=0.0: return`
- L39, `_draw` (literal adicional (revisión)): `var radii := safe_zone_bounds.size * 0.5`
- L40, `_draw` (literal adicional (revisión)): `for step in 8:`
- L41, `_draw` (regla/valor): `var direction := Vector2.from_angle(TAU * step / 8.0)`
- L42, `_draw` (literal adicional (revisión)): `var at := center + direction * radii * 1.12`
- L45, `_draw` (literal adicional (revisión)): `draw_polyline(PackedVector2Array([at - inward * 10 + side * 10, at + inward * 8, at - inward * 10 - side * 10]), Color(1, 0.9, 0.65, 0.35), 4, true)`

## scenes/arena/music_player.gd

36 líneas; 6 anotaciones export; 0 uniforms; 3 candidatos.

Hallazgos: AUDIO-03.

### Ya expuesto en el editor

- L3: `@export_group("Music")`
- L4: `@export var menu_music: AudioStream`
- L5: `@export var shop_music: AudioStream`
- L6: `@export var wave_music_tracks: Array[AudioStream] = []`
- L7: `@export var boss_music_tracks: Array[AudioStream] = []`
- L8: `@export_group("")`

### Candidatos / evidencia

- L9, `declaración` (literal adicional (revisión)): `var context := ""`
- L26, `choose_music` (regla/valor): `var sources: Array = []`
- L31, `choose_music` (regla/valor): `var valid: Array[AudioStream] = []`

## scenes/arena/spawner.gd

411 líneas; 17 anotaciones export; 0 uniforms; 107 candidatos.

Hallazgos: WORLD-01, WORLD-02.

### Ya expuesto en el editor

- L4: `@export_range(0.0, 150.0) var spawn_relocation_distance := 70.0`
- L11: `@export var waves_data: Array[WaveData]`
- L12: `@export var spawn_area_size := Vector2(1000, 500)`
- L13: `@export var min_spawn_distance := 120.0`
- L14: `@export_flags_2d_physics var obstacle_mask := 1`
- L15: `@export_range(1, 500) var max_alive_enemies := 500`
- L16: `@export var debug_enabled := false`
- L17: `@export_range(1, 100) var debug_start_wave := 1`
- L18: `@export_range(0.1, 5.0) var debug_density := 1.0`
- L19: `@export_range(0.1, 8.0) var debug_time_scale := 1.0`
- L20: `@export var debug_invulnerable := false`
- L21: `@export_group("Temporary crowd test")`
- L22: `@export var temporary_crowd_test := true`
- L23: `@export_range(1.0, 10.0) var test_heavy_health_multiplier := 4.0`
- L24: `@export_group("Temporary reward test")`
- L25: `@export var temporary_reward_test := true`
- L26: `@export_range(1.0, 100.0) var test_health_per_experience := 10.0`

### Candidatos / evidencia

- L10, `declaración` (constante): `const DIFFICULTY_RULES = preload("res://resources/difficulty_rules.gd")`
- L29, `declaración` (regla/valor): `var wave_index := 1`
- L31, `declaración` (regla/valor): `var spawned_enemies: Array[Enemy] = []`
- L32, `declaración` (regla/valor): `var special_enemies: Array[Enemy] = []`
- L33, `declaración` (regla/valor): `var boss_enemies: Array[Enemy] = []`
- L34, `declaración` (regla/valor): `var reward_enemies: Array[Enemy] = []`
- L35, `declaración` (regla/valor): `var difficulty_index := 0:`
- L37, `declaración` (regla/valor): `var spawn_generation := 0`
- L38, `declaración` (regla/valor): `var pending_spawns := 0`
- L39, `declaración` (regla/valor): `var pending_population := [0, 0, 0, 0]`
- L40, `declaración` (regla/valor): `var total_spawned := 0`
- L41, `declaración` (regla/valor): `var generated_by_type: Dictionary = {}`
- L42, `declaración` (regla/valor): `var active_groups: Array[Dictionary] = []`
- L43, `declaración` (regla/valor): `var scheduled_events: Array[Dictionary] = []`
- L56, `_ready` (regla/valor): `if arg.begins_with("--wave="): debug_start_wave = maxi(1, int(arg.get_slice("=", 1))); debug_enabled = true`
- L57, `_ready` (regla/valor): `if arg.begins_with("--density="): debug_density = clampf(float(arg.get_slice("=", 1)), 0.1, 5.0); debug_enabled = true`
- L58, `_ready` (visual): `if arg.begins_with("--speed="): debug_time_scale = clampf(float(arg.get_slice("=", 1)), 0.1, 8.0); debug_enabled = true`
- L59, `_ready` (literal adicional (revisión)): `if arg == "--invulnerable": debug_invulnerable = true; debug_enabled = true`
- L61, `_ready` (texto): `var layer=load("res://scenes/arena/spawner_debug_ui.tscn").instantiate()`
- L68, `_process` (texto): `debug_label.text = "DEBUG Wave %d | common %d/%d + %d pending\nHazards %d | bosses %d | generated %d\nGroups: %s | density %.2f | time %.2f" % [wave_index, info.common, info.limit, pending_population[0], info.hazards, info.bosses, total_spawned, ", ".join(info.groups), debug_density, Engine.time_scale]`
- L71, `last_wave_number` (regla/valor): `var last := 0`
- L91, `start_wave` (literal adicional (revisión)): `total_spawned = 0`
- L108, `start_wave` (literal adicional (revisión)): `total_spawned = 0`
- L111, `start_wave` (regla/valor): `var groups: Array[SpawnGroup] = []`
- L118, `start_wave` (literal adicional (revisión)): `active_groups.append({"group": group, "next": group.start_second, "executions": 0, "pending": 0, "completed": 0, "active": true})`
- L122, `start_wave` (literal adicional (revisión)): `scheduled_events.append({"event":event,"pending":0,"completed":0})`
- L124, `start_wave` (literal adicional (revisión)): `wave_timer.start(maxf(0.1, current_wave_data.wave_time))`
- L131, `start_spawn_timer` (literal adicional (revisión)): `spawn_timer.start(0.1)`
- L140, `scheduler_tick` (literal adicional (revisión)): `for index in maxi(0, missing):`
- L148, `scheduler_tick` (regla/valor): `if (group.duration >= 0.0 and elapsed > group.start_second + group.duration) or (group.repetitions >= 0 and (state.completed if group.guaranteed else state.executions) >= group.repetitions):`
- L151, `scheduler_tick` (regla/valor): `if elapsed < state.next or (group.guaranteed and state.pending > 0): continue`
- L153, `scheduler_tick` (regla/valor): `var density := debug_density if OS.is_debug_build() and debug_enabled and not group.guaranteed else 1.0`
- L155, `scheduler_tick` (texto): `state.next = elapsed + maxf(group.minimum_interval, group.interval_at(elapsed) / (density * difficulty_density * (Global.player.stats.final_multiplier("enemy_count") if is_instance_valid(Global.player) and not group.guaranteed else 1.0)))`
- L156, `scheduler_tick` (regla/valor): `state.executions += 1`
- L157, `scheduler_tick` (regla/valor): `var count := randi_range(maxi(1, group.minimum_count), maxi(group.minimum_count, group.maximum_count))`
- L160, `scheduler_tick` (regla/valor): `if school_profile: spawn_school(school_profile, count, Vector2.INF, group.school_radius, state)`
- L165, `scheduler_tick` (regla/valor): `var members := test_profile_count(profile) if group.affected_by_density else 1`
- L166, `scheduler_tick` (texto): `if group.school_probability > 0.0 and randf() < group.school_probability and profile.id in [&"chaser_mini", &"chaser_mid", &"chaser_fast"]:`
- L174, `test_wave_multiplier` (regla/valor): `if current_wave_data and current_wave_data.density_multiplier > 0: return current_wave_data.density_multiplier`
- L175, `test_wave_multiplier` (regla/valor): `return clampi(wave_index, 1, 5) if temporary_crowd_test else 1`
- L179, `test_profile_count` (texto): `return test_wave_multiplier() if profile.population == 0 and profile.id != &"chaser_slow" else 1`
- L182, `population_count` (regla/valor): `var list: Array[Enemy] = spawned_enemies if population == 0 else special_enemies if population == 1 else boss_enemies if population == 2 else reward_enemies`
- L183, `population_count` (regla/valor): `var alive := 0`
- L184, `population_count` (literal adicional (revisión)): `for i in range(list.size() - 1, -1, -1):`
- L187, `population_count` (regla/valor): `elif enemy.health_component.current_health > 0.0 and not enemy.is_retiring: alive += 1`
- L191, `alive_enemy_count` (regla/valor): `return population_count(0)`
- L194, `population_limit` (regla/valor): `if not current_wave_data: return 0`
- L195, `population_limit` (regla/valor): `return mini(max_alive_enemies, current_wave_data.common_limit * test_wave_multiplier()) if population == 0 else current_wave_data.hazard_limit if population == 1 else current_wave_data.boss_limit if population == 2 else current_wave_data.reward_limit`
- L202, `get_random_spawn_position` (visual): `return Vector2(randf_range(-spawn_area_size.x, spawn_area_size.x), randf_range(-spawn_area_size.y, spawn_area_size.y))`
- L206, `is_spawn_position_safe` (visual): `var margin := profile.spawn_margin * profile.visual_scale if profile else 80.0`
- L213, `is_spawn_geometry_valid` (visual): `var margin := profile.spawn_margin * profile.visual_scale if profile else 80.0`
- L214, `is_spawn_geometry_valid` (literal adicional (revisión)): `for step in 16:`
- L215, `is_spawn_geometry_valid` (literal adicional (revisión)): `var sample := point + Vector2.from_angle(TAU * step / 16.0) * margin`
- L218, `is_spawn_geometry_valid` (visual): `elif not Rect2(-spawn_area_size, spawn_area_size * 2.0).has_point(sample): return false`
- L223, `is_spawn_geometry_valid` (literal adicional (revisión)): `query.transform = Transform2D(0.0, point)`
- L226, `is_spawn_geometry_valid` (regla/valor): `return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()`
- L229, `matches_spawn_zone` (regla/valor): `if zone == 0: return true`
- L236, `matches_spawn_zone` (regla/valor): `return clearance <= edge_width if zone == 1 else clearance > edge_width`
- L240, `_state_spawn_zone` (regla/valor): `return settings.spawn_zone if settings else 0`
- L244, `_state_edge_width` (regla/valor): `return settings.edge_width if settings else 200.0`
- L249, `get_safe_spawn_position` (literal adicional (revisión)): `func get_safe_spawn_position(profile: EnemyProfile = null, zone: int = 0, edge_width: float = 200.0) -> Vector2:`
- L250, `get_safe_spawn_position` (literal adicional (revisión)): `for attempt in 128:`
- L253, `get_safe_spawn_position` (regla/valor): `return Vector2.INF`
- L258, `prepare_enemy` (literal adicional (revisión)): `var elapsed := maxi(0, wave_index - 1)`
- L260, `prepare_enemy` (regla/valor): `var hp_growth := profile.health_growth_multiplier if profile else 1.0`
- L261, `prepare_enemy` (regla/valor): `var damage_growth := profile.damage_growth_multiplier if profile else 1.0`
- L262, `prepare_enemy` (visual): `scaled.health = maxf(1.0, (base.initial_health + base.health_increase_per_wave * elapsed * hp_growth) * multiplier * (current_wave_data.health_multiplier if current_wave_data else 1.0))`
- L263, `prepare_enemy` (visual): `scaled.damage = maxf(0.0, (base.initial_damage + base.damage_increase_per_wave * elapsed * damage_growth) * multiplier * (current_wave_data.damage_multiplier if current_wave_data else 1.0))`
- L264, `prepare_enemy` (visual): `scaled.speed = maxf(0.0, base.speed + (profile.speed_growth_per_wave * elapsed if profile else 0.0)) * (current_wave_data.speed_multiplier if current_wave_data else 1.0)`
- L268, `prepare_enemy` (regla/valor): `if temporary_reward_test and profile and profile.population not in [1,3]:`
- L269, `prepare_enemy` (literal adicional (revisión)): `scaled.coin_drop = 1`
- L270, `prepare_enemy` (literal adicional (revisión)): `scaled.experience_reward = maxi(1, ceili(scaled.health / maxf(1.0, test_health_per_experience)))`
- L275, `prepare_enemy` (regla/valor): `shooting.damage_multiplier = multiplier * (current_wave_data.damage_multiplier if current_wave_data else 1.0) * damage_growth`
- L279, `prepare_enemy` (literal adicional (revisión)): `instance.knockback_resistance = clampf((profile.knockback_resistance + profile.resistance_growth_per_wave * elapsed) * current_wave_data.resistance_multiplier, 0.0, 1.0)`
- L288, `spawn_school` (literal adicional (revisión)): `func spawn_school(profile: EnemyProfile, count: int = 10, center: Vector2 = Vector2.INF, spread_radius: float = 140.0, state: Dictionary = {}) -> int:`
- L289, `spawn_school` (texto): `if not profile or not profile.is_valid() or profile.population != 0 or profile.id not in [&"chaser_mini", &"chaser_fast", &"chaser_mid"]: return 0`
- L290, `spawn_school` (regla/valor): `if Global.game_paused or not current_wave_data or wave_timer.is_stopped() or count <= 0: return 0`
- L292, `spawn_school` (regla/valor): `if not center.is_finite(): return 0`
- L293, `spawn_school` (regla/valor): `var admitted := 0`
- L294, `spawn_school` (literal adicional (revisión)): `var available := maxi(0, population_limit(0) - population_count(0) - pending_population[0])`
- L297, `spawn_school` (literal adicional (revisión)): `var point := center + Vector2.from_angle(index * 2.399963) * sqrt((index + 0.5) / maxf(1, desired)) * maxf(0, spread_radius)`
- L300, `spawn_school` (literal adicional (revisión)): `for attempt in 24:`
- L301, `spawn_school` (literal adicional (revisión)): `point = center + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * maxf(0, spread_radius)`
- L305, `spawn_school` (regla/valor): `admitted += 1`
- L311, `_spawn_profile_at` (regla/valor): `pending_spawns += 1`
- L312, `_spawn_profile_at` (regla/valor): `pending_population[profile.population] += 1`
- L313, `_spawn_profile_at` (regla/valor): `if not state.is_empty(): state.pending += 1`
- L326, `_spawn_profile_at` (literal adicional (revisión)): `pending_spawns -= 1`
- L327, `_spawn_profile_at` (literal adicional (revisión)): `pending_population[profile.population] -= 1`
- L328, `_spawn_profile_at` (regla/valor): `if not state.is_empty(): state.pending -= 1`
- L334, `_spawn_profile_at` (regla/valor): `if profile.population == 0: spawned_enemies.append(enemy)`
- L335, `_spawn_profile_at` (regla/valor): `elif profile.population == 1: special_enemies.append(enemy)`
- L336, `_spawn_profile_at` (regla/valor): `elif profile.population == 2: boss_enemies.append(enemy)`
- L338, `_spawn_profile_at` (regla/valor): `total_spawned += 1`
- L339, `_spawn_profile_at` (literal adicional (revisión)): `generated_by_type[profile.id] = int(generated_by_type.get(profile.id, 0)) + 1`
- L340, `_spawn_profile_at` (regla/valor): `if not state.is_empty(): state.completed += 1`
- L344, `spawn_enemy` (literal adicional (revisión)): `var profile := current_wave_data.groups[0].select_enemy()`
- L356, `clear_enemies` (regla/valor): `spawn_generation += 1`
- L357, `clear_enemies` (literal adicional (revisión)): `Engine.time_scale = 1.0`
- L358, `clear_enemies` (literal adicional (revisión)): `pending_spawns = 0`
- L359, `clear_enemies` (literal adicional (revisión)): `pending_population = [0, 0, 0, 0]`
- L375, `debug_snapshot` (regla/valor): `var labels: Array[String] = []`
- L376, `debug_snapshot` (regla/valor): `var elapsed := current_wave_data.wave_time - wave_timer.time_left if current_wave_data else 0.0`
- L379, `debug_snapshot` (texto): `return {"common": population_count(0), "limit": population_limit(0), "hazards": population_count(1), "bosses": population_count(2), "rewards": population_count(3), "generated": total_spawned, "groups": labels, "pending": pending_spawns}`
- L394, `reset_run` (literal adicional (revisión)): `Engine.time_scale = 1.0`
- L395, `reset_run` (regla/valor): `wave_index = clampi(debug_start_wave, 1, last_wave_number()) if OS.is_debug_build() and debug_enabled else 1`
- L410, `_on_wave_timer_timeout` (literal adicional (revisión)): `Engine.time_scale = 1.0`

## scenes/arena/stress_test.gd

79 líneas; 5 anotaciones export; 0 uniforms; 21 candidatos.

Hallazgos: DEV-03.

### Ya expuesto en el editor

- L3: `@export var target_population := 1000`
- L4: `@export var batch_size := 5`
- L5: `@export var batch_interval := 0.1`
- L6: `@export var spawn_per_frame := 1`
- L7: `@export_range(0,1,0.01) var yolk_attraction_chance := 1.0`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var enemies: Array[Enemy] = []`
- L11, `declaración` (regla/valor): `var total_spawned := 0`
- L12, `declaración` (regla/valor): `var pending := 0`
- L13, `declaración` (regla/valor): `var batch_left := 0.0`
- L14, `declaración` (regla/valor): `var hud_left := 0.0`
- L16, `declaración` (texto): `var profile: EnemyProfile = preload("res://resources/wave/enemies/chaser_mid.tres")`
- L24, `start` (literal adicional (revisión)): `total_spawned = 0`
- L34, `start` (literal adicional (revisión)): `Engine.time_scale = 1.0`
- L40, `stop` (literal adicional (revisión)): `Global.player.passive_items.debug_yolk_magnet_chance = -1.0`
- L42, `stop` (literal adicional (revisión)): `pending = 0`
- L51, `_process` (regla/valor): `if hud_left <= 0.0:`
- L52, `_process` (regla/valor): `enemies = enemies.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.health_component.current_health > 0)`
- L54, `_process` (literal adicional (revisión)): `hud_left = 0.25`
- L55, `_process` (regla/valor): `if batch_left <= 0.0:`
- L56, `_process` (literal adicional (revisión)): `pending += mini(batch_size,maxi(0,target_population-enemies.size()-pending))`
- L58, `_process` (literal adicional (revisión)): `batch_left = maxf(0.0,batch_left+batch_interval)`
- L61, `_process` (literal adicional (revisión)): `pending = 0`
- L63, `_process` (regla/valor): `if _spawn_enemy(): pending -= 1`
- L71, `_spawn_enemy` (visual): `enemy.position = point`
- L75, `_spawn_enemy` (regla/valor): `total_spawned += 1`
- L79, `_update_hud` (texto): `label.text = "PRUEBA DE ESTRÉS — INMORTAL\nEnemigos: %d / %d   Generados: %d\nFPS: %d   Armas: 6\nAtracción de yemas: %d%%\nPausa: Esc / Start" % [enemies.size(),target_population,total_spawned,Engine.get_frames_per_second(),roundi(yolk_attraction_chance*100)]`

## scenes/bosses/boss_encounter.gd

346 líneas; 0 anotaciones export; 0 uniforms; 108 candidatos.

Hallazgos: BOSS-01, BOSS-07.

### Candidatos / evidencia

- L4, `declaración` (constante): `const PHASE_SECTIONS := [["Static lines","Fixed turrets","Hot zones + Fueguitos"],["Moving lines","Rotating turrets","Intensified lines"],["Complex lines","Combined turrets","Mixed mechanics"]]`
- L6, `declaración` (texto): `var settings: Resource = preload("res://resources/bosses/salchichon.tres")`
- L11, `declaración` (regla/valor): `var phase := 0`
- L14, `declaración` (regla/valor): `var time_left := 0.0`
- L15, `declaración` (regla/valor): `var sections: Array[int] = []`
- L16, `declaración` (regla/valor): `var current_section := 0`
- L17, `declaración` (regla/valor): `var section_history: Array[int] = []`
- L23, `declaración` (regla/valor): `var presentation_clock := 0.0`
- L27, `_ready` (literal adicional (revisión)): `z_index = -1`
- L40, `start` (texto): `hud = load("res://scenes/bosses/boss_health_bar.tscn").instantiate()`
- L49, `start` (texto): `boss.stats.attack_effects.append(preload("res://resources/bosses/boss_burning.tres"))`
- L58, `start` (literal adicional (revisión)): `landing_hit.collision_layer = 0`
- L59, `start` (literal adicional (revisión)): `landing_hit.collision_mask = 0`
- L61, `start` (literal adicional (revisión)): `landing_hit.setup(settings.landing_damage,false,0,boss)`
- L63, `start` (texto): `landing_warning=preload("res://scenes/bosses/landing_warning.tscn").instantiate()`
- L66, `start` (literal adicional (revisión)): `presentation_clock=0.0`
- L67, `start` (literal adicional (revisión)): `phase = 0`
- L73, `start` (regla/valor): `if time_left <= 0: _begin_phase()`
- L94, `_begin_phase` (regla/valor): `if phase == 1 and settings.phase_two_fueguito_enabled:`
- L96, `_begin_phase` (texto): `phase_hazard = load("res://scenes/bosses/phase_fueguito.gd").new()`
- L101, `_begin_phase` (literal adicional (revisión)): `sections.assign([0,1,2])`
- L103, `_begin_phase` (regla/valor): `if phase == 2:`
- L104, `_begin_phase` (literal adicional (revisión)): `sections.erase(2)`
- L105, `_begin_phase` (literal adicional (revisión)): `sections.append(2)`
- L106, `_begin_phase` (regla/valor): `if phase == 0 and settings.test_static_lines_first:`
- L107, `_begin_phase` (literal adicional (revisión)): `sections.assign([0,1,2])`
- L108, `_begin_phase` (regla/valor): `if phase == 1 and settings.test_moving_lines_first:`
- L109, `_begin_phase` (literal adicional (revisión)): `sections.assign([0,1,2])`
- L110, `_begin_phase` (regla/valor): `if phase == 2 and settings.test_complex_lines_first:`
- L111, `_begin_phase` (literal adicional (revisión)): `sections.assign([0,1,2])`
- L119, `_next_section` (literal adicional (revisión)): `section_history.append(phase*3+current_section)`
- L124, `_next_section` (regla/valor): `if phase == 0 and current_section == 0:`
- L125, `_next_section` (texto): `section_runner = load("res://scenes/bosses/static_fire_lines.gd").new()`
- L128, `_next_section` (regla/valor): `elif phase == 0 and current_section == 1:`
- L129, `_next_section` (texto): `section_runner = load("res://scenes/bosses/fixed_turrets.gd").new()`
- L132, `_next_section` (regla/valor): `elif phase == 0 and current_section == 2:`
- L133, `_next_section` (texto): `section_runner = load("res://scenes/bosses/hot_zones_fueguitos.gd").new()`
- L136, `_next_section` (regla/valor): `elif phase == 1 and current_section == 0:`
- L137, `_next_section` (texto): `section_runner = load("res://scenes/bosses/moving_fire_lines.gd").new()`
- L140, `_next_section` (regla/valor): `elif phase == 1 and current_section == 1:`
- L141, `_next_section` (texto): `section_runner = load("res://scenes/bosses/rotating_turrets.gd").new()`
- L144, `_next_section` (regla/valor): `elif phase == 1 and current_section == 2:`
- L145, `_next_section` (texto): `section_runner = load("res://scenes/bosses/intensified_fire_lines.gd").new()`
- L148, `_next_section` (regla/valor): `elif phase == 2 and current_section == 0:`
- L149, `_next_section` (texto): `section_runner = load("res://scenes/bosses/complex_fire_lines.gd").new()`
- L152, `_next_section` (regla/valor): `elif phase == 2 and current_section == 1:`
- L153, `_next_section` (texto): `section_runner = load("res://scenes/bosses/mobile_rotating_turrets.gd").new()`
- L156, `_next_section` (regla/valor): `elif phase == 2 and current_section == 2:`
- L157, `_next_section` (texto): `section_runner = load("res://scenes/bosses/mixed_mechanics.gd").new()`
- L173, `_process` (literal adicional (revisión)): `var section_delta := minf(delta,maxf(0,time_left))`
- L177, `_process` (regla/valor): `if time_left <= 0: _begin_phase()`
- L180, `_process` (regla/valor): `if time_left<=0: _next_section()`
- L182, `_process` (regla/valor): `if time_left<=0:`
- L188, `_process` (literal adicional (revisión)): `var progress := clampf(1.0-time_left/settings.fall_seconds,0,1)`
- L189, `_process` (literal adicional (revisión)): `boss.set_fall_offset(settings.fall_height*(1.0-progress*progress))`
- L190, `_process` (regla/valor): `if time_left<=0: _land()`
- L192, `_process` (regla/valor): `if time_left<=0:`
- L195, `_process` (regla/valor): `sections.assign([randi_range(0,2)])`
- L198, `_process` (literal adicional (revisión)): `var age: float = settings.takeoff_anticipation_seconds+settings.takeoff_jump_seconds-maxf(0,time_left)`
- L200, `_process` (literal adicional (revisión)): `var progress: float = smoothstep(0,1,age/maxf(0.001,settings.takeoff_anticipation_seconds))`
- L201, `_process` (literal adicional (revisión)): `boss.set_takeoff_pose(1.0-settings.takeoff_compression*progress,0)`
- L203, `_process` (literal adicional (revisión)): `var progress: float = clampf((age-settings.takeoff_anticipation_seconds)/maxf(0.001,settings.takeoff_jump_seconds),0,1)`
- L207, `_process` (literal adicional (revisión)): `var stretch: float = lerpf(1.0-settings.takeoff_compression,1.1,smoothstep(0,0.3,progress))`
- L209, `_process` (regla/valor): `if time_left<=0: _finish_takeoff()`
- L211, `_process` (regla/valor): `if time_left<=0:`
- L226, `_begin_departure` (literal adicional (revisión)): `boss.set_takeoff_pose(1,0)`
- L227, `_begin_departure` (regla/valor): `if time_left<=0: _finish_takeoff()`
- L230, `_finish_takeoff` (literal adicional (revisión)): `boss.set_takeoff_pose(1,0)`
- L235, `_finish_takeoff` (regla/valor): `if time_left<=0:`
- L243, `_land` (literal adicional (revisión)): `boss.set_fall_offset(0)`
- L245, `_land` (texto): `var blast: Node2D = preload("res://scenes/bosses/landing_blast.tscn").instantiate()`
- L248, `_land` (visual): `blast.position=to_local(landing_center())`
- L257, `_land` (literal adicional (revisión)): `for index in 64:`
- L258, `_land` (literal adicional (revisión)): `points.append(Vector2(cos(TAU*index/64.0),sin(TAU*index/64.0)*landing_y_ratio())*landing_radius())`
- L262, `_land` (literal adicional (revisión)): `query.transform = Transform2D(0,landing_center())`
- L263, `_land` (literal adicional (revisión)): `query.collision_mask = 32`
- L269, `_land` (literal adicional (revisión)): `arena.get_node("Camera2D").start_shake(5,0.15)`
- L271, `landing_radius` (visual): `return boss.shadow_world_rect().size.x*0.5*settings.landing_radius_multiplier`
- L274, `landing_y_ratio` (visual): `return size.y/maxf(size.x,0.001)`
- L285, `_phase_cleared` (regla/valor): `if phase < 2:`
- L286, `_phase_cleared` (regla/valor): `phase += 1`
- L292, `_phase_cleared` (texto): `hud.status.text = "BOSS DEFEATED — TEST COMPLETE" if arena.boss_test_mode else "BOSS DEFEATED"`
- L298, `_update_status` (regla/valor): `var title := "%s · PHASE %d/3" % [settings.boss_name,phase+1]`
- L300, `_update_status` (texto): `State.INTRO: hud.status.text = "%s · STARTING IN %.1f s" % [title,maxf(0,time_left)]`
- L301, `_update_status` (texto): `State.WARNING,State.FALLING: hud.status.text = "%s · LEAVE THE MARKED ZONE" % title`
- L302, `_update_status` (texto): `State.VULNERABLE: hud.status.text = "%s · VULNERABLE" % title`
- L303, `_update_status` (texto): `_: hud.status.text = title`
- L305, `_update_status` (texto): `var prefix := "BOSS TEST · PHASE %d/3" % (phase+1)`
- L307, `_update_status` (texto): `State.TAKEOFF: hud.status.text = "%s · BOSS LEAVING" % prefix`
- L308, `_update_status` (texto): `State.DEPARTURE: hud.status.text = "%s · NEXT ATTACK IN %.1f s" % [prefix,maxf(0,time_left)]`
- L309, `_update_status` (texto): `State.INTRO: hud.status.text = "BOSS TEST · STARTING IN %.1f s" % maxf(0,time_left)`
- L311, `_update_status` (regla/valor): `if current_section == 1 and phase in [0,1,2] and is_instance_valid(section_runner):`
- L312, `_update_status` (texto): `var turret_label: String = ["FIXED TURRETS","ROTATING TURRETS","MIXED TURRETS"][phase]`
- L313, `_update_status` (texto): `hud.status.text = "%s · %s · %d · %.1f s" % [prefix,turret_label,section_runner.turrets.size(),maxf(0,time_left)]`
- L314, `_update_status` (regla/valor): `elif current_section == 2 and phase == 0 and is_instance_valid(section_runner):`
- L315, `_update_status` (texto): `hud.status.text = "%s · HOT ZONES %d · FUEGUITOS %d · %.1f s" % [prefix,section_runner.zones().size(),section_runner.hazards.size(),maxf(0,time_left)]`
- L316, `_update_status` (regla/valor): `elif phase == 1 and current_section == 0 and is_instance_valid(section_runner):`
- L317, `_update_status` (texto): `var mode: String = ["WARNING","ACTIVE","REST"][maxi(0,section_runner.stage)]`
- L318, `_update_status` (texto): `hud.status.text = "%s · MOVING LINES %d · %s · %.1f s" % [prefix,section_runner.attack_index+1,mode,maxf(0,time_left)]`
- L320, `_update_status` (texto): `var mode: String = ["WARNING","ACTIVE","REST"][maxi(0,section_runner.stage)]`
- L321, `_update_status` (texto): `hud.status.text = "%s · %s · %s · %.1f s" % [prefix,section_runner.current_label,mode,maxf(0,time_left)]`
- L323, `_update_status` (texto): `hud.status.text = "%s · SIMULATED: %s · %.1f s" % [prefix,PHASE_SECTIONS[phase][current_section],maxf(0,time_left)]`
- L324, `_update_status` (texto): `State.WARNING,State.FALLING: hud.status.text = "%s · LANDING — LEAVE THE MARKED ZONE" % prefix`
- L325, `_update_status` (texto): `State.VULNERABLE: hud.status.text = "%s · VULNERABLE · %.1f s" % [prefix,maxf(0,time_left)]`
- L331, `_update_landing_warning` (visual): `landing_warning.scale=Vector2(landing_radius()*2,landing_radius()*2*landing_y_ratio())`
- L332, `_update_landing_warning` (texto): `landing_warning.material.set_shader_parameter("phase",presentation_clock)`
- L333, `_update_landing_warning` (texto): `landing_warning.material.set_shader_parameter("world_length",landing_radius()*2)`
- L334, `_update_landing_warning` (texto): `landing_warning.material.set_shader_parameter("warning_progress",clampf(1-time_left/settings.landing_warning_seconds,0,1) if state==State.WARNING else 1.0)`

## scenes/bosses/boss_health_bar.gd

19 líneas; 0 anotaciones export; 0 uniforms; 2 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var phase := 0`
- L12, `show_boss` (texto): `caption.text = title`

## scenes/bosses/boss_health_component.gd

25 líneas; 0 anotaciones export; 0 uniforms; 4 candidatos.

Hallazgos: BOSS-02.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var health_floor := 0.0`
- L8, `open_window` (literal adicional (revisión)): `health_floor = max_health * float(2 - phase) / 3.0`
- L12, `take_damage` (regla/valor): `if not vulnerable or value <= 0 or current_health <= health_floor: return`
- L16, `take_damage` (regla/valor): `if current_health <= health_floor + 0.00001 and not floor_reported:`

## scenes/bosses/complex_fire_lines.gd

95 líneas; 0 anotaciones export; 0 uniforms; 27 candidatos.

Hallazgos: BOSS-03.

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var elapsed := 0.0`
- L8, `declaración` (regla/valor): `var attack_index := -1`
- L9, `declaración` (regla/valor): `var attack_kind := -1 # 0 static, 1 moving`
- L12, `declaración` (regla/valor): `var stage := 0`
- L13, `declaración` (texto): `var current_label := "Complex lines"`
- L14, `declaración` (regla/valor): `var history: Array[int] = []`
- L15, `declaración` (visual): `var forced_kind := -1 # Single-attack composition; normal sections keep -1.`
- L27, `setup` (literal adicional (revisión)): `advance(0)`
- L30, `roll_kind` (regla/valor): `if forced_kind >= 0: return forced_kind`
- L31, `roll_kind` (regla/valor): `if not history.is_empty() and history.back() == 1: return 0`
- L32, `roll_kind` (regla/valor): `return 0 if random.randf()<0.5 else 1`
- L36, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L37, `advance` (regla/valor): `if elapsed >= config.section_seconds-0.0000001:`
- L40, `advance` (literal adicional (revisión)): `var index := int(floor((elapsed+0.0000001)/config.complex_line_interval))`
- L43, `advance` (literal adicional (revisión)): `var local_time: float = maxf(0,elapsed-index*config.complex_line_interval)`
- L44, `advance` (literal adicional (revisión)): `attack.advance(maxf(0,local_time-attack.elapsed))`
- L54, `_begin_attack` (regla/valor): `if attack_kind == 0:`
- L56, `_begin_attack` (literal adicional (revisión)): `var scale_time: float = config.complex_line_interval/maxf(0.001,cycle)`
- L61, `_begin_attack` (visual): `var patterns: Array[Resource] = [config.static_line_patterns[random.randi_range(0,config.static_line_patterns.size()-1)]]`
- L63, `_begin_attack` (texto): `attack = load("res://scenes/bosses/static_fire_lines.gd").new()`
- L64, `_begin_attack` (literal adicional (revisión)): `current_label = "Complex lines · Static grid"`
- L66, `_begin_attack` (regla/valor): `var directions: Array[Vector2] = []`
- L70, `_begin_attack` (visual): `var direction := directions[random.randi_range(0,directions.size()-1)] if not directions.is_empty() else Vector2.UP`
- L75, `_begin_attack` (literal adicional (revisión)): `settings.moving_line_triple_from = 1`
- L79, `_begin_attack` (texto): `attack = load("res://scenes/bosses/moving_fire_lines.gd").new()`
- L80, `_begin_attack` (literal adicional (revisión)): `current_label = "Complex lines · Moving parallels"`
- L93, `stop` (literal adicional (revisión)): `stage = 2`

## scenes/bosses/fixed_turrets.gd

186 líneas; 0 anotaciones export; 0 uniforms; 45 candidatos.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L7, `declaración` (regla/valor): `var last_batch := -1`
- L9, `declaración` (regla/valor): `var turrets: Array[Dictionary] = []`
- L12, `declaración` (regla/valor): `var ray_offset := Vector2.ZERO`
- L13, `declaración` (regla/valor): `var contact_radius := 42.0`
- L28, `setup` (texto): `indicators = load("res://scenes/bosses/turret_edge_indicators.gd").new()`
- L33, `setup` (literal adicional (revisión)): `advance(0)`
- L37, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L48, `advance` (literal adicional (revisión)): `for index in range(last_batch+1,batch+1):`
- L55, `advance` (regla/valor): `var mode := 0 if age < config.turret_warning_seconds else 1`
- L57, `advance` (literal adicional (revisión)): `turret.beams.animate_lines(age,clampf(age/config.turret_warning_seconds,0,1))`
- L65, `_spawn_batch` (literal adicional (revisión)): `for slot in 3:`
- L66, `_spawn_batch` (literal adicional (revisión)): `var fraction: Vector2 = config.turret_positions[(batch*3+slot)%config.turret_positions.size()]`
- L68, `_spawn_batch` (regla/valor): `var diagonal := (batch+slot)%2==1`
- L69, `_spawn_batch` (regla/valor): `if slot == 0 and config.turret_target_player and is_instance_valid(Global.nearest_player(area.movement_bounds.get_center())):`
- L79, `_aimed_position` (regla/valor): `var angle := PI*0.25 if diagonal else 0.0`
- L80, `_aimed_position` (literal adicional (revisión)): `for offset in [0.0,PI*0.5]:`
- L81, `_aimed_position` (regla/valor): `var direction := Vector2.from_angle(angle+offset)`
- L89, `_aimed_position` (literal adicional (revisión)): `for iteration in 24:`
- L90, `_aimed_position` (literal adicional (revisión)): `var middle := inside.lerp(outside,0.5)`
- L94, `_aimed_position` (regla/valor): `if candidate.distance_to(target) < clearance-0.01: continue`
- L103, `_spawn_is_safe` (regla/valor): `return Global.players_clear_of(point,config.turret_spawn_min_distance-0.01)`
- L110, `_safe_spawn_position` (literal adicional (revisión)): `for ring in [1.01,1.5,2.0]:`
- L111, `_safe_spawn_position` (literal adicional (revisión)): `for index in 32:`
- L112, `_safe_spawn_position` (literal adicional (revisión)): `var candidate := area.clamp_position(Global.nearest_player(area.movement_bounds.get_center()).global_position+Vector2.from_angle(TAU*index/32.0)*config.turret_spawn_min_distance*ring)`
- L117, `_safe_spawn_position` (literal adicional (revisión)): `for x in 17:`
- L118, `_safe_spawn_position` (literal adicional (revisión)): `for y in 17:`
- L119, `_safe_spawn_position` (literal adicional (revisión)): `var candidate := area.clamp_position(area.movement_bounds.position+area.movement_bounds.size*Vector2(x/16.0,y/16.0))`
- L129, `_spawn_turret` (visual): `body.position = position_world`
- L136, `_spawn_turret` (literal adicional (revisión)): `contact.setup(config.turret_contact_damage,false,0,source)`
- L138, `_spawn_turret` (texto): `var beams = load("res://scenes/bosses/static_fire_lines.gd").new()`
- L144, `_spawn_turret` (regla/valor): `var angle := PI*0.25 if diagonal else 0.0`
- L145, `_spawn_turret` (literal adicional (revisión)): `for offset in [0.0,PI*0.5]:`
- L146, `_spawn_turret` (regla/valor): `var direction := Vector2.from_angle(angle+offset)`
- L151, `_edge` (texto): `var bounds := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),config.laser_end_overscan)`
- L153, `_edge` (regla/valor): `if direction.x > 0.00001: distance = minf(distance,(bounds.end.x-origin.x)/direction.x)`
- L154, `_edge` (visual): `elif direction.x < -0.00001: distance = minf(distance,(bounds.position.x-origin.x)/direction.x)`
- L155, `_edge` (regla/valor): `if direction.y > 0.00001: distance = minf(distance,(bounds.end.y-origin.y)/direction.y)`
- L156, `_edge` (visual): `elif direction.y < -0.00001: distance = minf(distance,(bounds.position.y-origin.y)/direction.y)`
- L157, `_edge` (regla/valor): `return origin+direction*maxf(0,distance)`
- L160, `_remove_turret` (literal adicional (revisión)): `turret.contact.damage = 0`
- L161, `_remove_turret` (literal adicional (revisión)): `turret.contact.base_damage = 0`
- L162, `_remove_turret` (literal adicional (revisión)): `turret.contact.collision_layer = 0`
- L185, `_animate_band` (texto): `turret.sprite.material.set_shader_parameter("phase",age)`
- L186, `_animate_band` (texto): `turret.sprite.material.set_shader_parameter("firing",float(mode==1))`

## scenes/bosses/hot_zones_fueguitos.gd

119 líneas; 0 anotaciones export; 0 uniforms; 25 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var elapsed := 0.0`
- L7, `declaración` (regla/valor): `var next_fueguito := 0.0`
- L9, `declaración` (regla/valor): `var zone_batch := -1`
- L10, `declaración` (regla/valor): `var births := 0`
- L20, `setup` (literal adicional (revisión)): `batch_size = 1`
- L21, `setup` (texto): `griddle = load("res://scenes/arena/mechanics/griddle_mechanic.tscn").instantiate()`
- L27, `setup` (literal adicional (revisión)): `griddle.active_duration = maxf(0.05,config.hot_zone_interval-griddle.warning_duration-griddle.cooling_duration)`
- L33, `setup` (literal adicional (revisión)): `advance(0)`
- L37, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L41, `advance` (literal adicional (revisión)): `for zone in zones(): zone._process(maxf(0,delta))`
- L42, `advance` (regla/valor): `if pending > 0 and elapsed >= materialize_at: materialize_batch()`
- L47, `advance` (regla/valor): `if pending > 0 and elapsed >= materialize_at: materialize_batch()`
- L53, `advance` (literal adicional (revisión)): `for attempt in config.hot_zone_count*3:`
- L57, `advance` (texto): `zone.damage_hitbox.status_effects.append(preload("res://resources/bosses/boss_burning.tres"))`
- L60, `advance` (literal adicional (revisión)): `separate_hazards(maxf(0,delta))`
- L63, `zones` (regla/valor): `var result: Array[Node] = []`
- L76, `materialize_batch` (literal adicional (revisión)): `enemy.stats.coin_drop = 0`
- L77, `materialize_batch` (literal adicional (revisión)): `enemy.stats.experience_reward = 0`
- L86, `materialize_batch` (regla/valor): `births += 1`
- L88, `materialize_batch` (literal adicional (revisión)): `pending = 0`
- L95, `_clear_zones` (literal adicional (revisión)): `zone.damage_hitbox.damage = 0`
- L96, `_clear_zones` (literal adicional (revisión)): `zone.damage_hitbox.base_damage = 0`
- L109, `stop` (literal adicional (revisión)): `enemy.get_node("HitboxComponent").damage = 0`
- L110, `stop` (literal adicional (revisión)): `enemy.get_node("HitboxComponent").collision_layer = 0`
- L113, `stop` (texto): `var flare=preload("res://scenes/arena/mechanics/flame_transition.gd").new()`

## scenes/bosses/intensified_fire_lines.gd

27 líneas; 0 anotaciones export; 0 uniforms; 5 candidatos.

### Candidatos / evidencia

- L6, `setup` (literal adicional (revisión)): `var ratio: float = settings.intensified_line_interval/maxf(0.001,original_cycle)`
- L10, `setup` (regla/valor): `var patterns: Array[Resource] = []`
- L13, `setup` (literal adicional (revisión)): `pattern.label = "Intensified · "+original.label`
- L22, `_thin_positions` (literal adicional (revisión)): `var count := clampi(roundi(positions.size()*density),1,positions.size())`
- L25, `_thin_positions` (visual): `var sample: int = roundi(index*float(positions.size()-1)/float(count-1)) if count>1 else int(positions.size()/2)`

## scenes/bosses/landing_blast.gd

25 líneas; 4 anotaciones export; 0 uniforms; 6 candidatos.

### Ya expuesto en el editor

- L3: `@export var visual_radius := 140.0`
- L4: `@export var y_ratio := 0.6`
- L5: `@export var duration := 0.3`
- L6: `@export var flash_seconds := 0.1`

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var elapsed := 0.0`
- L12, `_ready` (texto): `var settings: Resource = load("res://resources/items/weapons/spicy/stats_scotch_bonnet.tres").spicy_pattern.duplicate()`
- L15, `_ready` (texto): `blast=load("res://effects/scotch_mine_visual.gd").new()`
- L18, `_ready` (literal adicional (revisión)): `blast.update_visual(0,true,0)`
- L19, `_ready` (visual): `$Flash.scale=Vector2(visual_radius*3.0,visual_radius*3.0*y_ratio)`
- L24, `_process` (texto): `$Flash.material.set_shader_parameter("progress",clampf(elapsed/flash_seconds,0,1))`

## scenes/bosses/laser_bounds.gd

8 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L4, `for_view` (visual): `var bounds := Rect2(area.background_offset-area.background_size*0.5,area.background_size)`

## scenes/bosses/mixed_mechanics.gd

123 líneas; 0 anotaciones export; 0 uniforms; 38 candidatos.

Hallazgos: BOSS-05.

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var elapsed := 0.0`
- L8, `declaración` (regla/valor): `var attack_index := -1`
- L9, `declaración` (regla/valor): `var attack_kind := -1`
- L10, `declaración` (regla/valor): `var stage := 0`
- L11, `declaración` (texto): `var current_label := "Final mix"`
- L15, `declaración` (regla/valor): `var attack_origin := 0.0`
- L16, `declaración` (regla/valor): `var preview_origin := 0.0`
- L17, `declaración` (regla/valor): `var preview_index := -1`
- L18, `declaración` (regla/valor): `var schedule: Array[int] = []`
- L19, `declaración` (regla/valor): `var history: Array[int] = []`
- L31, `setup` (literal adicional (revisión)): `advance(0)`
- L34, `roll_kind` (regla/valor): `if previous in [1,3]: return 0 if random.randf()<0.5 else 2`
- L35, `roll_kind` (regla/valor): `return random.randi_range(0,3)`
- L39, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L40, `advance` (regla/valor): `if elapsed >= config.section_seconds-0.0000001:`
- L43, `advance` (literal adicional (revisión)): `var index := int(floor((elapsed+0.0000001)/config.mixed_mechanic_interval))`
- L44, `advance` (literal adicional (revisión)): `while schedule.size() <= index+1 and schedule.size()*config.mixed_mechanic_interval < config.section_seconds:`
- L45, `advance` (regla/valor): `schedule.append(roll_kind(schedule.back() if not schedule.is_empty() else -1))`
- L47, `advance` (literal adicional (revisión)): `var next := index+1`
- L50, `advance` (visual): `if next < schedule.size() and schedule[next] in [2,3] and elapsed >= next_origin-0.0000001 and preview_index != next:`
- L56, `advance` (literal adicional (revisión)): `attack.advance(maxf(0,elapsed-attack_origin-attack.elapsed))`
- L58, `advance` (regla/valor): `if is_instance_valid(preview): preview.advance(maxf(0,elapsed-preview_origin-preview.elapsed))`
- L65, `_begin_slot` (literal adicional (revisión)): `current_label = "Final mix · "+["Static grid","Moving parallels","Rotating turret","Moving turret"][attack_kind]`
- L70, `_begin_slot` (literal adicional (revisión)): `preview_index = -1`
- L73, `_begin_slot` (regla/valor): `var lead: float = config.rotating_turret_warning_seconds if index>0 and attack_kind in [2,3] else 0.0`
- L81, `_create_attack` (regla/valor): `if kind in [0,1]:`
- L83, `_create_attack` (texto): `child = load("res://scenes/bosses/complex_fire_lines.gd").new()`
- L85, `_create_attack` (regla/valor): `elif kind == 2:`
- L86, `_create_attack` (texto): `child = load("res://scenes/bosses/rotating_turrets.gd").new()`
- L88, `_create_attack` (texto): `child = load("res://scenes/bosses/mobile_rotating_turrets.gd").new()`
- L89, `_create_attack` (literal adicional (revisión)): `child.forced_moving = 1`
- L90, `_create_attack` (regla/valor): `if kind in [2,3]:`
- L93, `_create_attack` (literal adicional (revisión)): `settings.rotating_turret_spawn_limit = 1`
- L101, `_child_stage` (regla/valor): `if attack_kind in [0,1]: return child.stage`
- L102, `_child_stage` (regla/valor): `if child.turrets.is_empty(): return 2`
- L103, `_child_stage` (regla/valor): `return child.turrets[0].beams.stage`
- L116, `_clear_preview` (literal adicional (revisión)): `preview_index = -1`
- L120, `stop` (literal adicional (revisión)): `stage = 2`

## scenes/bosses/mobile_rotating_turrets.gd

60 líneas; 0 anotaciones export; 0 uniforms; 10 candidatos.

Hallazgos: BOSS-04.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var forced_moving := -1 # -1 random, 0 rotating, 1 moving.`
- L10, `roll_moving` (regla/valor): `if forced_moving >= 0: return forced_moving == 1`
- L11, `roll_moving` (regla/valor): `return random.randf()<0.5`
- L26, `_spawn_batch` (regla/valor): `if turret.moving: turret.rotation_sign = 0.0`
- L37, `_spawn_batch` (texto): `var path = load("res://scenes/bosses/turret_path_cue.gd").new()`
- L46, `_update_motion` (literal adicional (revisión)): `var duration: float = maxf(0.001,turret.expires_at-turret.firing_at)`
- L47, `_update_motion` (literal adicional (revisión)): `var progress := clampf(spinning_age/duration,0,1)`
- L48, `_update_motion` (visual): `turret.position = turret.path_start.lerp(turret.path_end,progress)`
- L49, `_update_motion` (visual): `turret.body.position = turret.position`
- L51, `_update_motion` (literal adicional (revisión)): `turret.path_cue.firing = turret.beams.stage==1`

## scenes/bosses/moving_fire_lines.gd

102 líneas; 0 anotaciones export; 0 uniforms; 27 candidatos.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L7, `declaración` (regla/valor): `var attack_index := -1`
- L8, `declaración` (regla/valor): `var stage := -1`
- L12, `declaración` (regla/valor): `var barriers: Array[Dictionary] = []`
- L13, `declaración` (regla/valor): `var warning_directions: Array[Vector2] = []`
- L21, `setup` (texto): `renderer = load("res://scenes/bosses/static_fire_lines.gd").new()`
- L28, `setup` (texto): `arrows = load("res://scenes/bosses/moving_line_arrows.gd").new()`
- L32, `setup` (literal adicional (revisión)): `advance(0)`
- L36, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L37, `advance` (regla/valor): `if elapsed >= config.section_seconds-0.0000001:`
- L41, `advance` (literal adicional (revisión)): `var index := int(floor((elapsed+0.0000001)/config.moving_line_interval))`
- L43, `advance` (literal adicional (revisión)): `var local_time: float = maxf(0,elapsed-index*config.moving_line_interval)`
- L44, `advance` (regla/valor): `stage = 0 if local_time < config.moving_line_warning_seconds else 1 if local_time < config.moving_line_warning_seconds+config.moving_line_travel_seconds else 2`
- L45, `advance` (literal adicional (revisión)): `var progress := clampf((local_time-config.moving_line_warning_seconds)/config.moving_line_travel_seconds,0,1)`
- L48, `advance` (visual): `barrier.line.visual.position = center`
- L52, `advance` (literal adicional (revisión)): `renderer.animate_lines(elapsed,clampf(local_time/config.moving_line_warning_seconds,0,1))`
- L57, `_begin_attack` (literal adicional (revisión)): `renderer.stage = -1`
- L64, `_begin_attack` (regla/valor): `if config.moving_line_double_attacks.has(index+1): _add_barrier(direction.orthogonal())`
- L68, `_add_barrier` (regla/valor): `var count: int = config.moving_line_parallel_count if attack_index+1 >= config.moving_line_triple_from else 1`
- L69, `_add_barrier` (regla/valor): `var spacing: float = maxf(0,config.moving_line_triple_spacing) if count > 1 else 0.0`
- L71, `_add_barrier` (literal adicional (revisión)): `var half_size := area.background_size*0.5`
- L75, `_add_barrier` (literal adicional (revisión)): `var margin: float = config.moving_line_width+4.0`
- L76, `_add_barrier` (literal adicional (revisión)): `var travel_half := absf(direction.x)*half_size.x+absf(direction.y)*half_size.y+margin+spacing*(count-1)*0.5`
- L77, `_add_barrier` (texto): `var coverage := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),maxf(margin,config.laser_end_overscan))`
- L78, `_add_barrier` (regla/valor): `var span_half := 0.0`
- L83, `_add_barrier` (literal adicional (revisión)): `var offset := direction*(index-(count-1)*0.5)*spacing`
- L91, `stop` (literal adicional (revisión)): `stage = 2`

## scenes/bosses/moving_line_arrows.gd

48 líneas; 0 anotaciones export; 0 uniforms; 16 candidatos.

Hallazgos: BOSS-08.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var badges: Array[Node2D] = []`
- L4, `declaración` (constante): `const BADGE_SCENE = preload("res://scenes/bosses/moving_line_arrow_badge.tscn")`
- L12, `markers` (regla/valor): `var result: Array[Dictionary] = []`
- L13, `markers` (regla/valor): `if not is_instance_valid(section) or not section.running or section.stage != 0: return result`
- L15, `markers` (literal adicional (revisión)): `var center := viewport_size*0.5`
- L16, `markers` (visual): `var safe := Rect2(Vector2(104,180),viewport_size-Vector2(208,396))`
- L20, `markers` (regla/valor): `var incoming := -forward`
- L22, `markers` (regla/valor): `if incoming.x > 0.00001: distance = minf(distance,(safe.end.x-center.x)/incoming.x)`
- L23, `markers` (visual): `elif incoming.x < -0.00001: distance = minf(distance,(safe.position.x-center.x)/incoming.x)`
- L24, `markers` (regla/valor): `if incoming.y > 0.00001: distance = minf(distance,(safe.end.y-center.y)/incoming.y)`
- L25, `markers` (visual): `elif incoming.y < -0.00001: distance = minf(distance,(safe.position.y-center.y)/incoming.y)`
- L44, `refresh` (visual): `badge.position = marker.point`
- L45, `refresh` (regla/valor): `badge.rotation = marker.direction.angle()`
- L46, `refresh` (texto): `badge.scale = badge.get_meta("rest_scale")*(1.0+0.08*sin(section.elapsed*22))`
- L47, `refresh` (texto): `badge.get_node("Arrow").material.set_shader_parameter("phase",section.elapsed)`
- L48, `refresh` (texto): `badge.get_node("Border").material.set_shader_parameter("phase",section.elapsed)`

## scenes/bosses/phase_fueguito.gd

25 líneas; 0 anotaciones export; 0 uniforms; 4 candidatos.

### Candidatos / evidencia

- L11, `setup` (literal adicional (revisión)): `batch_size = 1`
- L18, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L20, `advance` (regla/valor): `if pending > 0 and elapsed >= materialize_at: materialize_batch()`
- L21, `advance` (regla/valor): `if hazards.is_empty() and pending == 0:`

## scenes/bosses/rotating_turrets.gd

86 líneas; 0 anotaciones export; 0 uniforms; 28 candidatos.

### Candidatos / evidencia

- L15, `_spawn_batch` (regla/valor): `var diagonal := sequence%2==1`
- L20, `_spawn_batch` (regla/valor): `turret.base_angle = PI*0.25 if diagonal else 0.0`
- L21, `_spawn_batch` (regla/valor): `turret.rotation_sign = 1.0 if sequence%2==0 else -1.0`
- L23, `_spawn_batch` (regla/valor): `turret.firing_at = config.turret_warning_seconds if batch == 0 else batch*config.rotating_turret_interval`
- L25, `_spawn_batch` (texto): `var cue = load("res://scenes/bosses/turret_rotation_cue.gd").new()`
- L26, `_spawn_batch` (literal adicional (revisión)): `cue.radius = config.turret_visual_height*0.6`
- L27, `_spawn_batch` (texto): `cue.position = turret.body.get_node("RayOrigin").position`
- L33, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L34, `advance` (regla/valor): `if elapsed >= config.section_seconds-0.0000001:`
- L38, `advance` (regla/valor): `if elapsed >= turret.expires_at-0.0000001: _remove_turret(turret)`
- L40, `advance` (literal adicional (revisión)): `var batch := last_batch+1`
- L42, `advance` (literal adicional (revisión)): `var preview_at: float = maxf(0,firing_at-config.turret_warning_seconds)`
- L43, `advance` (regla/valor): `if config.rotating_turret_spawn_limit > 0 and batch >= config.rotating_turret_spawn_limit: break`
- L44, `advance` (regla/valor): `if firing_at >= config.section_seconds or preview_at > elapsed+0.0000001: break`
- L45, `advance` (regla/valor): `if firing_at+config.rotating_turret_lifetime > elapsed+0.0000001: _spawn_batch(batch,preview_at)`
- L49, `advance` (regla/valor): `turret.beams.set_line_stage(0 if elapsed < turret.firing_at-0.0000001 else 1)`
- L50, `advance` (literal adicional (revisión)): `turret.beams.animate_lines(age,clampf(age/config.turret_warning_seconds,0,1))`
- L52, `advance` (literal adicional (revisión)): `var spinning_age := maxf(0,elapsed-turret.firing_at)`
- L58, `advance` (literal adicional (revisión)): `turret.cue.firing = turret.beams.stage==1`
- L61, `advance` (literal adicional (revisión)): `for index in 2:`
- L62, `advance` (regla/valor): `var direction := Vector2.from_angle(turret.angle+index*PI*0.5)`
- L70, `advance` (visual): `line.visual.position = start.lerp(end,0.5)`
- L71, `advance` (regla/valor): `line.visual.rotation = start.angle_to_point(end)`
- L74, `advance` (texto): `line.glow.material.set_shader_parameter("world_length",length)`
- L76, `advance` (texto): `line.warning.material.set_shader_parameter("world_length",length)`
- L77, `advance` (regla/valor): `var half: Vector2 = Vector2(length*0.5,config.turret_line_width)`
- L79, `advance` (visual): `line.shape.shape.size = Vector2(length,config.turret_line_width)`
- L80, `advance` (texto): `line.material.set_shader_parameter("world_length",length)`

## scenes/bosses/salchichon/salchichon.gd

103 líneas; 0 anotaciones export; 0 uniforms; 19 candidatos.

### Candidatos / evidencia

- L2, `declaración` (regla/valor): `var anchor := Vector2.ZERO`
- L3, `declaración` (visual): `var rest_sprite_scale := Vector2.ONE`
- L4, `declaración` (visual): `var rest_sprite_position := Vector2.ZERO`
- L5, `declaración` (regla/valor): `var idle_clock := 0.0`
- L9, `declaración` (regla/valor): `var takeoff_vertical := 1.0`
- L10, `declaración` (regla/valor): `var shadow_local_rect := Rect2()`
- L27, `configure` (literal adicional (revisión)): `$HitboxComponent.setup(settings.contact_damage,false,0,self)`
- L33, `set_present` (regla/valor): `$HurtboxComponent.collision_layer = 8 if enabled else 0`
- L36, `set_present` (regla/valor): `$HitboxComponent.collision_layer = 4 if enabled else 0`
- L45, `_process` (literal adicional (revisión)): `slow_left = maxf(0,slow_left-delta)`
- L46, `_process` (literal adicional (revisión)): `launch_left = maxf(0,launch_left-delta)`
- L51, `_process` (regla/valor): `var vertical: float = 1.0 + animation_settings.idle_squash_strength * sin(idle_clock * TAU / animation_settings.idle_squash_period)`
- L54, `_process` (literal adicional (revisión)): `vertical -= animation_settings.landing_squash_strength * cos(progress * TAU * 1.5) * pow(1.0-progress,2)`
- L56, `_process` (regla/valor): `vertical += 0.08 # A little stretch during the fall.`
- L58, `_process` (visual): `sprite.scale = rest_sprite_scale * Vector2(1.0/vertical,vertical)`
- L79, `play_landing_squash` (literal adicional (revisión)): `impact_age = 0.0`
- L90, `contact_world_radius` (visual): `return (shape.shape as CircleShape2D).radius * absf(shape.global_scale.x)`
- L97, `set_fall_offset` (visual): `sprite.position = rest_sprite_position + Vector2(0,-height)`
- L103, `set_takeoff_pose` (visual): `sprite.scale=rest_sprite_scale*Vector2(1.0/vertical,vertical)`

## scenes/bosses/sausage_turret.gd

73 líneas; 6 anotaciones export; 0 uniforms; 29 candidatos.

Hallazgos: BOSS-06.

### Ya expuesto en el editor

- L2: `@export_range(0.1,1.0,0.01) var spawn_seconds := 0.46`
- L3: `@export var spawn_small_scale := Vector2(0.2,0.12)`
- L4: `@export var spawn_peak_scale := Vector2(1.16,1.45)`
- L5: `@export var spawn_recoil_scale := Vector2(0.96,0.92)`
- L6: `@export_range(0.1,1.0,0.01) var retire_seconds := 0.36`
- L7: `@export var retire_peak_scale := Vector2(1.12,1.32)`

### Candidatos / evidencia

- L9, `declaración` (regla/valor): `var retire_age := 0.0`
- L10, `declaración` (regla/valor): `var retire_from := Vector2.ONE`
- L11, `declaración` (regla/valor): `var retire_phase := 0.0`
- L13, `declaración` (visual): `var rest_sprite_scale := Vector2.ONE`
- L17, `_ready` (literal adicional (revisión)): `animate_birth(0)`
- L20, `animate_birth` (literal adicional (revisión)): `var progress := clampf(age/spawn_seconds,0,1)`
- L22, `animate_birth` (regla/valor): `if progress<0.6:`
- L23, `animate_birth` (regla/valor): `var t := 1.0-pow(1.0-progress/0.6,3.0)`
- L25, `animate_birth` (regla/valor): `elif progress<0.84:`
- L26, `animate_birth` (literal adicional (revisión)): `factor=spawn_peak_scale.lerp(spawn_recoil_scale,smoothstep(0.6,0.84,progress))`
- L28, `animate_birth` (literal adicional (revisión)): `factor=spawn_recoil_scale.lerp(Vector2.ONE,smoothstep(0.84,1.0,progress))`
- L30, `animate_birth` (regla/valor): `var breath := 0.025*sin((age-spawn_seconds)*4.0)`
- L31, `animate_birth` (literal adicional (revisión)): `factor=Vector2(1.0+breath,1.0-breath)`
- L32, `animate_birth` (visual): `$Sprite.scale=rest_sprite_scale*factor`
- L37, `begin_retirement` (literal adicional (revisión)): `retire_age=0`
- L41, `begin_retirement` (texto): `$Sprite.material.set_shader_parameter("firing",0.0)`
- L42, `begin_retirement` (literal adicional (revisión)): `$HitboxComponent.damage=0`
- L43, `begin_retirement` (literal adicional (revisión)): `$HitboxComponent.base_damage=0`
- L44, `begin_retirement` (literal adicional (revisión)): `$HitboxComponent.collision_layer=0`
- L47, `begin_retirement` (texto): `if child.get_script() == preload("res://scenes/bosses/turret_rotation_cue.gd"):`
- L52, `begin_retirement` (literal adicional (revisión)): `animate_retirement(0)`
- L55, `animate_retirement` (literal adicional (revisión)): `var progress := clampf(age/retire_seconds,0,1)`
- L57, `animate_retirement` (regla/valor): `if progress<0.22:`
- L58, `animate_retirement` (literal adicional (revisión)): `factor=retire_from.lerp(retire_peak_scale,smoothstep(0,0.22,progress))`
- L60, `animate_retirement` (literal adicional (revisión)): `factor=retire_peak_scale.lerp(Vector2.ZERO,smoothstep(0.22,1,progress))`
- L61, `animate_retirement` (visual): `$Sprite.scale=rest_sprite_scale*factor`
- L62, `animate_retirement` (texto): `$Sprite.material.set_shader_parameter("phase",retire_phase+age)`
- L63, `animate_retirement` (regla/valor): `if progress>=1: queue_free()`
- L72, `_process` (literal adicional (revisión)): `retire_age+=maxf(0,delta)`

## scenes/bosses/static_fire_lines.gd

181 líneas; 0 anotaciones export; 0 uniforms; 69 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var length := 100.0`
- L5, `declaración` (regla/valor): `var width := 24.0`
- L6, `declaración` (regla/valor): `var warning_progress := 0.0`
- L7, `declaración` (regla/valor): `var phase := 0.0`
- L8, `declaración` (regla/valor): `var mode := 0`
- L13, `declaración` (regla/valor): `var elapsed := 0.0`
- L14, `declaración` (regla/valor): `var pattern_index := -1`
- L15, `declaración` (regla/valor): `var stage := -1 # 0 warning, 1 active, 2 rest`
- L16, `declaración` (regla/valor): `var lines: Array[Dictionary] = []`
- L19, `declaración` (regla/valor): `var active_started_at := -1.0`
- L20, `declaración` (regla/valor): `var current_label := ""`
- L29, `setup` (literal adicional (revisión)): `advance(0)`
- L33, `advance` (literal adicional (revisión)): `elapsed += maxf(0,delta)`
- L38, `advance` (regla/valor): `if config.static_line_patterns.is_empty() or cycle <= 0: return`
- L44, `advance` (literal adicional (revisión)): `stage = -1`
- L46, `advance` (regla/valor): `var next_stage := 0 if local_time < config.line_warning_seconds else 1 if local_time < config.line_warning_seconds+config.line_active_seconds else 2`
- L48, `advance` (literal adicional (revisión)): `animate_lines(elapsed,clampf(local_time/config.line_warning_seconds,0,1))`
- L54, `set_line_stage` (texto): `if stage in [0,1]: SoundManager.play_event("laser_warning" if stage==0 else "laser_fire")`
- L55, `set_line_stage` (regla/valor): `if stage==1: active_started_at = -1.0`
- L58, `set_line_stage` (literal adicional (revisión)): `line.visual.visible = stage != 2`
- L59, `set_line_stage` (literal adicional (revisión)): `line.fire.visible = stage == 1`
- L60, `set_line_stage` (regla/valor): `if stage==1:`
- L62, `set_line_stage` (texto): `line.material.set_shader_parameter("flash",0.0 if persistent_glow else 1.0)`
- L63, `set_line_stage` (texto): `line.glow.material.set_shader_parameter("intensity",config.laser_glow_strength if persistent_glow else config.laser_glow_strength*0.65+config.laser_flash_strength)`
- L64, `set_line_stage` (literal adicional (revisión)): `line.glow.visible = stage == 1`
- L65, `set_line_stage` (literal adicional (revisión)): `line.warning.visible = stage == 0`
- L66, `set_line_stage` (regla/valor): `line.hit.damage = config.line_damage if stage == 1 else 0.0`
- L68, `set_line_stage` (regla/valor): `line.hit.collision_layer = 4 if stage == 1 else 0`
- L69, `set_line_stage` (literal adicional (revisión)): `line.shape.set_deferred("disabled",stage != 1)`
- L72, `animate_lines` (regla/valor): `if stage==1 and active_started_at<0: active_started_at=clock`
- L73, `animate_lines` (regla/valor): `var flash := pow(maxf(0.0,1.0-(clock-active_started_at)/config.laser_flash_seconds),2.0) if stage==1 and not persistent_glow else 0.0`
- L77, `animate_lines` (visual): `line.warning.scale = Vector2(line.visual.length,line.visual.width)`
- L78, `animate_lines` (texto): `line.warning.material.set_shader_parameter("phase",clock)`
- L79, `animate_lines` (texto): `line.warning.material.set_shader_parameter("warning_progress",warning_progress)`
- L80, `animate_lines` (texto): `line.warning.material.set_shader_parameter("world_length",line.visual.length)`
- L81, `animate_lines` (texto): `line.material.set_shader_parameter("phase",clock)`
- L82, `animate_lines` (texto): `line.material.set_shader_parameter("flash",flash)`
- L83, `animate_lines` (visual): `line.glow.scale=Vector2(line.visual.length,line.visual.width*4.0)`
- L84, `animate_lines` (texto): `line.glow.material.set_shader_parameter("phase",clock if persistent_glow else 0.0)`
- L85, `animate_lines` (texto): `line.glow.material.set_shader_parameter("ripple_strength",0.06 if persistent_glow else 0.0)`
- L86, `animate_lines` (texto): `line.glow.material.set_shader_parameter("world_length",line.visual.length)`
- L87, `animate_lines` (texto): `line.glow.material.set_shader_parameter("intensity",config.laser_glow_strength*(1.0 if persistent_glow else 0.65)+config.laser_flash_strength*flash)`
- L92, `_build_pattern` (texto): `var background := preload("res://scenes/bosses/laser_bounds.gd").for_view(area,get_viewport(),config.laser_end_overscan)`
- L93, `_build_pattern` (regla/valor): `var horizontal: Array[float] = []`
- L94, `_build_pattern` (regla/valor): `var vertical: Array[float] = []`
- L96, `_build_pattern` (literal adicional (revisión)): `horizontal.append(lerpf(bounds.position.y,bounds.end.y,clampf(fraction,0,1)))`
- L98, `_build_pattern` (literal adicional (revisión)): `vertical.append(lerpf(bounds.position.x,bounds.end.x,clampf(fraction,0,1)))`
- L103, `_build_pattern` (regla/valor): `var chosen := -1`
- L114, `_build_pattern` (regla/valor): `if chosen >= 0:`
- L124, `_add_segment` (regla/valor): `if length <= 0.1: return`
- L128, `_add_segment` (visual): `visual.position = start.lerp(end,0.5)`
- L129, `_add_segment` (regla/valor): `visual.rotation = start.angle_to_point(end)`
- L131, `_add_segment` (texto): `var glow: Polygon2D = preload("res://scenes/bosses/fire_line_glow.tscn").instantiate()`
- L132, `_add_segment` (visual): `glow.scale=Vector2(length,config.line_width*4.0)`
- L135, `_add_segment` (texto): `var warning: Polygon2D = preload("res://scenes/bosses/fire_line_warning.tscn").instantiate()`
- L136, `_add_segment` (visual): `warning.scale = Vector2(length,config.line_width)`
- L137, `_add_segment` (texto): `warning.material.set_shader_parameter("world_length",length)`
- L140, `_add_segment` (regla/valor): `var half := Vector2(length*0.5,config.line_width)`
- L142, `_add_segment` (literal adicional (revisión)): `fire.uv = PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])`
- L144, `_add_segment` (literal adicional (revisión)): `var image := Image.create(1,1,false,Image.FORMAT_RGBA8)`
- L148, `_add_segment` (texto): `material.shader = preload("res://shaders/boss_fire_line.gdshader")`
- L149, `_add_segment` (texto): `material.set_shader_parameter("world_length",length)`
- L155, `_add_segment` (literal adicional (revisión)): `hit.collision_layer = 0`
- L156, `_add_segment` (literal adicional (revisión)): `hit.collision_mask = 0`
- L160, `_add_segment` (literal adicional (revisión)): `hit.setup(0,false,0,source)`
- L163, `_add_segment` (visual): `shape.shape.size = Vector2(length,config.line_width)`
- L170, `_clear_lines` (literal adicional (revisión)): `line.hit.damage = 0`
- L171, `_clear_lines` (literal adicional (revisión)): `line.hit.base_damage = 0`
- L172, `_clear_lines` (literal adicional (revisión)): `line.hit.collision_layer = 0`

## scenes/bosses/turret_edge_indicators.gd

55 líneas; 0 anotaciones export; 0 uniforms; 20 candidatos.

### Candidatos / evidencia

- L13, `markers` (regla/valor): `var result: Array[Dictionary] = []`
- L16, `markers` (literal adicional (revisión)): `var center := viewport_size*0.5`
- L18, `markers` (visual): `var safe := Rect2(Vector2(36,132),viewport_size-Vector2(72,168))`
- L22, `markers` (visual): `if Rect2(Vector2.ZERO,viewport_size).has_point(screen): continue`
- L25, `markers` (regla/valor): `if direction.x > 0: distance = minf(distance,(safe.end.x-center.x)/direction.x)`
- L26, `markers` (visual): `elif direction.x < 0: distance = minf(distance,(safe.position.x-center.x)/direction.x)`
- L27, `markers` (regla/valor): `if direction.y > 0: distance = minf(distance,(safe.end.y-center.y)/direction.y)`
- L28, `markers` (visual): `elif direction.y < 0: distance = minf(distance,(safe.position.y-center.y)/direction.y)`
- L32, `markers` (literal adicional (revisión)): `for step in [0,1,-1,2,-2,3,-3,4,-4,5,-5]:`
- L33, `markers` (regla/valor): `var candidate := point+Vector2(0,step*58) if side_edge else point+Vector2(step*58,0)`
- L37, `markers` (regla/valor): `if candidate.distance_to(previous.point) < 54: crowded = true`
- L41, `markers` (texto): `result.append({"point":point,"diagonal":turret.diagonal,"active":turret.beams.stage==1,"angle":turret.get("angle",PI*0.25 if turret.diagonal else 0.0),"turn":turret.get("rotation_sign",0.0)})`
- L47, `_draw` (texto): `var color := Color("ff9b39") if marker.active else Color("ffe4a8")`
- L48, `_draw` (literal adicional (revisión)): `draw_circle(point,25,Color("35251c"),true,-1,true)`
- L49, `_draw` (literal adicional (revisión)): `draw_arc(point,25,0,TAU,40,color,3,true)`
- L51, `_draw` (regla/valor): `if marker.turn != 0:`
- L52, `_draw` (texto): `preload("res://scenes/bosses/turret_rotation_cue.gd").draw_turn(self,point,32,angle,marker.turn,color)`
- L53, `_draw` (literal adicional (revisión)): `for offset in [0.0,PI*0.5]:`
- L54, `_draw` (regla/valor): `var direction := Vector2.from_angle(angle+offset)*12`
- L55, `_draw` (literal adicional (revisión)): `draw_line(point-direction,point+direction,color,4,true)`

## scenes/bosses/turret_path_cue.gd

26 líneas; 0 anotaciones export; 0 uniforms; 14 candidatos.

### Candidatos / evidencia

- L2, `declaración` (regla/valor): `var start := Vector2.ZERO`
- L3, `declaración` (regla/valor): `var finish := Vector2.ZERO`
- L4, `declaración` (regla/valor): `var progress := 0.0`
- L8, `_ready` (literal adicional (revisión)): `z_index = -1`
- L14, `_draw` (visual): `var color := Color(1,0.76,0.32,0.38 if firing else 0.9)`
- L17, `_draw` (literal adicional (revisión)): `draw_line(origin,finish,Color(1,0.65,0.12,0.08),16,true)`
- L18, `_draw` (literal adicional (revisión)): `for index in ceili(distance/42):`
- L19, `_draw` (literal adicional (revisión)): `var from := origin+direction*index*42`
- L20, `_draw` (literal adicional (revisión)): `var to := origin+direction*minf(distance,index*42+24)`
- L21, `_draw` (literal adicional (revisión)): `draw_line(from,to,color,3,true)`
- L22, `_draw` (regla/valor): `if distance > 30:`
- L23, `_draw` (literal adicional (revisión)): `for fraction in [0.25,0.6,0.9]:`
- L25, `_draw` (literal adicional (revisión)): `draw_colored_polygon(PackedVector2Array([point+direction*14,point-direction*10+side*10,point-direction*10-side*10]),color)`
- L26, `_draw` (literal adicional (revisión)): `draw_arc(finish,18,0,TAU,32,color,3,true)`

## scenes/bosses/turret_rotation_cue.gd

22 líneas; 0 anotaciones export; 0 uniforms; 12 candidatos.

### Candidatos / evidencia

- L2, `declaración` (regla/valor): `var radius := 84.0`
- L3, `declaración` (regla/valor): `var angle := 0.0`
- L4, `declaración` (regla/valor): `var turn := 1.0`
- L8, `_draw` (texto): `var color := Color("ff9b39") if firing else Color("ffe4a8")`
- L13, `draw_turn` (literal adicional (revisión)): `var start := rotation_angle-PI*0.5`
- L14, `draw_turn` (literal adicional (revisión)): `var end := start+sign_value*TAU*0.72`
- L15, `draw_turn` (literal adicional (revisión)): `for index in 41:`
- L16, `draw_turn` (literal adicional (revisión)): `points.append(center+Vector2.from_angle(lerpf(start,end,index/40.0))*r)`
- L17, `draw_turn` (literal adicional (revisión)): `canvas.draw_polyline(points,color,3,true)`
- L19, `draw_turn` (regla/valor): `var forward := Vector2(-sin(end),cos(end))*sign_value`
- L21, `draw_turn` (literal adicional (revisión)): `var arrow_size := minf(12,r*0.3)`
- L22, `draw_turn` (literal adicional (revisión)): `canvas.draw_colored_polygon(PackedVector2Array([head+forward*arrow_size,head-forward*arrow_size+side*arrow_size*0.7,head-forward*arrow_size-side*arrow_size*0.7]),color)`

## scenes/coins/burst_yolk.gd

54 líneas; 0 anotaciones export; 0 uniforms; 17 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var launch_start := Vector2.ZERO`
- L4, `declaración` (regla/valor): `var launch_end := Vector2.ZERO`
- L5, `declaración` (regla/valor): `var launch_duration := 0.5`
- L6, `declaración` (regla/valor): `var launch_elapsed := 0.0`
- L7, `declaración` (regla/valor): `var launch_height := 60.0`
- L9, `declaración` (visual): `var _rest_position := Vector2.ZERO`
- L10, `declaración` (visual): `var _rest_shadow_scale := Vector2.ONE`
- L15, `launch` (literal adicional (revisión)): `launch_duration=maxf(0.1,duration)`
- L16, `launch` (literal adicional (revisión)): `launch_height=maxf(0,height)`
- L41, `_process` (literal adicional (revisión)): `launch_elapsed+=maxf(0,delta)`
- L42, `_process` (literal adicional (revisión)): `var progress:=clampf(launch_elapsed/launch_duration,0,1)`
- L43, `_process` (regla/valor): `var eased:=1.0-pow(1.0-progress,2.0)`
- L46, `_process` (visual): `sprite.position=_rest_position+Vector2(0,-arc*launch_height/maxf(0.001,absf(global_scale.y)))`
- L47, `_process` (visual): `$Shadow.scale=_rest_shadow_scale*(1.0-0.35*arc)`
- L48, `_process` (regla/valor): `if progress>=1.0:`
- L50, `_process` (visual): `sprite.position=_rest_position`
- L51, `_process` (visual): `$Shadow.scale=_rest_shadow_scale`

## scenes/coins/coins.gd

120 líneas; 6 anotaciones export; 0 uniforms; 18 candidatos.

Hallazgos: COOP-06.

### Ya expuesto en el editor

- L4: `@export var move_speed := 1000.0`
- L5: `@export var collect_distance := 15.0`
- L6: `@export var attraction_distance := 195.0`
- L7: `@export_range(0.0, 0.15, 0.01) var squash_amount := 0.05`
- L8: `@export_range(0.5, 3.0, 0.1) var squash_period := 1.4`
- L9: `@export_range(0.2, 0.9, 0.05) var jar_flight_duration := 0.65`

### Candidatos / evidencia

- L13, `declaración` (regla/valor): `var squash_phase := 0.0`
- L15, `declaración` (regla/valor): `var value := 1`
- L21, `declaración` (regla/valor): `var flight_elapsed := 0.0`
- L31, `_try_spawn_attraction` (regla/valor): `var activated: Array[Player]=[]`
- L42, `_pickup_target` (regla/valor): `if is_instance_valid(magnet_target) and not magnet_target.is_queued_for_deletion() and magnet_target.health_component.current_health>0: return magnet_target`
- L54, `_process` (regla/valor): `var stretch := 1.0 + sin(squash_phase) * squash_amount`
- L55, `_process` (visual): `sprite.scale = sprite_base_scale * Vector2(stretch, 1.0 / stretch)`
- L58, `_process` (visual): `if not collected and global_position.distance_squared_to(target.global_position) <= pow(target.stats.get_pickup_distance(attraction_distance), 2): collected = true`
- L70, `fly_to_jar` (literal adicional (revisión)): `flight_elapsed = 0.0`
- L81, `animate_jar_flight` (literal adicional (revisión)): `var progress := clampf(flight_elapsed / jar_flight_duration, 0.0, 1.0)`
- L82, `animate_jar_flight` (literal adicional (revisión)): `var eased := progress * progress * (3.0 - 2.0 * progress)`
- L83, `animate_jar_flight` (literal adicional (revisión)): `var jar_center_screen := jar_target.get_global_transform_with_canvas() * (jar_target.size * 0.5)`
- L87, `animate_jar_flight` (regla/valor): `if progress >= 1.0:`
- L98, `add_coins` (literal adicional (revisión)): `Global.nearest_player(global_position).passive_items.on_yolks_collected(maxi(0, value) + bonus)`
- L99, `add_coins` (regla/valor): `if bonus > 0:`
- L102, `add_coins` (texto): `text.setup_text("×2" if bonus == value else "+%d" % bonus, Color("ffd34e"))`
- L114, `_ready` (literal adicional (revisión)): `sprite.z_index = -1`
- L116, `_ready` (literal adicional (revisión)): `$Shadow.z_index = -2`

## scenes/components/fueguito_health_component.gd

8 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.


## scenes/components/health_component.gd

46 líneas; 0 anotaciones export; 0 uniforms; 10 candidatos.

Hallazgos: ITEM-03.

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var max_health := 1.0`
- L11, `declaración` (regla/valor): `var current_health := 1.0`
- L14, `setup` (literal adicional (revisión)): `max_health = maxf(1.0, stats.health)`
- L19, `take_damage` (regla/valor): `if current_health <= 0 or Global.game_paused or debug_invulnerable: return`
- L21, `take_damage` (regla/valor): `if owner is Player and is_instance_valid(owner.passive_items) and owner.passive_items.shell_invulnerability > 0.0: return`
- L23, `take_damage` (literal adicional (revisión)): `current_health = minf(1.0, max_health)`
- L27, `take_damage` (literal adicional (revisión)): `current_health = max(current_health, 0) #Selecciona el valor mas alto, para no tener valores negativos`
- L32, `take_damage` (regla/valor): `if current_health <= 0:`
- L33, `take_damage` (literal adicional (revisión)): `current_health = 0`
- L38, `heal` (regla/valor): `if current_health <= 0: return`

## scenes/components/hitbox_component.gd

96 líneas; 2 anotaciones export; 0 uniforms; 15 candidatos.

### Ya expuesto en el editor

- L32: `@export var status_effects: Array[StatusEffect] = []`
- L37: `@export var bb: CollisionShape2D`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var damage := 1.0`
- L14, `declaración` (regla/valor): `var critical_chance := 0.0`
- L15, `declaración` (regla/valor): `var critical_multiplier := 1.0`
- L16, `declaración` (regla/valor): `var base_damage := 1.0`
- L17, `declaración` (regla/valor): `var knockback_power := 0.0`
- L20, `declaración` (regla/valor): `var weapon_damage_record: Dictionary = {}`
- L21, `declaración` (regla/valor): `var life_steal_chance := 0.0`
- L24, `declaración` (regla/valor): `var _hit_hurtboxes: Dictionary = {}`
- L26, `declaración` (regla/valor): `var launch_direction := Vector2.ZERO`
- L28, `declaración` (regla/valor): `var launch_speed := 520.0`
- L29, `declaración` (regla/valor): `var launch_duration := 0.45`
- L30, `declaración` (regla/valor): `var launch_damage := 0.0`
- L73, `report_damage` (regla/valor): `if amount <= 0.0 or Global.game_paused: return`
- L86, `report_damage` (texto): `if _breading_handler == null: _breading_handler = load("res://effects/breading_hit.gd")`
- L96, `roll_target_critical` (regla/valor): `damage = base_damage * (critical_multiplier if critical else 1.0)`

## scenes/components/hurtbox_component.gd

47 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

Hallazgos: UNIT-07.

### Candidatos / evidencia

- L6, `declaración` (constante): `const CONTACT_INTERVAL := 0.5`
- L7, `declaración` (regla/valor): `var contact_cooldowns: Dictionary = {}`
- L14, `get_target_position` (regla/valor): `if child is CollisionShape2D and child.shape:`
- L24, `_physics_process` (regla/valor): `var present: Array = []`
- L28, `_physics_process` (regla/valor): `if area.source.health_component.current_health <= 0.0: continue`
- L31, `_physics_process` (literal adicional (revisión)): `contact_cooldowns[key] = maxf(0.0, contact_cooldowns.get(key, 0.0) - delta)`
- L32, `_physics_process` (regla/valor): `if contact_cooldowns[key] <= 0.0: _contact_hit(area)`
- L38, `_contact_hit` (regla/valor): `if owner is Player and (owner.is_dashing or owner.hit_invulnerability_left > 0.0): return`

## scenes/coop/coop_game_toggle.gd

27 líneas; 0 anotaciones export; 0 uniforms; 5 candidatos.

### Candidatos / evidencia

- L6, `declaración` (visual): `var rest_position := Vector2.ZERO`
- L17, `_sync` (texto): `background.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.focus if on else UITheme.palette.inset,UITheme.palette.outline,18,2))`
- L18, `_sync` (texto): `knob.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.hud_text if on else UITheme.palette.muted,Color.TRANSPARENT,14,0))`
- L19, `_sync` (literal adicional (revisión)): `var target: float=maxf(0,track.size.y-knob.size.y-rest_position.y) if on else rest_position.y`
- L23, `_sync` (texto): `motion.tween_property(knob,"position:y",target,.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)`

## scenes/coop/coop_reward_panel.gd

78 líneas; 0 anotaciones export; 0 uniforms; 24 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var controls: Array[Button]=[]`
- L6, `declaración` (regla/valor): `var hovered_control:=-1`
- L12, `setup` (texto): `add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,controller.COLORS[slot],12,2))`
- L13, `setup` (texto): `$HeaderOverlay/PlayerLabel.text="P%d" % (slot+1)`
- L14, `setup` (texto): `$HeaderOverlay/PlayerLabel.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L15, `setup` (texto): `$HeaderOverlay/PlayerLabel.add_theme_stylebox_override("normal",UITheme.box(controller.COLORS[slot],Color.TRANSPARENT,12,0))`
- L16, `setup` (texto): `$Waiting.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L17, `setup` (literal adicional (revisión)): `var keep: Button=card.get_node("MarginContainer/Control/Actions").get_child(0)`
- L23, `setup` (literal adicional (revisión)): `for i in 2:`
- L30, `setup` (regla/valor): `if session and session.device<0 and not MenuInput.coop_mouse_blocked(): controller.activate(session,i))`
- L31, `setup` (literal adicional (revisión)): `card.get_node("MarginContainer/Control/Actions").get_child(0).get_node("HBoxContainer/TextureRect").hide()`
- L34, `setup` (texto): `sell_value.add_theme_color_override("font_color",UITheme.palette.text)`
- L38, `_hover` (regla/valor): `if session and session.device<0 and not MenuInput.coop_mouse_blocked():`
- L47, `_unhover` (literal adicional (revisión)): `hovered_control=-1`
- L52, `move_selector` (regla/valor): `var index=0 if direction.y<0 or direction.x<0 else 1`
- L64, `present` (literal adicional (revisión)): `card.shop_item=session.rewards[0]`
- L65, `present` (texto): `card.item_cost.text="CONSERVAR"`
- L66, `present` (texto): `controls[1].text=""`
- L67, `present` (texto): `sell_value.text="VENDER %d" % session.rewards[0].get_sell_price(card.shop_wave)`
- L68, `present` (literal adicional (revisión)): `for i in 2:`
- L70, `present` (literal adicional (revisión)): `UITheme.style_slot(controls[i],0)`
- L72, `present` (texto): `controls[i].add_theme_stylebox_override("normal",controls[i].get_theme_stylebox("hover").duplicate())`
- L75, `show_waiting` (texto): `$Waiting.text="LISTO" if session else "JUGADOR NO CONECTADO"`
- L78, `scroll_detail` (literal adicional (revisión)): `card.item_description.get_v_scroll_bar().value+=amount*2`

## scenes/coop/coop_selection.gd

459 líneas; 2 anotaciones export; 0 uniforms; 92 candidatos.

Hallazgos: COOP-03.

### Ya expuesto en el editor

- L3: `@export_range(0.2, 2.0, 0.05) var join_hold_seconds := 0.65`
- L4: `@export_multiline var solo_notice_text: String = "Para jugar solo, desactivá Coop Game.\nO esperá a que se una otro jugador."`

### Candidatos / evidencia

- L5, `declaración` (constante): `const Rows = preload("res://scenes/coop/selection_player_rows.tscn")`
- L6, `declaración` (constante): `const Markers = preload("res://scenes/coop/selection_roster_markers.tscn")`
- L10, `declaración` (texto): `var mode := "characters"`
- L12, `declaración` (regla/valor): `var holds: Dictionary = {}`
- L13, `declaración` (regla/valor): `var accept_latches: Dictionary = {}`
- L14, `declaración` (regla/valor): `var repeat_times: Dictionary = {}`
- L34, `setup` (texto): `for i in 4: markers.get_child(i).add_theme_color_override("font_color",coop.COLORS[i])`
- L43, `_install_rows` (literal adicional (revisión)): `for i in 4: rows.get_node("Rows").get_child(i).get_node("Margin/Content/Header/Confirm").pressed.connect(_mouse_confirm.bind(i))`
- L55, `enable` (literal adicional (revisión)): `mode="characters"`
- L79, `disable` (literal adicional (revisión)): `Global.main_player_selected=coop.sessions[0].character`
- L80, `disable` (literal adicional (revisión)): `Global.main_weapon_selected=coop.sessions[0].weapon`
- L82, `disable` (literal adicional (revisión)): `if coop: coop.mode=""`
- L102, `_join_device` (texto): `if mode!="characters" or coop.sessions.size()>=4 or _session(device): return null`
- L103, `_join_device` (regla/valor): `var readiness: Array=[]`
- L109, `_join_device` (regla/valor): `session.character=Global.main_player_selected if device==coop.sessions[0].device and Global.main_player_selected and choices.has(Global.main_player_selected) else choices[0]`
- L117, `_choices` (regla/valor): `var result: Array=[]`
- L125, `_set_default_weapon` (texto): `var spatula=preload("res://resources/items/weapons/melee/spatula/item_spatula_1.tres")`
- L134, `choose_character` (literal adicional (revisión)): `var session=_session(-1)`
- L135, `choose_character` (literal adicional (revisión)): `if not session or mode!="characters" or session.ready or transitioning or not Progression.is_character_unlocked(player): return`
- L143, `choose_weapon` (literal adicional (revisión)): `var session=_session(-1)`
- L144, `choose_weapon` (literal adicional (revisión)): `if not session or mode!="weapons" or session.ready or transitioning: return`
- L155, `_mouse_confirm` (visual): `if slot<coop.sessions.size() and coop.sessions[slot].device<0: confirm(coop.sessions[slot])`
- L159, `confirm` (literal adicional (revisión)): `if mode=="weapons" and (not Global.is_valid_starting_weapon(session.weapon) or not Progression.is_weapon_unlocked(session.weapon) or not session.character.can_use_weapon(session.weapon)):`
- L165, `confirm` (visual): `if coop.sessions.size()>=2 and holds.is_empty() and coop.sessions.all(func(s): return s.ready and not s.disconnected):`
- L166, `confirm` (literal adicional (revisión)): `if mode=="characters": _to_weapons()`
- L170, `_to_weapons` (visual): `if coop.sessions.size()<2: return`
- L175, `_to_weapons` (literal adicional (revisión)): `mode="weapons"`
- L187, `_to_difficulty` (visual): `if coop.sessions.size()<2: return`
- L188, `_to_difficulty` (literal adicional (revisión)): `mode="difficulty"`
- L194, `_to_difficulty` (literal adicional (revisión)): `Global.main_player_selected=coop.sessions[0].character`
- L195, `_to_difficulty` (literal adicional (revisión)): `Global.main_weapon_selected=coop.sessions[0].weapon`
- L198, `back_to_weapons` (literal adicional (revisión)): `mode="weapons"`
- L207, `back_to_characters` (literal adicional (revisión)): `mode="characters"`
- L217, `start_difficulty` (texto): `if not enabled or mode!="difficulty" or coop.sessions.size()<2: return`
- L223, `refresh` (literal adicional (revisión)): `pair[0].visible=enabled`
- L224, `refresh` (literal adicional (revisión)): `pair[1].get_node("MarginContainer").visible=not enabled`
- L227, `refresh` (literal adicional (revisión)): `for i in 4: _render_card(rows.get_node("Rows").get_child(i),i,rows==weapon_rows,rows==weapon_character_rows)`
- L237, `refresh` (literal adicional (revisión)): `card.modulate.a=1.0`
- L240, `refresh` (literal adicional (revisión)): `for i in 4:`
- L244, `refresh` (texto): `markers.get_child(i).text="P%d%s"%[i+1," ✕" if incompatible else ""]`
- L245, `refresh` (visual): `var colors: Array[Color]=[]`
- L246, `refresh` (literal adicional (revisión)): `for i in 4:`
- L258, `_mouse_preview` (literal adicional (revisión)): `if mode=="characters" and item is UnitStats: choose_character(item)`
- L259, `_mouse_preview` (literal adicional (revisión)): `elif mode=="weapons" and item is ItemWeapon: choose_weapon(item)`
- L268, `_render_card` (texto): `progress.add_theme_stylebox_override("background",UITheme.box(UITheme.palette.surface.lerp(coop.COLORS[slot],0.2),coop.COLORS[slot],8,1))`
- L269, `_render_card` (texto): `progress.add_theme_stylebox_override("fill",UITheme.box(coop.COLORS[slot],Color.TRANSPARENT,8,0))`
- L271, `_render_card` (texto): `solo_notice.get_node("Margin/Message").text=solo_notice_text`
- L273, `_render_card` (literal adicional (revisión)): `solo_notice.visible=enabled and mode=="characters" and coop.sessions.size()==1 and joined and coop.sessions[slot].ready`
- L274, `_render_card` (texto): `if solo_notice.visible: solo_notice.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.inset,UITheme.palette.accent,10,2))`
- L278, `_render_card` (texto): `card.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,coop.COLORS[slot] if joined else UITheme.palette.outline))`
- L280, `_render_card` (texto): `name_label.text="P%d"%(slot+1)`
- L281, `_render_card` (texto): `description.text="Hold A / X or Enter to join" if mode=="characters" else "Sin jugador"`
- L282, `_render_card` (regla/valor): `var held:=0.0`
- L289, `_render_card` (texto): `name_label.text="P%d · %s"%[slot+1,session.weapon.item_name if weapons else session.character.name]`
- L290, `_render_card` (texto): `confirm_button.text="✓" if session.ready else "Ready"`
- L294, `_render_card` (texto): `description.text="Mando desconectado"`
- L296, `_render_card` (texto): `description.text="Personaje de P%d"%(slot+1)`
- L298, `_render_card` (texto): `description.text="Personaje confirmado" if solo_notice.visible else "LISTO · esperando al equipo"`
- L300, `_render_card` (texto): `description.text="✕ No compatible con este personaje"`
- L303, `_render_card` (texto): `description.text=UITheme.rich_text("Damage: %s\nCooldown: %s s\nRange: %s"%[session.weapon.get_damage_description(stats),ItemWeapon.format_number(session.weapon.get_effective_cooldown(stats)),ItemWeapon.format_number(session.weapon.get_effective_range(stats))])`
- L306, `_render_card` (texto): `description.text="\n".join(lines.slice(0,4))`
- L309, `_roster_cards` (regla/valor): `var result: Array=[]`
- L321, `_input` (regla/valor): `var device: int=event.device if event is InputEventJoypadButton or event is InputEventJoypadMotion else -1`
- L330, `_input` (literal adicional (revisión)): `if mode=="difficulty":`
- L332, `_input` (regla/valor): `if coop.sessions.is_empty() or device!=coop.sessions[0].device: return`
- L348, `_input` (texto): `elif mode=="characters" and coop.sessions.size()<4: holds[device]=0.0`
- L356, `_input` (literal adicional (revisión)): `elif mode=="weapons": back_to_characters()`
- L357, `_input` (regla/valor): `elif session.slot>0:`
- L371, `_process` (literal adicional (revisión)): `if mode=="difficulty":`
- L372, `_process` (literal adicional (revisión)): `var session=coop.sessions[0]`
- L374, `_process` (literal adicional (revisión)): `repeat_times[session.device]=maxf(0,float(repeat_times.get(session.device,0))-delta)`
- L375, `_process` (regla/valor): `if direction.length()<0.5:`
- L376, `_process` (literal adicional (revisión)): `repeat_times[session.device]=0.0`
- L377, `_process` (regla/valor): `elif repeat_times[session.device]<=0:`
- L378, `_process` (literal adicional (revisión)): `repeat_times[session.device]=0.18`
- L379, `_process` (regla/valor): `MenuInput.move_focus(Vector2(signf(direction.x),0) if absf(direction.x)>absf(direction.y) else Vector2(0,signf(direction.y)))`
- L386, `_process` (texto): `var columns: int=8 if mode=="weapons" else 3`
- L387, `_process` (regla/valor): `var step: int=(1 if direction.x>0 else -1) if absf(direction.x)>.5 else (columns if direction.y>0 else -columns) if absf(direction.y)>.5 else 0`
- L388, `_process` (literal adicional (revisión)): `repeat_times[session.device]=maxf(0,float(repeat_times.get(session.device,0))-delta)`
- L389, `_process` (regla/valor): `if step==0: repeat_times[session.device]=0.0; continue`
- L390, `_process` (regla/valor): `if repeat_times[session.device]>0: continue`
- L391, `_process` (literal adicional (revisión)): `repeat_times[session.device]=0.18`
- L395, `move_cursor` (regla/valor): `if step==0 or session.ready or session.disconnected or transitioning: return`
- L396, `move_cursor` (regla/valor): `var weapons: bool=mode=="weapons"`
- L397, `move_cursor` (regla/valor): `var direction:=Vector2(signi(step),0) if absi(step)<(8 if weapons else 3) else Vector2(0,signi(step))`
- L412, `move_cursor` (regla/valor): `if forward<=1: continue`
- L415, `move_cursor` (literal adicional (revisión)): `var score:=forward+sideways*4.0`
- L432, `advance_holds` (literal adicional (revisión)): `if mode!="characters": holds.clear(); return`
- L434, `advance_holds` (literal adicional (revisión)): `holds[device]+=maxf(0,delta)`
- L454, `_focus_difficulty` (literal adicional (revisión)): `if not enabled or mode!="difficulty": return`
- L457, `_focus_difficulty` (literal adicional (revisión)): `arena.level_panel.buttons[0].grab_focus()`
- L458, `_focus_difficulty` (literal adicional (revisión)): `arena.level_panel._show_difficulty(0)`

## scenes/coop/coop_shop_panel.gd

377 líneas; 0 anotaciones export; 0 uniforms; 135 candidatos.

Hallazgos: COOP-09.

### Candidatos / evidencia

- L3, `declaración` (constante): `const InventorySlot=preload("res://scenes/coop/coop_inventory_slot.tscn")`
- L6, `declaración` (regla/valor): `var controls: Array[Button]=[]`
- L7, `declaración` (regla/valor): `var offers: Array=[]`
- L8, `declaración` (regla/valor): `var lock_buttons: Array[Button]=[]`
- L9, `declaración` (regla/valor): `var inventory: Array=[]`
- L10, `declaración` (regla/valor): `var inventory_signature: Array=[]`
- L12, `declaración` (regla/valor): `var context_origin:=0`
- L13, `declaración` (regla/valor): `var page := "shop"`
- L14, `declaración` (regla/valor): `var slot_index := 0`
- L16, `declaración` (regla/valor): `var hovered_control := -1`
- L37, `setup` (literal adicional (revisión)): `for i in 4:`
- L41, `setup` (literal adicional (revisión)): `var button=card.get_node("MarginContainer/Control/Actions").get_child(0)`
- L47, `setup` (literal adicional (revisión)): `card.lock_button.tooltip_text=""`
- L51, `setup` (literal adicional (revisión)): `card.lock_button.mouse_entered.connect(_hover.bind(200+i))`
- L52, `setup` (literal adicional (revisión)): `card.lock_button.mouse_exited.connect(_unhover.bind(200+i))`
- L54, `setup` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked(): owner_coop.toggle_lock(session,i)`
- L56, `setup` (literal adicional (revisión)): `_register(view.get_node("Refresh"),4)`
- L57, `setup` (literal adicional (revisión)): `_register(view.get_node("WeaponActions/Margin/Content/Combine"),5)`
- L58, `setup` (literal adicional (revisión)): `_register(view.get_node("WeaponActions/Margin/Content/Sell"),6)`
- L59, `setup` (literal adicional (revisión)): `_register(view.get_node("Ready"),7)`
- L63, `setup` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked(): close_weapon_actions())`
- L64, `setup` (literal adicional (revisión)): `close.mouse_entered.connect(_hover.bind(100))`
- L65, `setup` (literal adicional (revisión)): `close.mouse_exited.connect(_unhover.bind(100))`
- L66, `setup` (literal adicional (revisión)): `_register(view.get_node("StatsButton"),8)`
- L69, `setup` (literal adicional (revisión)): `items.mouse_entered.connect(_hover.bind(300))`
- L70, `setup` (literal adicional (revisión)): `items.mouse_exited.connect(_unhover.bind(300))`
- L72, `setup` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked() and context_target()==null:`
- L73, `setup` (literal adicional (revisión)): `select(300)`
- L74, `setup` (literal adicional (revisión)): `owner_coop.activate(session,300))`
- L77, `setup` (literal adicional (revisión)): `shop.mouse_entered.connect(_hover.bind(301))`
- L78, `setup` (literal adicional (revisión)): `shop.mouse_exited.connect(_unhover.bind(301))`
- L80, `setup` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked() and context_target()==null:`
- L81, `setup` (literal adicional (revisión)): `select(301)`
- L82, `setup` (literal adicional (revisión)): `owner_coop.activate(session,301))`
- L87, `setup` (regla/valor): `if session.device>=0: target.mouse_filter=Control.MOUSE_FILTER_IGNORE`
- L89, `setup` (visual): `sheet.stat_help.scale=Vector2.ONE`
- L99, `_show_initial_selection` (literal adicional (revisión)): `hovered_control=-1`
- L109, `_register` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked():`
- L110, `_register` (regla/valor): `if context_target()!=null and index not in [5,6]: return`
- L116, `_hover` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked():`
- L123, `_unhover` (regla/valor): `if session.device<0 and hovered_control==index:`
- L124, `_unhover` (literal adicional (revisión)): `hovered_control=-1`
- L131, `select` (regla/valor): `if context_target()!=null and index not in [5,6,100]: return`
- L135, `select` (visual): `if index>=9 and index<controls.size():`
- L148, `set_page` (texto): `session.cursor=0 if page=="shop" else 301`
- L153, `_apply_page` (regla/valor): `var reward: bool=owner_coop.mode=="rewards"`
- L154, `_apply_page` (literal adicional (revisión)): `view.get_node("Cards").visible=page=="shop"`
- L155, `_apply_page` (literal adicional (revisión)): `view.get_node("Inventory").visible=page!="stats" and not reward`
- L156, `_apply_page` (literal adicional (revisión)): `view.get_node("Inventory/PassivesPanel").visible=page=="items"`
- L157, `_apply_page` (literal adicional (revisión)): `view.get_node("Inventory/WeaponsPanel").visible=page=="shop"`
- L158, `_apply_page` (literal adicional (revisión)): `stats.visible=page=="stats"`
- L159, `_apply_page` (literal adicional (revisión)): `stats_secondary.visible=page=="stats"`
- L160, `_apply_page` (literal adicional (revisión)): `if page=="stats":`
- L163, `_apply_page` (literal adicional (revisión)): `view.get_node("Refresh").visible=page=="shop" and not reward`
- L168, `_apply_page` (literal adicional (revisión)): `view.get_node("ShopButton").disabled=page=="shop" or session.disconnected`
- L169, `_apply_page` (literal adicional (revisión)): `view.get_node("ItemsButton").disabled=page=="items" or session.disconnected`
- L170, `_apply_page` (literal adicional (revisión)): `view.get_node("StatsButton").disabled=page=="stats" or session.disconnected`
- L176, `move_selector` (regla/valor): `var options: Array=[5,6,100] if owner_coop.can_combine(session,context_weapon) else [6,100]`
- L178, `move_selector` (visual): `select(options[posmod(current+(1 if direction.x>0 or direction.y>0 else -1),options.size())])`
- L181, `move_selector` (regla/valor): `var targets: Dictionary={}`
- L183, `move_selector` (literal adicional (revisión)): `for i in lock_buttons.size(): targets[200+i]=lock_buttons[i]`
- L184, `move_selector` (literal adicional (revisión)): `targets[300]=view.get_node("ItemsButton")`
- L185, `move_selector` (literal adicional (revisión)): `targets[301]=view.get_node("ShopButton")`
- L186, `move_selector` (literal adicional (revisión)): `var origin: Button=targets.get(session.cursor,controls[0])`
- L187, `move_selector` (regla/valor): `var selected: int=-1`
- L194, `move_selector` (regla/valor): `if forward<=1: continue`
- L195, `move_selector` (literal adicional (revisión)): `var candidate=forward+absf(offset.cross(direction))*4`
- L197, `move_selector` (regla/valor): `if selected>=0: select(selected)`
- L201, `_inventory` (regla/valor): `var entries: Array=[]`
- L202, `_inventory` (literal adicional (revisión)): `for weapon in session.actor.current_weapons: entries.append({"item":weapon.data,"count":1,"weapon":true,"instance":weapon})`
- L206, `_inventory` (regla/valor): `if not entry.weapon and entry.item==record.item: entry.count+=1; found=true; break`
- L207, `_inventory` (texto): `if not found: entries.append({"item":record.item,"count":1,"weapon":false,"instance":null})`
- L208, `_inventory` (regla/valor): `var signature: Array=[]`
- L214, `_inventory` (literal adicional (revisión)): `controls.resize(9)`
- L226, `_inventory` (literal adicional (revisión)): `_register(button,9+i)`
- L227, `_inventory` (literal adicional (revisión)): `for i in maxi(0,session.actor.get_weapon_limit()-session.actor.current_weapons.size()):`
- L228, `_inventory` (texto): `var empty=preload("res://scenes/coop/empty_inventory_slot.tscn").instantiate()`
- L230, `_inventory` (visual): `if session.cursor>=9 and session.cursor<100: session.cursor=mini(session.cursor,controls.size()-1)`
- L236, `present` (texto): `var upgrades: bool=owner_coop.mode=="upgrades"`
- L238, `present` (texto): `view.get_node("Balance").text=str(session.coins)`
- L239, `present` (literal adicional (revisión)): `for i in 4:`
- L253, `present` (texto): `card.item_cost.text="CONSERVAR" if reward and i==0 else "VENDER %d"%item.get_sell_price(card.shop_wave) if reward else "ELEGIR" if upgrades else str(item.get_shop_price(card.shop_wave))`
- L254, `present` (texto): `if item is ItemUpgrade: card.item_description.text="%s %s"%[ItemWeapon.format_number(item.value),item.stat_id]`
- L255, `present` (literal adicional (revisión)): `for i in 4:`
- L256, `present` (literal adicional (revisión)): `controls[4+i].disabled=session.disconnected or reward or (session.ready and i!=3) or (upgrades and i>0)`
- L257, `present` (texto): `view.get_node("Refresh/Content/CostLabel").text="REFRESH %d"%ItemBase.ECONOMY_RULES.reroll_price(owner_coop.arena.spawner.wave_index,session.rerolls)`
- L258, `present` (texto): `controls[7].text="LISTO"`
- L259, `present` (literal adicional (revisión)): `$ReadyShade.visible=session.ready and owner_coop.mode=="shop"`
- L261, `present` (regla/valor): `if i in [5,6]: continue`
- L263, `present` (regla/valor): `if i==7:`
- L265, `present` (visual): `for state in states: button.add_theme_stylebox_override(state,states[state])`
- L266, `present` (regla/valor): `else: UITheme.style_slot(button,inventory[i-9].item.item_tier if i>=9 else 0)`
- L270, `present` (literal adicional (revisión)): `style.set_border_width_all(maxi(4,UITheme.palette.focus_width))`
- L271, `present` (texto): `button.add_theme_stylebox_override("normal",style)`
- L273, `present` (regla/valor): `if _highlighted(200+i):`
- L276, `present` (literal adicional (revisión)): `border.set_border_width_all(maxi(4,UITheme.palette.focus_width))`
- L277, `present` (texto): `lock_buttons[i].add_theme_stylebox_override("normal",border)`
- L278, `present` (texto): `lock_buttons[i].add_theme_stylebox_override("pressed",border)`
- L279, `present` (literal adicional (revisión)): `for pair in [["ItemsButton",300],["ShopButton",301]]:`
- L280, `present` (literal adicional (revisión)): `var button: Button=view.get_node(pair[0])`
- L281, `present` (literal adicional (revisión)): `UITheme.style_slot(button,0)`
- L282, `present` (regla/valor): `if _highlighted(pair[1]) and not button.disabled:`
- L283, `present` (texto): `button.add_theme_stylebox_override("normal",UITheme.box(UITheme.palette.hover_surface,owner_coop.COLORS[session.slot],14,4))`
- L289, `_show_detail` (visual): `var valid: bool=context_target()==null and session.cursor>=9 and session.cursor-9<inventory.size() and controls[session.cursor].is_visible_in_tree()`
- L298, `scroll_detail` (texto): `if session.cursor>=9: view.get_node("Inspect").full_description.get_v_scroll_bar().value+=amount*2`
- L299, `scroll_detail` (regla/valor): `elif session.cursor<4 and offers[session.cursor].visible: offers[session.cursor].item_description.get_v_scroll_bar().value+=amount*2`
- L304, `show_waiting` (texto): `$Empty.text="Listo"`
- L305, `show_waiting` (texto): `$Empty.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L307, `show_waiting` (texto): `add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,Color.TRANSPARENT,0,0))`
- L313, `activate_inventory` (visual): `if session.ready or index<9 or index-9>=inventory.size(): return`
- L314, `activate_inventory` (literal adicional (revisión)): `var entry=inventory[index-9]`
- L320, `activate_inventory` (regla/valor): `session.cursor=5 if owner_coop.can_combine(session,context_weapon) else 6`
- L327, `close_weapon_actions` (literal adicional (revisión)): `session.cursor=clampi(context_origin,0,controls.size()-1)`
- L335, `_render_weapon_actions` (texto): `popup.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,UITheme.palette.outline,16,2))`
- L336, `_render_weapon_actions` (texto): `controls[5].text="COMBINAR"`
- L337, `_render_weapon_actions` (literal adicional (revisión)): `controls[5].disabled=not owner_coop.can_combine(session,weapon) or session.ready`
- L338, `_render_weapon_actions` (texto): `controls[6].text="VENDER · %d YEMAS"%weapon.data.get_sell_price(owner_coop.arena.spawner.wave_index)`
- L339, `_render_weapon_actions` (literal adicional (revisión)): `controls[6].disabled=session.ready`
- L341, `_render_weapon_actions` (literal adicional (revisión)): `for pair in [[controls[5],5],[controls[6],6],[close,100]]:`
- L342, `_render_weapon_actions` (literal adicional (revisión)): `var button: Button=pair[0]`
- L343, `_render_weapon_actions` (visual): `var fill: Color=UITheme.palette.danger if pair[1]==6 else UITheme.palette.button`
- L345, `_render_weapon_actions` (visual): `for state in styles: button.add_theme_stylebox_override(state,styles[state])`
- L346, `_render_weapon_actions` (texto): `if _highlighted(pair[1]): button.add_theme_stylebox_override("normal",styles.hover)`
- L349, `_render_weapon_actions` (visual): `var point:=Vector2(rect.get_center().x-popup.size.x*.5,rect.position.y-popup.size.y-12)`
- L350, `_render_weapon_actions` (visual): `popup.position=point.clamp(Vector2(12,12),view.size-popup.size-Vector2(12,12))`
- L354, `_input` (regla/valor): `if is_visible_in_tree() and session and session.device<0 and event is InputEventMouseMotion and event.relative.length_squared()>0:`
- L356, `_input` (regla/valor): `if is_visible_in_tree() and session and session.device<0 and event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:`
- L359, `_input` (regla/valor): `scroll_detail(-100.0 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 100.0)`
- L362, `_input` (regla/valor): `if not is_visible_in_tree() or not session or session.device>=0 or context_target()==null: return`
- L371, `_refresh_panel_style` (texto): `add_theme_stylebox_override("panel",UITheme.box(color,color,12,3))`
- L373, `_refresh_panel_style` (texto): `$InnerFrame/Surface.add_theme_stylebox_override("panel",UITheme.box(UITheme.palette.surface,Color.TRANSPARENT,12,0))`
- L374, `_refresh_panel_style` (texto): `$TabAnchor/PlayerTab.add_theme_stylebox_override("panel",UITheme.box(color,Color.TRANSPARENT,7,0))`
- L375, `_refresh_panel_style` (texto): `$TabAnchor/PlayerTab/Label.text="P%d"%(slot_index+1)`
- L376, `_refresh_panel_style` (texto): `$TabAnchor/PlayerTab/Label.add_theme_color_override("font_color",UITheme.palette.surface)`
- L377, `_refresh_panel_style` (literal adicional (revisión)): `if session and owner_coop.mode=="rewards" and session.rewards.is_empty(): show_waiting()`

## scenes/coop/coop_upgrade_panel.gd

90 líneas; 0 anotaciones export; 0 uniforms; 25 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var controls: Array[Button]=[]`
- L5, `declaración` (regla/valor): `var cards: Array=[]`
- L7, `declaración` (regla/valor): `var hovered_control:=-1`
- L12, `setup` (texto): `$HeaderOverlay/PlayerLabel.text="P%d" % (slot+1)`
- L13, `setup` (texto): `$HeaderOverlay/PlayerLabel.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L14, `setup` (texto): `$HeaderOverlay/PlayerLabel.add_theme_stylebox_override("normal",UITheme.box(controller.COLORS[slot],Color.TRANSPARENT,12,0))`
- L15, `setup` (texto): `add_theme_stylebox_override("panel",UITheme.box(Color.TRANSPARENT,controller.COLORS[slot],12,2))`
- L16, `setup` (texto): `$Waiting.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L17, `setup` (texto): `$Margin/Content/Header.add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L19, `setup` (texto): `$Margin.hide(); $Waiting.show(); $Waiting.text="Jugador no conectado"`
- L21, `setup` (literal adicional (revisión)): `for i in 4:`
- L29, `setup` (literal adicional (revisión)): `_register(view.get_node("Refresh"),4)`
- L37, `_register` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked(): controller.activate(session,index))`
- L40, `_hover` (regla/valor): `if session.device<0 and not MenuInput.coop_mouse_blocked():`
- L46, `_unhover` (regla/valor): `if session.device<0 and hovered_control==index:`
- L47, `_unhover` (literal adicional (revisión)): `hovered_control=-1`
- L57, `move_selector` (literal adicional (revisión)): `var origin=controls[clampi(session.cursor,0,4)]`
- L64, `move_selector` (regla/valor): `if forward<=1: continue`
- L65, `move_selector` (literal adicional (revisión)): `var value=forward+absf(offset.cross(direction))*4`
- L76, `present` (literal adicional (revisión)): `for i in 4:`
- L82, `present` (literal adicional (revisión)): `UITheme.style_slot(controls[i],0)`
- L86, `present` (literal adicional (revisión)): `style.set_border_width_all(maxi(4,UITheme.palette.focus_width))`
- L87, `present` (texto): `controls[i].add_theme_stylebox_override("normal",style)`
- L89, `present` (texto): `controls[4].text="REFRESH %d"%cost`
- L90, `present` (literal adicional (revisión)): `controls[4].disabled=session.disconnected or session.coins<cost`

## scenes/coop/local_coop.gd

770 líneas; 0 anotaciones export; 0 uniforms; 167 candidatos.

Hallazgos: COOP-01, COOP-04, COOP-05, COOP-07, COOP-08, INPUT-02.

### Candidatos / evidencia

- L3, `declaración` (constante): `const Session = preload("res://resources/coop_player_session.gd")`
- L4, `declaración` (constante): `const RewardPanelScene = preload("res://scenes/coop/coop_reward_panel.tscn")`
- L5, `declaración` (constante): `const UpgradePanelScene = preload("res://scenes/coop/coop_upgrade_panel.tscn")`
- L6, `declaración` (constante): `const PanelScene = preload("res://scenes/coop/coop_player_panel.tscn")`
- L7, `declaración` (constante): `const LobbySlot = preload("res://scenes/coop/lobby_slot.tscn")`
- L8, `declaración` (constante): `const LobbyPlayer = preload("res://scenes/coop/lobby_player.tscn")`
- L9, `declaración` (constante): `const Bias = preload("res://resources/shop_weapon_bias.gd")`
- L10, `declaración` (constante): `const ShopRarity = preload("res://resources/shop_rarity.gd")`
- L11, `declaración` (constante): `const UpgradeRarity = preload("res://resources/upgrade_rarity.gd")`
- L12, `declaración` (constante): `const COLORS := [Color("16778b"),Color("ae4d53"),Color("4967a4"),Color("936719")]`
- L13, `declaración` (constante): `const MAX_PLAYERS := 4`
- L14, `declaración` (constante): `const MAX_SHOP_WEAPONS := 2`
- L17, `declaración` (regla/valor): `var sessions: Array = []`
- L19, `declaración` (regla/valor): `var mode := ""`
- L22, `declaración` (regla/valor): `var pause_repeat := 0.0`
- L23, `declaración` (regla/valor): `var repeat_times: Dictionary = {}`
- L24, `declaración` (regla/valor): `var panels: Array[Control] = []`
- L25, `declaración` (regla/valor): `var reward_queues: Array = []`
- L27, `declaración` (regla/valor): `var corpses: Array[Node2D] = []`
- L52, `open` (literal adicional (revisión)): `mode="characters"`
- L69, `join` (literal adicional (revisión)): `session.character=arena.selection_panel.player_list[0]`
- L70, `join` (literal adicional (revisión)): `session.weapon=arena.weapon_selection_panel.weapons_list[0]`
- L81, `_catalogue` (regla/valor): `var result: Array=[]`
- L82, `_catalogue` (literal adicional (revisión)): `for item in (arena.selection_panel.player_list if mode=="characters" else arena.weapon_selection_panel.weapons_list):`
- L83, `_catalogue` (literal adicional (revisión)): `if mode=="characters" and Progression.is_character_unlocked(item): result.append(item)`
- L84, `_catalogue` (literal adicional (revisión)): `elif mode=="weapons" and Global.is_valid_starting_weapon(item) and Progression.is_weapon_unlocked(item): result.append(item)`
- L94, `_refresh_lobby` (texto): `title.text="ELEGIR PERSONAJES" if mode=="characters" else "ELEGIR ARMAS"`
- L95, `_refresh_lobby` (texto): `hint.text="Enter / A: unirse o confirmar · WASD / stick: elegir · Esc / B: cancelar · prueba de 2 jugadores"`
- L103, `_refresh_lobby` (literal adicional (revisión)): `button.icon=item.icon if mode=="characters" else item.item_icon`
- L107, `_refresh_lobby` (texto): `if (session.character if mode=="characters" else session.weapon)==item: owners.append("P%d"%(session.slot+1))`
- L108, `_refresh_lobby` (texto): `button.text=" ".join(owners)`
- L110, `_refresh_lobby` (visual): `(left if i < ceili(slots.size()/2.0) else right).add_child(button)`
- L113, `_refresh_lobby` (literal adicional (revisión)): `button.icon=session.character.icon if mode=="characters" else session.weapon.item_icon`
- L115, `_refresh_lobby` (texto): `button.text="P%d · %s\n%s%s"%[session.slot+1,session.character.name if mode=="characters" else session.weapon.item_name,"LISTO" if session.ready else "Elegir", " · teclado" if session.device<0 else " · mando %d"%session.device]`
- L116, `_refresh_lobby` (texto): `button.add_theme_stylebox_override("normal",UITheme.box(UITheme.palette.surface,COLORS[session.slot]))`
- L122, `_mouse_choose` (regla/valor): `if not session: session=join(-1)`
- L126, `_mouse_confirm` (regla/valor): `if sessions[slot].device<0: _confirm_lobby(sessions[slot])`
- L133, `_choose_lobby` (literal adicional (revisión)): `if mode=="characters":`
- L141, `_confirm_lobby` (literal adicional (revisión)): `if mode=="weapons" and not session.character.can_use_weapon(session.weapon): return`
- L143, `_confirm_lobby` (visual): `if sessions.size()>=2 and sessions.all(func(s): return s.ready):`
- L144, `_confirm_lobby` (literal adicional (revisión)): `if mode=="characters":`
- L145, `_confirm_lobby` (literal adicional (revisión)): `mode="weapons"`
- L148, `_confirm_lobby` (literal adicional (revisión)): `s.cursor=0`
- L158, `_keyboard_session` (regla/valor): `if session.device<0: return session`
- L165, `_input` (regla/valor): `var device: int = event.device if event is InputEventJoypadButton or event is InputEventJoypadMotion else -1`
- L172, `_input` (literal adicional (revisión)): `if mode=="result" and (accept or cancel):`
- L202, `_input` (literal adicional (revisión)): `if mode=="shop" and cancel and panels[session.slot].context_target()!=null:`
- L206, `_input` (literal adicional (revisión)): `if mode=="shop" and cancel and panels[session.slot].page!="shop":`
- L210, `_input` (literal adicional (revisión)): `if active and mode=="combat":`
- L218, `_input` (literal adicional (revisión)): `elif mode=="weapons":`
- L219, `_input` (literal adicional (revisión)): `mode="characters"`
- L225, `_input` (literal adicional (revisión)): `elif mode=="shop" and ((event is InputEventJoypadButton and event.pressed and event.button_index==JOY_BUTTON_Y) or (event is InputEventKey and event.pressed and event.physical_keycode==KEY_TAB)):`
- L235, `_process` (literal adicional (revisión)): `hud.visible=active and mode=="combat" and not paused`
- L239, `_process` (literal adicional (revisión)): `pause_repeat=maxf(0,pause_repeat-delta)`
- L240, `_process` (regla/valor): `if movement.length()<0.5: pause_repeat=0`
- L241, `_process` (regla/valor): `elif pause_repeat<=0:`
- L242, `_process` (literal adicional (revisión)): `pause_repeat=0.18`
- L243, `_process` (regla/valor): `MenuInput.move_focus(Vector2(signf(movement.x),0) if absf(movement.x)>absf(movement.y) else Vector2(0,signf(movement.y)))`
- L250, `_process` (literal adicional (revisión)): `var widget=hud.get_node("P%d" % (i+1))`
- L255, `_process` (texto): `widget.get_node("PlayerLabel").text="P%d" % (i+1)`
- L256, `_process` (texto): `widget.get_node("Wallet/Balance/Value").text=str(session.coins)`
- L257, `_process` (texto): `widget.get_node("Wallet/Balance/Value").add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L258, `_process` (texto): `widget.get_node("Wallet/Reserve/Value").text=str(sessions.reduce(func(total,s): return total+s.reserve,0))`
- L259, `_process` (texto): `widget.get_node("Wallet/Reserve/Value").add_theme_color_override("font_color",UITheme.palette.hud_text)`
- L260, `_process` (literal adicional (revisión)): `widget.get_node("Health").update_bar(health.current_health/maxf(1.0,health.max_health),health.current_health)`
- L264, `_process` (texto): `bar.health_value.text="LV %d  %d / %d" % [xp.level,xp.experience,xp.required_experience()]`
- L267, `_process` (literal adicional (revisión)): `if session.disconnected or (mode=="upgrades" and session.experience.pending_levels.is_empty()) or (mode=="rewards" and session.rewards.is_empty()): continue`
- L268, `_process` (literal adicional (revisión)): `if mode=="shop":`
- L269, `_process` (regla/valor): `var scroll_axis: float=Input.get_joy_axis(session.device,JOY_AXIS_RIGHT_Y) if session.device>=0 else float(Input.is_physical_key_pressed(KEY_PAGEDOWN))-float(Input.is_physical_key_pressed(KEY_PAGEUP))`
- L270, `_process` (regla/valor): `if absf(scroll_axis)>.2: panels[session.slot].scroll_detail(scroll_axis*delta*300)`
- L272, `_process` (texto): `var columns: int = 2 if mode in ["shop","upgrades","rewards"] else 4`
- L273, `_process` (regla/valor): `var step: int = (1 if movement.x>0 else -1) if absf(movement.x)>.5 else (columns if movement.y>0 else -columns) if absf(movement.y)>.5 else 0`
- L274, `_process` (literal adicional (revisión)): `repeat_times[session.slot]=maxf(0,float(repeat_times.get(session.slot,0))-delta)`
- L275, `_process` (regla/valor): `if step==0: repeat_times[session.slot]=0; continue`
- L276, `_process` (regla/valor): `if repeat_times[session.slot]>0: continue`
- L277, `_process` (literal adicional (revisión)): `repeat_times[session.slot]=.2`
- L278, `_process` (texto): `if mode in ["shop","upgrades","rewards"]: panels[session.slot].move_selector(Vector2(signi(step),0) if absi(step)==1 else Vector2(0,signi(step)))`
- L292, `_set_paused` (literal adicional (revisión)): `Global.game_paused=value or mode!="combat"`
- L294, `_set_paused` (literal adicional (revisión)): `arena.coocking_player.stream_paused=value or mode!="combat"`
- L298, `_set_paused` (regla/valor): `pause_owner=owner_session if owner_session else sessions[0]`
- L310, `_set_paused` (literal adicional (revisión)): `screen.visible=mode!="combat"`
- L312, `start_run` (literal adicional (revisión)): `func start_run(difficulty: int = 0) -> void:`
- L315, `start_run` (literal adicional (revisión)): `mode="combat"`
- L338, `start_run` (literal adicional (revisión)): `session.reserve=0`
- L345, `start_run` (texto): `actor.shadow.material.set_shader_parameter("outline_color",COLORS[session.slot])`
- L348, `start_run` (literal adicional (revisión)): `Global.player=sessions[0].actor`
- L356, `start_run` (literal adicional (revisión)): `_process(0.0)`
- L364, `configure_players` (literal adicional (revisión)): `session.actor.global_position=area.clamp_position(area.movement_bounds.get_center()+Vector2((session.slot-(sessions.size()-1)*.5)*120,0))`
- L371, `_level_gained` (literal adicional (revisión)): `actor.stats.apply_stat_change("health",1)`
- L373, `_level_gained` (literal adicional (revisión)): `actor.health_component.heal(maxf(0,actor.stats.health-before))`
- L376, `collect_yolk` (regla/valor): `var bonus:=0`
- L379, `collect_yolk` (literal adicional (revisión)): `for session in sessions: bonus=maxi(bonus,session.collect(maxi(0,amount)))`
- L397, `player_down` (texto): `var corpse=preload("res://scenes/coop/player_corpse.tscn").instantiate()`
- L410, `player_down` (literal adicional (revisión)): `mode="result"`
- L412, `player_down` (texto): `title.text="DERROTA DEL EQUIPO"`
- L413, `player_down` (texto): `hint.text="Todos los jugadores han caído."`
- L416, `wave_completed` (literal adicional (revisión)): `if transitioning or not active or mode!="combat": return`
- L421, `wave_completed` (regla/valor): `var bank:=0`
- L423, `wave_completed` (regla/valor): `if is_instance_valid(pickup) and not pickup.awarded: bank+=maxi(0,pickup.value)`
- L424, `wave_completed` (visual): `for i in sessions.size(): sessions[i].reserve=bank/sessions.size()+(1 if i<bank%sessions.size() else 0)`
- L428, `wave_completed` (regla/valor): `await get_tree().create_timer(1.0).timeout`
- L429, `wave_completed` (literal adicional (revisión)): `if not active or mode!="combat":`
- L435, `wave_completed` (literal adicional (revisión)): `mode="result"`
- L439, `wave_completed` (texto): `title.text="¡VICTORIA DEL EQUIPO!"`
- L440, `wave_completed` (texto): `hint.text="Cooperativo de prueba completado."`
- L457, `_show_post_wave_phase` (literal adicional (revisión)): `session.cursor=0`
- L458, `_show_post_wave_phase` (literal adicional (revisión)): `session.rerolls=0`
- L461, `_show_post_wave_phase` (literal adicional (revisión)): `if phase=="shop" and not session.saved_shop_offers.is_empty():`
- L463, `_show_post_wave_phase` (literal adicional (revisión)): `for i in 4: session.locked[i]=session.offers[i]!=null`
- L466, `_show_post_wave_phase` (literal adicional (revisión)): `for slot in 4:`
- L467, `_show_post_wave_phase` (texto): `var panel=(UpgradePanelScene if mode=="upgrades" else RewardPanelScene if mode=="rewards" else PanelScene).instantiate()`
- L472, `_show_post_wave_phase` (literal adicional (revisión)): `if mode=="shop": tarena_music_shop()`
- L475, `_advance_post_wave_phase` (literal adicional (revisión)): `if mode=="rewards" and sessions.all(func(s): return s.rewards.is_empty()):`
- L477, `_advance_post_wave_phase` (literal adicional (revisión)): `elif mode=="upgrades" and sessions.all(func(s): return s.experience.pending_levels.is_empty()):`
- L482, `_activate_upgrade` (regla/valor): `if index==4:`
- L487, `_activate_upgrade` (regla/valor): `session.coins-=cost; session.rerolls+=1`
- L489, `_activate_upgrade` (regla/valor): `elif index>=0 and index<4:`
- L497, `_activate_upgrade` (literal adicional (revisión)): `session.cursor=0`
- L506, `_mouse_activate` (regla/valor): `if session.device<0: activate(session,index)`
- L509, `_mouse_hover` (regla/valor): `if session.device<0:`
- L514, `_pool` (regla/valor): `var pool: Array=[]`
- L527, `roll_offers` (literal adicional (revisión)): `if mode=="rewards":`
- L530, `roll_offers` (literal adicional (revisión)): `session.offers.assign([session.rewards[0],session.rewards[0],null,null])`
- L532, `roll_offers` (texto): `var upgrade: bool=mode=="upgrades"`
- L535, `roll_offers` (regla/valor): `var previous: Array=[]`
- L540, `roll_offers` (literal adicional (revisión)): `session.offers.resize(4)`
- L542, `roll_offers` (regla/valor): `var weapons:=0`
- L544, `roll_offers` (literal adicional (revisión)): `for i in 4:`
- L547, `roll_offers` (regla/valor): `if old[i] is ItemWeapon: weapons+=1`
- L550, `roll_offers` (literal adicional (revisión)): `var guarantee: bool=not upgrade and old.is_empty() and held.size()<3`
- L551, `roll_offers` (literal adicional (revisión)): `for i in 4:`
- L553, `roll_offers` (literal adicional (revisión)): `var tier: int=UpgradeRarity.roll_tier(session.experience.pending_levels[0]) if upgrade else ShopRarity.roll_tier(arena.spawner.wave_index)`
- L554, `roll_offers` (regla/valor): `var candidates=pool.filter(func(item): return item.item_tier==tier and not keys.has(item.get_offer_key()) and (upgrade or weapons<2 or not item is ItemWeapon))`
- L555, `roll_offers` (regla/valor): `if guarantee and weapons<2:`
- L558, `roll_offers` (regla/valor): `if candidates.is_empty(): candidates=pool.filter(func(item): return item.item_tier<=tier and not keys.has(item.get_offer_key()) and (upgrade or weapons<2 or not item is ItemWeapon))`
- L563, `roll_offers` (regla/valor): `if item is ItemWeapon: weapons+=1`
- L566, `_refill_purchased_offer` (regla/valor): `var excluded: Array=[]`
- L567, `_refill_purchased_offer` (regla/valor): `var weapons:=0`
- L571, `_refill_purchased_offer` (regla/valor): `if session.offers[i] is ItemWeapon: weapons+=1`
- L582, `toggle_lock` (literal adicional (revisión)): `func toggle_lock(session,offer_index: int=-1) -> void:`
- L583, `toggle_lock` (regla/valor): `var index: int=offer_index if offer_index>=0 else session.cursor-200 if session.cursor>=200 and session.cursor<204 else session.cursor`
- L584, `toggle_lock` (texto): `if mode!="shop" or session.disconnected or session.ready or index<0 or index>3 or not session.rewards.is_empty() or index>=session.offers.size() or not session.offers[index]: return`
- L592, `activate` (literal adicional (revisión)): `if mode=="upgrades":`
- L595, `activate` (literal adicional (revisión)): `if mode=="rewards" and session.rewards.is_empty(): return`
- L596, `activate` (regla/valor): `if index==301:`
- L599, `activate` (regla/valor): `if index==300:`
- L602, `activate` (regla/valor): `if index>=200 and index<204:`
- L603, `activate` (literal adicional (revisión)): `toggle_lock(session,index-200)`
- L605, `activate` (regla/valor): `if index>=8:`
- L606, `activate` (regla/valor): `if index==100: panels[session.slot].close_weapon_actions()`
- L607, `activate` (regla/valor): `elif index==8: panels[session.slot].toggle_stats()`
- L610, `activate` (literal adicional (revisión)): `if mode=="rewards":`
- L611, `activate` (regla/valor): `if index>1: return`
- L612, `activate` (literal adicional (revisión)): `var reward: ItemPassive=session.rewards[0]`
- L613, `activate` (regla/valor): `if index==0:`
- L617, `activate` (regla/valor): `SoundManager.play_sound(SoundManager.Sound.UI_ACCEPT if index==0 else SoundManager.Sound.SHOP_SELL)`
- L624, `activate` (regla/valor): `if index==7:`
- L629, `activate` (regla/valor): `elif index<4:`
- L647, `activate` (regla/valor): `elif index==4:`
- L652, `activate` (regla/valor): `session.coins-=cost; session.rerolls+=1`
- L655, `activate` (regla/valor): `elif index==5:`
- L662, `activate` (regla/valor): `elif index==6:`
- L710, `_render_panel` (literal adicional (revisión)): `if mode=="rewards" and session.rewards.is_empty():`
- L722, `next_wave` (literal adicional (revisión)): `mode="combat"`
- L727, `next_wave` (literal adicional (revisión)): `for i in 4:`
- L737, `next_wave` (regla/valor): `arena.spawner.wave_index+=1`
- L760, `stop` (literal adicional (revisión)): `mode=""`

## scenes/coop/shop_canvas_fit.gd

12 líneas; 1 anotaciones export; 0 uniforms; 3 candidatos.

### Ya expuesto en el editor

- L4: `@export var design_size:=Vector2(1880,980)`

### Candidatos / evidencia

- L10, `_notification` (visual): `child.size=design_size`
- L11, `_notification` (visual): `child.scale=Vector2.ONE*factor`
- L12, `_notification` (visual): `child.position=(size-design_size*factor)*.5`

## scenes/coop/shop_quadrants.gd

15 líneas; 1 anotaciones export; 0 uniforms; 5 candidatos.

Hallazgos: UI-09.

### Ya expuesto en el editor

- L3: `@export var separation:=14.0:`

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var columns:=2`
- L10, `_notification` (literal adicional (revisión)): `var cell: Vector2=(size-Vector2.ONE*separation)/2.0`
- L11, `_notification` (regla/valor): `var index:=0`
- L14, `_notification` (literal adicional (revisión)): `fit_child_in_rect(child,Rect2(Vector2(index%2,index/2)*(cell+Vector2.ONE*separation),cell))`
- L15, `_notification` (regla/valor): `index+=1`

## scenes/effects/spawn_effect.gd

22 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L10, `_ready` (literal adicional (revisión)): `z_index = -1`

## scenes/health_bar/health_bar.gd

96 líneas; 5 anotaciones export; 0 uniforms; 17 candidatos.

### Ya expuesto en el editor

- L4: `@export var use_ui_palette := false`
- L5: `@export var experience_bar := false`
- L6: `@export var back_color: Color`
- L7: `@export var fill_color: Color`
- L8: `@export_range(0.05, 1.0) var damage_flash_duration := 0.28`

### Candidatos / evidencia

- L9, `declaración` (regla/valor): `var flash_left := 0.0`
- L11, `declaración` (regla/valor): `var displayed_health := 0.0`
- L34, `_ready` (texto): `progress_bar.add_theme_stylebox_override("background", back_style)`
- L35, `_ready` (texto): `progress_bar.add_theme_stylebox_override("fill", fill_style)`
- L41, `_apply_ui_palette` (texto): `progress_bar.add_theme_stylebox_override("background",background)`
- L44, `_apply_ui_palette` (texto): `progress_bar.add_theme_stylebox_override("fill",fill)`
- L45, `_apply_ui_palette` (texto): `clipped_fill.material.set_shader_parameter("fill_color",palette.experience_fill if experience_bar else palette.health_fill)`
- L48, `_apply_ui_palette` (texto): `$ProgressBar/Outline.add_theme_stylebox_override("panel",outline)`
- L50, `_apply_ui_palette` (texto): `health_value.add_theme_color_override("font_color",palette.hud_text)`
- L54, `_sync_clipped_fill` (texto): `clipped_fill.material.set_shader_parameter("bar_size", progress_bar.size)`
- L55, `_sync_clipped_fill` (texto): `clipped_fill.material.set_shader_parameter("ratio", progress_bar.ratio)`
- L65, `_refresh_health_label` (texto): `health_value.text = ItemWeapon.format_number(displayed_health)`
- L73, `reset_damage_flash` (literal adicional (revisión)): `flash_left = 0.0`
- L81, `_process` (regla/valor): `if flash_left <= 0.0: return`
- L82, `_process` (literal adicional (revisión)): `flash_left = maxf(0.0, flash_left - delta)`
- L83, `_process` (regla/valor): `if flash_left<=0.0: set_process(false)`
- L87, `_process` (texto): `if clipped_fill: clipped_fill.material.set_shader_parameter("fill_color", flash_color)`

## scenes/health_bar/rounded_fill.gdshader

21 líneas; 0 anotaciones export; 5 uniforms; 11 candidatos.

### Uniforms editables

- L2: `uniform vec2 bar_size = vec2(320.0,48.0);`
- L3: `uniform float ratio : hint_range(0.0,1.0) = 1.0;`
- L4: `uniform float radius = 24.0;`
- L5: `uniform float inset = 5.0;`
- L6: `uniform vec4 fill_color : source_color = vec4(0.9,0.3,0.35,1.0);`

### Candidatos / evidencia

- L7, `shader` (shader interno): `float rounded_box(vec2 p, vec2 half_size, float r) {`
- L8, `shader` (shader interno): `vec2 q = abs(p) - half_size + vec2(r);`
- L9, `shader` (shader interno): `return length(max(q,vec2(0.0))) + min(max(q.x,q.y),0.0) - r;`
- L12, `shader` (shader interno): `vec2 inner_size = max(bar_size-vec2(inset*2.0),vec2(1.0));`
- L13, `shader` (shader interno): `vec2 point = UV * bar_size-vec2(inset);`
- L14, `shader` (shader interno): `float r = min(max(0.0,radius-inset),min(inner_size.x,inner_size.y)*0.5);`
- L15, `shader` (shader interno): `float outer = rounded_box(point-inner_size*0.5,inner_size*0.5,r);`
- L17, `shader` (shader interno): `vec2 half_fill = vec2(width,inner_size.y)*0.5;`
- L18, `shader` (shader interno): `float filled = rounded_box(point-half_fill,half_fill,min(r,width*0.5));`
- L19, `shader` (shader interno): `float mask = 1.0-smoothstep(-0.6,0.6,max(outer,filled));`
- L20, `shader` (shader interno): `COLOR = vec4(fill_color.rgb,fill_color.a*mask*step(0.0001,ratio));`

## scenes/projectiles/baguette_harpoon.gd

98 líneas; 0 anotaciones export; 0 uniforms; 21 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var carried: Array[Enemy] = []`
- L7, `declaración` (regla/valor): `var hold_left := 0.0`
- L8, `declaración` (regla/valor): `var hold_duration := 0.0`
- L16, `_ready` (literal adicional (revisión)): `query.collision_mask = 8`
- L21, `setup_projectile` (literal adicional (revisión)): `super.setup_projectile(projectile_velocity, damage, critical, 0.0, unit, travel_range)`
- L26, `configure_effects` (literal adicional (revisión)): `sweep_shape.radius = maxf(1.0, settings.harpoon_capture_radius * Global.GAME_ENTITY_SCALE)`
- L32, `_process` (literal adicional (revisión)): `var t := clampf((hold_duration - hold_left) / maxf(0.001, settings.harpoon_embed_duration), 0.0, 1.0)`
- L33, `_process` (regla/valor): `$Sprite2D.rotation = settings.harpoon_embed_angle * sin(t * PI * 0.5)`
- L34, `_process` (regla/valor): `if hold_left <= 0.0: finish()`
- L37, `_process` (literal adicional (revisión)): `var remaining := maxf(0.0, max_distance - distance_travelled)`
- L44, `_process` (literal adicional (revisión)): `for i in 20:`
- L45, `_process` (literal adicional (revisión)): `var middle := (inside + outside) * 0.5`
- L50, `_process` (literal adicional (revisión)): `var steps := maxi(1, ceili(start.distance_to(end) / sweep_shape.radius))`
- L51, `_process` (literal adicional (revisión)): `for i in range(steps + 1):`
- L52, `_process` (literal adicional (revisión)): `query.transform = Transform2D(0.0, start.lerp(end, float(i) / steps))`
- L53, `_process` (literal adicional (revisión)): `for result in get_world_2d().direct_space_state.intersect_shape(query, 4096):`
- L59, `_process` (regla/valor): `if edge or distance_travelled >= max_distance - 0.001: _plant()`
- L64, `_on_hitbox_component_on_hit_hurtbox` (regla/valor): `if not is_instance_valid(enemy) or enemy.displacement_immune or enemy.is_retiring or enemy.health_component.current_health <= 0.0: return`
- L73, `_move_carried` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue`
- L81, `_plant` (literal adicional (revisión)): `z_index = 0`
- L86, `_plant` (regla/valor): `if hold_left <= 0.0: finish()`

## scenes/projectiles/bomb_corn.gd

53 líneas; 0 anotaciones export; 0 uniforms; 2 candidatos.

### Candidatos / evidencia

- L14, `_process` (literal adicional (revisión)): `var remaining := maxf(0.0, max_distance - distance_travelled)`
- L43, `detonate` (literal adicional (revisión)): `popcorn.setup_projectile(Vector2.from_angle(randf() * TAU) * effects.popcorn_speed, explosion_base_damage * effects.popcorn_damage_multiplier, hitbox.critical, 0.0, hitbox.source, effects.popcorn_range * Global.GAME_ENTITY_SCALE)`

## scenes/projectiles/catalogue_projectile.gd

56 líneas; 0 anotaciones export; 0 uniforms; 10 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var fuse_left := 0.0`
- L6, `declaración` (regla/valor): `var explosion_base_damage := 0.0`
- L15, `configure_effects` (regla/valor): `hitbox.launch_speed = effects.airbourne_speed * (hitbox.source.stats.get_crowd_control_multiplier() if hitbox.source is Unit else 1.0)`
- L16, `configure_effects` (regla/valor): `hitbox.launch_duration = effects.airbourne_duration * (hitbox.source.stats.get_crowd_control_multiplier() if hitbox.source is Unit else 1.0)`
- L19, `configure_effects` (literal adicional (revisión)): `hitbox.knockback_power = 0.0`
- L23, `configure_effects` (literal adicional (revisión)): `hitbox.base_damage = 0.0`
- L24, `configure_effects` (literal adicional (revisión)): `hitbox.damage = 0.0`
- L31, `_process` (literal adicional (revisión)): `var movement := (velocity * delta).limit_length(maxf(0.0, max_distance - distance_travelled))`
- L35, `_process` (regla/valor): `if fuse_left <= 0.0: detonate()`
- L49, `detonate` (texto): `var effect = load("res://scenes/projectiles/ranged_area_effect.gd").new()`

## scenes/projectiles/corpse_egg.gd

129 líneas; 0 anotaciones export; 0 uniforms; 34 candidatos.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var origin := Vector2.ZERO`
- L5, `declaración` (regla/valor): `var landing_point := Vector2.ZERO`
- L6, `declaración` (regla/valor): `var flight_time := 0.0`
- L7, `declaración` (regla/valor): `var flight_elapsed := 0.0`
- L9, `declaración` (regla/valor): `var fuse_left := 0.3`
- L12, `declaración` (regla/valor): `var fall_elapsed := 0.0`
- L13, `declaración` (regla/valor): `var fall_height := 0.0`
- L14, `declaración` (regla/valor): `var contact_target_id := 0`
- L22, `_ready` (literal adicional (revisión)): `z_index = 0`
- L26, `setup_projectile` (literal adicional (revisión)): `rotation = 0.0`
- L35, `configure_target` (literal adicional (revisión)): `flight_time = origin.distance_to(point) / maxf(1.0, velocity.length())`
- L39, `_process` (literal adicional (revisión)): `rotation = 0.0`
- L43, `_process` (literal adicional (revisión)): `var step := minf(remaining, maxf(0.0, flight_time - flight_elapsed))`
- L46, `_process` (literal adicional (revisión)): `var progress := clampf(flight_elapsed / maxf(0.0001, flight_time), 0.0, 1.0)`
- L63, `_process` (literal adicional (revisión)): `var fall_step := minf(remaining, maxf(0.0, settings.egg_fall_duration - fall_elapsed))`
- L66, `_process` (literal adicional (revisión)): `egg.position.y = lerpf(fall_height, 0.0, pow(clampf(fall_elapsed / settings.egg_fall_duration, 0.0, 1.0), 2.0))`
- L73, `_process` (regla/valor): `if shake_window > 0.0 and shake_elapsed > 0.0:`
- L75, `_process` (literal adicional (revisión)): `var intensity := lerpf(0.65, 1.0, clampf(shake_elapsed / shake_window, 0.0, 1.0))`
- L76, `_process` (visual): `egg.position = Vector2(sin(phase), sin(phase * 1.37) * 0.5) * settings.pre_explosion_shake_amount * intensity`
- L77, `_process` (regla/valor): `var pulse := 0.5 + 0.5 * sin(phase)`
- L78, `_process` (literal adicional (revisión)): `egg.modulate = Color(1.0, 1.0 - pulse * 0.18, 1.0 - pulse * 0.3)`
- L80, `_process` (visual): `egg.position = Vector2.ZERO`
- L82, `_process` (regla/valor): `if fuse_left <= 0.0: detonate()`
- L88, `_land` (visual): `egg.position = Vector2.ZERO`
- L89, `_land` (literal adicional (revisión)): `z_index = 0`
- L94, `_find_contact` (literal adicional (revisión)): `shape.radius = 10.0 * Global.GAME_ENTITY_SCALE`
- L97, `_find_contact` (literal adicional (revisión)): `query.collision_mask = 8`
- L100, `_find_contact` (literal adicional (revisión)): `var steps := maxi(1, ceili(start.distance_to(end) / maxf(1.0, shape.radius)))`
- L101, `_find_contact` (literal adicional (revisión)): `for index in range(steps + 1):`
- L103, `_find_contact` (literal adicional (revisión)): `query.transform = Transform2D(0.0, point)`
- L104, `_find_contact` (literal adicional (revisión)): `for result in get_world_2d().direct_space_state.intersect_shape(query, 16):`
- L108, `_find_contact` (regla/valor): `if not enemy is Enemy or not enemy.targetable or enemy.is_retiring or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0.0: continue`
- L116, `detonate` (texto): `var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()`
- L121, `detonate` (literal adicional (revisión)): `for i in settings.bonus_yolks: arena.spawn_yolk_at(landing_point, 1)`

## scenes/projectiles/electric_saw.gd

33 líneas; 7 anotaciones export; 0 uniforms; 13 candidatos.

### Ya expuesto en el editor

- L3: `@export var blade_radius := 10.0`
- L4: `@export var tooth_count := 12`
- L5: `@export var spin_speed := 22.0`
- L6: `@export var outline_width := 1.8`
- L7: `@export var metal_color := Color("d9dedb")`
- L8: `@export var shadow_color := Color("82969d")`
- L9: `@export var electric_color := Color("80dbed")`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var blade_angle := 0.0`
- L20, `_draw` (literal adicional (revisión)): `for i in maxi(3, tooth_count):`
- L21, `_draw` (literal adicional (revisión)): `var angle := blade_angle + TAU * i / maxi(3, tooth_count)`
- L22, `_draw` (literal adicional (revisión)): `for point in [Vector2(blade_radius * 0.78, 0).rotated(angle), Vector2(blade_radius, 0).rotated(angle + TAU / maxi(3, tooth_count) * 0.3), Vector2(blade_radius * 0.86, 0).rotated(angle + TAU / maxi(3, tooth_count) * 0.7)]:`
- L25, `_draw` (literal adicional (revisión)): `teeth.append(teeth[0])`
- L26, `_draw` (literal adicional (revisión)): `draw_polyline(teeth, Color("242522"), outline_width, true)`
- L27, `_draw` (literal adicional (revisión)): `draw_circle(Vector2.ZERO, blade_radius * 0.55, shadow_color)`
- L28, `_draw` (literal adicional (revisión)): `draw_arc(Vector2.ZERO, blade_radius * 0.55, 0, TAU, 32, Color("242522"), outline_width, true)`
- L29, `_draw` (literal adicional (revisión)): `draw_circle(Vector2.ZERO, blade_radius * 0.22, electric_color)`
- L30, `_draw` (literal adicional (revisión)): `for i in 3:`
- L31, `_draw` (literal adicional (revisión)): `var angle := blade_angle + i * TAU / 3.0`
- L32, `_draw` (literal adicional (revisión)): `var spark := PackedVector2Array([Vector2(blade_radius * 0.58, 0).rotated(angle), Vector2(blade_radius * 0.7, -3).rotated(angle), Vector2(blade_radius * 0.83, 1).rotated(angle)])`
- L33, `_draw` (literal adicional (revisión)): `draw_polyline(spark, electric_color, 1.8, true)`

## scenes/projectiles/ketchup_capsule.gd

56 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var impact_direction := Vector2.RIGHT`
- L4, `declaración` (regla/valor): `var impact_directions: Dictionary = {}`
- L5, `declaración` (regla/valor): `var splattered_targets: Dictionary = {}`
- L6, `declaración` (regla/valor): `var initial_shot_range := 0.0`
- L34, `_on_damage_dealt` (literal adicional (revisión)): `var origin := hurtbox.get_target_position() + direction * 5.0 * Global.GAME_ENTITY_SCALE`
- L40, `_spawn_splatter` (regla/valor): `var offset := deg_to_rad(effects.splatter_spread_degrees) * (float(index) / maxf(1.0, effects.splatter_count - 1) - 0.5) if effects.splatter_count > 1 else 0.0`
- L46, `_spawn_splatter` (texto): `droplet = load("res://scenes/projectiles/projectile_ketchup_drop.tscn").instantiate()`
- L49, `_spawn_splatter` (literal adicional (revisión)): `droplet.setup_projectile(direction.rotated(offset) * effects.splatter_speed, droplet_damage, was_critical, 0.0, hitbox.source, initial_shot_range * effects.splatter_range_multiplier)`

## scenes/projectiles/ketchup_drop.gd

44 líneas; 0 anotaciones export; 0 uniforms; 7 candidatos.

### Candidatos / evidencia

- L7, `activate` (literal adicional (revisión)): `distance_travelled = 0.0`
- L9, `activate` (literal adicional (revisión)): `remaining_piercing = 0`
- L10, `activate` (literal adicional (revisión)): `remaining_bounces = 0`
- L15, `activate` (literal adicional (revisión)): `hitbox.life_steal_chance = 0.0`
- L41, `_draw` (literal adicional (revisión)): `var points := PackedVector2Array([Vector2(-10,0),Vector2(-2,-4),Vector2(4,-4),Vector2(7,-2),Vector2(8,0),Vector2(7,2),Vector2(4,4),Vector2(-2,4),Vector2(-10,0)])`
- L43, `_draw` (literal adicional (revisión)): `draw_polyline(points,Color("58201a"),1.5,true)`
- L44, `_draw` (literal adicional (revisión)): `draw_line(Vector2(0,-2),Vector2(4,-2),Color("ff8b57"),1.5,true)`

## scenes/projectiles/plate_projectile.gd

42 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L10, `setup_projectile` (literal adicional (revisión)): `rotation = 0.0`
- L26, `_on_hitbox_component_on_hit_hurtbox` (literal adicional (revisión)): `rotation = 0.0`
- L38, `_emit_break` (texto): `var fragments = load("res://effects/plate_fragments.gd").new()`

## scenes/projectiles/pressure_pot.gd

51 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

### Candidatos / evidencia

- L3, `declaración` (visual): `var rest_scale := Vector2.ONE`
- L7, `configure_effects` (visual): `egg.scale = Vector2.ONE * settings.pot_sprite_scale`
- L25, `_land` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue`
- L27, `_land` (literal adicional (revisión)): `offset.y /= maxf(0.01, settings.area_y_ratio)`
- L30, `_land` (texto): `var steam = load("res://effects/pan_slow_burst.gd").new()`
- L41, `_process` (literal adicional (revisión)): `var progress := clampf(1.0 - fuse_left / maxf(0.001, settings.fuse), 0.0, 1.0)`
- L42, `_process` (visual): `egg.scale = rest_scale * (1.0 + settings.pot_inflate_amount * progress * progress)`
- L47, `detonate` (texto): `var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()`

## scenes/projectiles/projectile.gd

77 líneas; 1 anotaciones export; 0 uniforms; 11 candidatos.

### Ya expuesto en el editor

- L4: `@export var hitbox: HitboxComponent`

### Candidatos / evidencia

- L8, `declaración` (regla/valor): `var distance_travelled := 0.0`
- L9, `declaración` (regla/valor): `var remaining_piercing := 0`
- L11, `declaración` (regla/valor): `var remaining_bounces := 0`
- L12, `declaración` (regla/valor): `var hit_targets: Dictionary = {}`
- L25, `_process` (literal adicional (revisión)): `var remaining := maxf(0.0, max_distance - distance_travelled)`
- L48, `setup_projectile` (literal adicional (revisión)): `max_distance = maxf(0.0, travel_range)`
- L49, `setup_projectile` (literal adicional (revisión)): `distance_travelled = 0.0`
- L65, `_on_hitbox_component_on_hit_hurtbox` (regla/valor): `if remaining_bounces > 0:`
- L70, `_on_hitbox_component_on_hit_hurtbox` (literal adicional (revisión)): `remaining_bounces -= 1`
- L74, `_on_hitbox_component_on_hit_hurtbox` (regla/valor): `if remaining_piercing > 0:`
- L75, `_on_hitbox_component_on_hit_hurtbox` (literal adicional (revisión)): `remaining_piercing -= 1`

## scenes/projectiles/projectile_pool.gd

54 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

### Candidatos / evidencia

- L3, `declaración` (constante): `const DROP_SCENE := preload("res://scenes/projectiles/projectile_ketchup_drop.tscn")`
- L4, `declaración` (constante): `const CAPACITY := 256`
- L5, `declaración` (constante): `const PREWARM := 64`
- L6, `declaración` (regla/valor): `var available: Array[Projectile] = []`
- L7, `declaración` (regla/valor): `var leased: Dictionary = {}`
- L8, `declaración` (regla/valor): `var created := 0`
- L11, `_ready` (literal adicional (revisión)): `name = "ProjectilePool"`
- L23, `_create` (regla/valor): `created += 1`
- L54, `_on_projectile_exiting` (literal adicional (revisión)): `created -= 1`

## scenes/projectiles/ranged_area_effect.gd

81 líneas; 0 anotaciones export; 0 uniforms; 18 candidatos.

Hallazgos: FX-10.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L7, `declaración` (regla/valor): `var lifetime := 0.2`
- L8, `declaración` (regla/valor): `var radius := 70.0`
- L9, `declaración` (regla/valor): `var next_hit := 0.0`
- L24, `setup` (literal adicional (revisión)): `hit.collision_layer = 0`
- L25, `setup` (literal adicional (revisión)): `hit.collision_mask = 0`
- L27, `setup` (regla/valor): `hit.setup(template.base_damage * (settings.pit_damage_multiplier if pit else settings.explosion_damage_multiplier), false, 0.0, template.source)`
- L41, `setup` (literal adicional (revisión)): `z_index = 2`
- L53, `_process` (regla/valor): `if next_hit <= 0.0:`
- L61, `_damage_enemies` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue`
- L69, `_draw` (literal adicional (revisión)): `var progress := clampf(elapsed / lifetime, 0.0, 1.0)`
- L71, `_draw` (literal adicional (revisión)): `draw_texture_rect(texture, Rect2(-Vector2(20, 14), Vector2(40, 28)), false, Color(1, 1, 1, minf(1.0, (1.0 - progress) * 5.0)))`
- L74, `_draw` (literal adicional (revisión)): `color.a = (1.0 - progress) * 0.65`
- L75, `_draw` (literal adicional (revisión)): `draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, settings.area_y_ratio))`
- L76, `_draw` (literal adicional (revisión)): `draw_circle(Vector2.ZERO, radius * (0.6 + progress * 0.4), color)`
- L77, `_draw` (literal adicional (revisión)): `draw_arc(Vector2.ZERO, radius * (0.6 + progress * 0.4), 0.0, TAU, 40, Color(color, color.a * 0.8), 3.0, true)`
- L80, `_draw` (visual): `var size := Vector2.ONE * radius * (0.8 + progress * 0.5)`
- L81, `_draw` (literal adicional (revisión)): `draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1, 1, 1, 1.0 - progress))`

## scenes/projectiles/smasher_projectile.gd

20 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L12, `_process` (visual): `var bounds := Rect2(arena_environment.background_offset - arena_environment.background_size * 0.5, arena_environment.background_size)`

## scenes/ui/credits_panel/credits_panel.gd

7 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.


## scenes/ui/damage_vignette.gdshader

8 líneas; 0 anotaciones export; 2 uniforms; 3 candidatos.

### Uniforms editables

- L2: `uniform float strength : hint_range(0.0, 1.0) = 0.0;`
- L3: `uniform vec4 tint : source_color = vec4(0.32, 0.055, 0.035, 1.0);`

### Candidatos / evidencia

- L5, `shader` (shader interno): `vec2 p = abs(UV * 2.0 - 1.0);`
- L6, `shader` (shader interno): `float edge = smoothstep(0.28, 1.20, length(p));`
- L7, `shader` (shader interno): `COLOR = vec4(tint.rgb, edge * strength);`

## scenes/ui/final_screen.gd

8 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.


## scenes/ui/floating_text/floating_text.gd

56 líneas; 0 anotaciones export; 0 uniforms; 23 candidatos.

Hallazgos: FX-05.

### Candidatos / evidencia

- L8, `declaración` (regla/valor): `var elapsed := 0.0`
- L9, `declaración` (regla/valor): `var lifetime := 1.3`
- L10, `declaración` (visual): `var animation_scale := 1.0`
- L11, `declaración` (visual): `var start_position := Vector2.ZERO`
- L16, `setup_text` (literal adicional (revisión)): `func setup_text(value: String, color: Color, duration: float = 1.3) -> void:`
- L17, `setup_text` (texto): `label.text = value`
- L21, `setup_text` (regla/valor): `rotation = deg_to_rad(randf_range(-10, 10))`
- L22, `setup_text` (visual): `var random_scale := randf_range(.8, 1.6)`
- L24, `setup_text` (literal adicional (revisión)): `elapsed = 0.0`
- L25, `setup_text` (literal adicional (revisión)): `lifetime = maxf(0.01,duration)`
- L32, `setup_text` (literal adicional (revisión)): `var timing := maxf(0.01, duration) / 1.3`
- L34, `setup_text` (texto): `tween.parallel().tween_property(self, "scale", Vector2.ONE * random_scale, .4 * timing)`
- L35, `setup_text` (texto): `tween.parallel().tween_property(self, "global_position", global_position + Vector2.UP * 15, .4 * timing)`
- L37, `setup_text` (literal adicional (revisión)): `tween.tween_interval(.5 * timing)`
- L39, `setup_text` (texto): `tween.parallel().tween_property(self, "scale", Vector2.ZERO, .4 * timing)`
- L40, `setup_text` (texto): `tween.parallel().tween_property(self, "modulate:a", .0, .4 * timing)`
- L48, `_process` (literal adicional (revisión)): `var time := elapsed/lifetime*1.3`
- L49, `_process` (regla/valor): `if time>=1.3:`
- L52, `_process` (literal adicional (revisión)): `var growth := clampf(time/0.4,0.0,1.0)`
- L53, `_process` (literal adicional (revisión)): `var fade := clampf((time-0.9)/0.4,0.0,1.0)`
- L54, `_process` (literal adicional (revisión)): `scale = Vector2.ONE*animation_scale*growth*(1.0-fade)`
- L55, `_process` (literal adicional (revisión)): `global_position = start_position+Vector2.UP*15.0*growth`
- L56, `_process` (literal adicional (revisión)): `modulate.a = 1.0-fade`

## scenes/ui/incognito_rewards.gd

82 líneas; 0 anotaciones export; 0 uniforms; 11 candidatos.

Hallazgos: UI-06.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var pending: Array[Dictionary] = []`
- L5, `declaración` (regla/valor): `var current: Dictionary = {}`
- L6, `declaración` (texto): `var loot = load("res://resources/rewards/incognito_loot.tres")`
- L40, `open_next` (literal adicional (revisión)): `current=pending[0]`
- L42, `open_next` (texto): `heading.text="INCOGNITO REWARD — %d LEFT" % pending.size()`
- L43, `open_next` (texto): `item_name.text=item.item_name`
- L44, `open_next` (texto): `rarity.text=["COMMON","RARE","EPIC","LEGENDARY"][item.item_tier]`
- L47, `open_next` (texto): `description.text=UITheme.rich_text(item.get_description())`
- L48, `open_next` (texto): `card.add_theme_stylebox_override("panel",Global.get_tier_style(item.item_tier))`
- L51, `open_next` (texto): `keep_button.text="KEEP" if allowed else "LIMIT REACHED"`
- L52, `open_next` (texto): `sell_button.text="SELL — %d YOLKS" % current.sell_value`

## scenes/ui/level_panel/level_panel.gd

92 líneas; 1 anotaciones export; 0 uniforms; 17 candidatos.

### Ya expuesto en el editor

- L10: `@export var buttons: Array[Button] = []`

### Candidatos / evidencia

- L4, `declaración` (constante): `const DIFFICULTY_RULES = preload("res://resources/difficulty_rules.gd")`
- L23, `_ready` (literal adicional (revisión)): `_show_difficulty(0)`
- L28, `_show_difficulty` (literal adicional (revisión)): `description = "LOCKED — Win a run on difficulty %d to unlock." % (level - 1)`
- L29, `_show_difficulty` (texto): `%DifficultyDescription.text = description`
- L40, `enable_buttons` (texto): `var edge = UITheme.palette.outline if state == "normal" else UITheme.palette.focus`
- L41, `enable_buttons` (texto): `var width: int = UITheme.palette.border_width if state == "normal" else UITheme.palette.focus_width`
- L42, `enable_buttons` (visual): `button.add_theme_stylebox_override(state, UITheme.box(UITheme.palette.locked_surface, edge, -1, width))`
- L45, `enable_buttons` (texto): `button.get_node("Label").add_theme_color_override("font_color", UITheme.palette.hud_text if locked else UITheme.palette.text)`
- L46, `enable_buttons` (literal adicional (revisión)): `button.tooltip_text = "Win a run on difficulty %d to unlock." % (i - 1) if locked else DIFFICULTY_RULES.description(i)`
- L59, `_on_level_0_button_pressed` (literal adicional (revisión)): `_select_difficulty(0)`
- L63, `_on_level_1_button_pressed` (literal adicional (revisión)): `_select_difficulty(1)`
- L67, `_on_level_2_button_pressed` (literal adicional (revisión)): `_select_difficulty(2)`
- L71, `_on_level_3_button_pressed` (literal adicional (revisión)): `_select_difficulty(3)`
- L75, `_on_level_4_button_pressed` (literal adicional (revisión)): `_select_difficulty(4)`
- L79, `_on_level_5_button_pressed` (literal adicional (revisión)): `_select_difficulty(5)`
- L86, `_on_stress_test_button_pressed` (literal adicional (revisión)): `on_stress_test_selected.emit(1000)`
- L89, `_on_stress_500_button_pressed` (literal adicional (revisión)): `on_stress_test_selected.emit(500)`

## scenes/ui/options_panel/options_panel.gd

49 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L43, `show_message` (texto): `message.text = text`
- L45, `show_message` (literal adicional (revisión)): `message.modulate.a = 1`
- L47, `show_message` (texto): `tween.tween_property(message, "modulate:a", 0, 3)`

## scenes/ui/pause_panel/pause_panel.gd

44 líneas; 0 anotaciones export; 0 uniforms; 6 candidatos.

### Candidatos / evidencia

- L11, `bind_player` (literal adicional (revisión)): `func bind_player(player: Player = null, slot: int = -1) -> void:`
- L14, `bind_player` (literal adicional (revisión)): `stats.independent_navigation=slot>=0`
- L15, `bind_player` (texto): `$VBoxContainer/Label.text="PAUSA · P%d" % (slot+1) if slot>=0 else "Game Paused"`
- L29, `_refresh_weapons` (texto): `var tile=preload("res://scenes/ui/pause_panel/pause_weapon_slot.tscn").instantiate()`
- L33, `_refresh_weapons` (texto): `tile.add_theme_stylebox_override("panel",style)`
- L38, `_refresh_weapons` (texto): `load("res://scenes/ui/rarity_marker.gd").apply(content,weapon.data.item_tier,true)`

## scenes/ui/player_damage_feedback.gd

83 líneas; 3 anotaciones export; 0 uniforms; 36 candidatos.

Hallazgos: FX-04.

### Ya expuesto en el editor

- L4: `@export var impact_duration := 1.1`
- L5: `@export var center_duration := 0.85`
- L6: `@export var darkness := 0.72`

### Candidatos / evidencia

- L11, `declaración` (regla/valor): `var health_ratio := 1.0`
- L12, `declaración` (regla/valor): `var target_strength := 0.0`
- L13, `declaración` (regla/valor): `var strength := 0.0`
- L16, `declaración` (regla/valor): `var elapsed := 0.0`
- L17, `declaración` (regla/valor): `var death_origin := Vector2.ZERO`
- L18, `declaración` (visual): `var start_size := 90.0`
- L27, `update_health` (literal adicional (revisión)): `health_ratio = clampf(current / maxf(1.0, maximum), 0.0, 1.0)`
- L31, `strength_for_health` (regla/valor): `if ratio >= 0.5: return 0.0`
- L32, `strength_for_health` (regla/valor): `if ratio >= 0.35: return 0.16`
- L33, `strength_for_health` (regla/valor): `if ratio >= 0.20: return 0.28`
- L34, `strength_for_health` (regla/valor): `if ratio >= 0.10: return 0.42`
- L35, `strength_for_health` (regla/valor): `return 0.58`
- L40, `begin_defeat` (literal adicional (revisión)): `elapsed = 0.0`
- L42, `begin_defeat` (literal adicional (revisión)): `start_size = maxf(60, display_size)`
- L43, `begin_defeat` (visual): `corpse.position = death_origin`
- L45, `begin_defeat` (visual): `corpse.scale = Vector2.ONE * start_size / maxf(1.0, corpse.texture.get_width())`
- L47, `begin_defeat` (visual): `particles.position = death_origin`
- L52, `_process` (literal adicional (revisión)): `var real_delta := delta / maxf(0.01, Engine.time_scale)`
- L55, `_process` (literal adicional (revisión)): `strength = move_toward(strength, 0.0, real_delta * 2.0)`
- L56, `_process` (literal adicional (revisión)): `dim.color.a = darkness * minf(1, elapsed / 0.35)`
- L57, `_process` (literal adicional (revisión)): `var travel := clampf((elapsed - impact_duration) / maxf(0.01,center_duration), 0, 1)`
- L58, `_process` (literal adicional (revisión)): `var eased := smoothstep(0, 1, travel)`
- L59, `_process` (visual): `corpse.position = death_origin.lerp(get_viewport().get_visible_rect().size * 0.5, eased)`
- L60, `_process` (regla/valor): `var pop := 1.0 + 0.18 * sin(minf(1,elapsed / 0.22) * PI)`
- L61, `_process` (literal adicional (revisión)): `var pixels := lerpf(start_size, 180.0, eased) * pop`
- L62, `_process` (visual): `corpse.scale = Vector2.ONE * pixels / corpse.texture.get_width()`
- L63, `_process` (regla/valor): `if travel >= 1:`
- L69, `_process` (regla/valor): `var desired := target_strength if active else 0.0`
- L70, `_process` (literal adicional (revisión)): `strength = move_toward(strength, desired, real_delta * 0.8)`
- L71, `_process` (texto): `vignette.material.set_shader_parameter("strength", strength)`
- L76, `reset` (literal adicional (revisión)): `elapsed = 0.0`
- L77, `reset` (literal adicional (revisión)): `health_ratio = 1.0`
- L78, `reset` (literal adicional (revisión)): `strength = 0.0`
- L79, `reset` (literal adicional (revisión)): `target_strength = 0.0`
- L80, `reset` (literal adicional (revisión)): `dim.color.a = 0.0`
- L83, `reset` (texto): `vignette.material.set_shader_parameter("strength",0.0)`

## scenes/ui/rarity_marker.gd

14 líneas; 0 anotaciones export; 0 uniforms; 4 candidatos.

Hallazgos: UI-04.

### Candidatos / evidencia

- L6, `apply` (texto): `band=load("res://scenes/ui/rarity_compact.tscn" if compact else "res://scenes/ui/rarity_band.tscn").instantiate()`
- L11, `apply` (texto): `band.add_theme_stylebox_override("panel", style)`
- L13, `apply` (texto): `label.text = ["I", "II", "III", "IV"][clampi(tier, 0, 3)] if compact else ["COMMON", "RARE", "EPIC", "LEGENDARY"][clampi(tier, 0, 3)]`
- L14, `apply` (texto): `label.add_theme_color_override("font_color", UITheme.palette.rarity(tier) if compact else UITheme.palette.hud_text)`

## scenes/ui/selection_panel/selection_card.gd

57 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

### Candidatos / evidencia

- L14, `_ready` (constante): `const SILHOUETTE = preload("res://shaders/locked_silhouette.gdshader")`
- L17, `_ready` (visual): `var coop_highlights: Array[Color] = []`
- L22, `set_coop_highlights` (literal adicional (revisión)): `UITheme.style_slot(self,int(get_meta("ui_tier",0)))`
- L26, `set_coop_highlights` (literal adicional (revisión)): `style.border_color=colors[0]`
- L27, `set_coop_highlights` (literal adicional (revisión)): `style.set_border_width_all(maxi(3,UITheme.palette.focus_width))`
- L28, `set_coop_highlights` (texto): `add_theme_stylebox_override("normal",style)`
- L30, `set_icon` (literal adicional (revisión)): `func set_icon(texture: Texture2D, icon_scale: float = 1.0) -> void:`
- L45, `set_locked` (texto): `silhouette.set_shader_parameter("silhouette_color", UITheme.palette.muted)`

## scenes/ui/selection_panel/selection_layout.gd

43 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

### Candidatos / evidencia

- L18, `refresh` (visual): `menu.player_panel.offset_left=authored_panel_offsets.x`
- L19, `refresh` (visual): `menu.player_panel.offset_top=authored_panel_offsets.y`
- L20, `refresh` (visual): `menu.player_panel.offset_right=authored_panel_offsets.z`
- L21, `refresh` (visual): `menu.player_panel.offset_bottom=authored_panel_offsets.w`
- L28, `player_slot_rects` (regla/valor): `if _count<=1: return [rect]`
- L31, `player_slot_rects` (literal adicional (revisión)): `var height=(rect.size.y-gap*(_count-1))/_count`
- L32, `player_slot_rects` (regla/valor): `var result: Array[Rect2]=[]`
- L33, `player_slot_rects` (literal adicional (revisión)): `for i in _count: result.append(Rect2(rect.position+Vector2(0,i*(height+gap)),Vector2(rect.size.x,height)))`
- L38, `content_rect` (visual): `return Rect2(Vector2(back.position.x,menu.player_panel.position.y),Vector2(body.size.x-2*back.position.x,menu.player_panel.size.y))`

## scenes/ui/selection_panel/selection_panel.gd

322 líneas; 4 anotaciones export; 0 uniforms; 38 candidatos.

Hallazgos: UI-05.

### Ya expuesto en el editor

- L11: `@export var selection_mode: SelectionMode = SelectionMode.CHARACTER`
- L13: `@export var base_player_stats: UnitStats`
- L15: `@export var player_list: Array[UnitStats]`
- L16: `@export var weapons_list: Array[ItemWeapon]`

### Candidatos / evidencia

- L7, `declaración` (constante): `const SELECTION_CARD = preload("res://scenes/ui/selection_panel/selection_card.tscn")`
- L20, `declaración` (texto): `var roster_layout = preload("res://scenes/ui/selection_panel/selection_layout.gd").new()`
- L37, `declaración` (constante): `const DISPLAY_STATS := [`
- L51, `declaración` (constante): `const SILHOUETTE = preload("res://shaders/locked_silhouette.gdshader")`
- L58, `_ready` (texto): `for item in load("res://resources/items/weapons/melee_catalogue.gd").items():`
- L62, `_ready` (texto): `for item in load("res://resources/items/weapons/spicy_catalogue.gd").items():`
- L64, `_ready` (texto): `for item in load("res://resources/items/weapons/pet_catalogue.gd").items():`
- L74, `_ready` (texto): `heading.text = "Select Player" if selection_mode == SelectionMode.CHARACTER else "Select Weapon"`
- L86, `_refresh_selection_info` (literal adicional (revisión)): `players_container.modulate.a = 1.0`
- L87, `_refresh_selection_info` (literal adicional (revisión)): `roster_layout.right_players.modulate.a = 1.0`
- L157, `_show_player_preview` (texto): `player_name.text = player.name`
- L159, `_show_player_preview` (texto): `player_title.text = "Player" if unlocked else "Locked"`
- L161, `_show_player_preview` (texto): `player_description.text = get_character_description(player) if unlocked else Progression.requirement_for(player.unlock_id, true)`
- L193, `_show_weapon_preview` (texto): `weapon_name.text = weapon.item_name`
- L194, `_show_weapon_preview` (texto): `weapon_title.text = weapon.get_category_label()`
- L198, `_show_weapon_preview` (texto): `weapon_title.text = weapon.get_category_label()`
- L199, `_show_weapon_preview` (texto): `weapon_description.text = Progression.requirement_for(weapon.unlock_id, false)`
- L201, `_show_weapon_preview` (texto): `weapon_description.text = UITheme.rich_text(weapon.get_description(Global.main_player_selected.get_passive_preview() if Global.main_player_selected else null))`
- L203, `_show_weapon_preview` (texto): `weapon_title.text = weapon.get_category_label()`
- L223, `_update_weapon_availability` (regla/valor): `card.modulate.a = 0.4 if not allowed else 1.0`
- L229, `_set_portrait_lock` (texto): `silhouette.set_shader_parameter("silhouette_color", UITheme.palette.muted)`
- L258, `get_character_description` (regla/valor): `var lines: PackedStringArray = []`
- L261, `get_character_description` (literal adicional (revisión)): `var difference := float(player.get(stat[0])) - float(base_player_stats.get(stat[0]))`
- L263, `get_character_description` (regla/valor): `var sign_text := "+" if difference > 0.0 else ""`
- L264, `get_character_description` (texto): `var color := UITheme.color_hex("positive" if difference > 0.0 else "negative")`
- L265, `get_character_description` (regla/valor): `var suffix := "%" if stat[2] else ""`
- L266, `get_character_description` (literal adicional (revisión)): `lines.append("%s: [color=%s]%s%s%s[/color]" % [stat[1], color, sign_text, ItemWeapon.format_number(difference), suffix])`
- L271, `get_character_description` (regla/valor): `var passive_lines: PackedStringArray = []`
- L279, `get_player_cards` (regla/valor): `var cards: Array[Node] = []`
- L290, `animate_character_to_weapons` (texto): `tween.tween_property(players_container, "modulate:a", 0.0, 0.18)`
- L291, `animate_character_to_weapons` (texto): `tween.tween_property(roster_layout.right_players, "modulate:a", 0.0, 0.18)`
- L292, `animate_character_to_weapons` (literal adicional (revisión)): `var target: Rect2 = roster_layout.player_slot_rects(1, true)[0]`
- L293, `animate_character_to_weapons` (texto): `tween.tween_property(player_panel, "position", target.position, 0.38).set_delay(0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)`
- L294, `animate_character_to_weapons` (texto): `tween.tween_property(player_panel, "size", target.size, 0.38).set_delay(0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)`
- L298, `reveal_weapon_roster` (literal adicional (revisión)): `weapons_container.modulate.a = 0.0`
- L299, `reveal_weapon_roster` (literal adicional (revisión)): `weapon_panel.modulate.a = 0.0`
- L301, `reveal_weapon_roster` (texto): `tween.tween_property(weapons_container, "modulate:a", 1.0, 0.2)`
- L302, `reveal_weapon_roster` (texto): `tween.tween_property(weapon_panel, "modulate:a", 1.0, 0.2)`

## scenes/ui/shop/chocolate_coin_reveal.gd

154 líneas; 1 anotaciones export; 0 uniforms; 60 candidatos.

Hallazgos: FX-01.

### Ya expuesto en el editor

- L7: `@export var frames: Array[Texture2D] = []`

### Candidatos / evidencia

- L4, `declaración` (constante): `const SHEET := "res://assets/sprites/UI/chocolate_coin/coin-turn.png"`
- L5, `declaración` (constante): `const REGIONS := [Rect2(52,81,526,533), Rect2(699,77,310,536), Rect2(1265,77,123,537), Rect2(1592,80,525,534)]`
- L6, `declaración` (constante): `const TURN := [0, 1, 2, 4, 3, 4, 2, 1]`
- L16, `declaración` (regla/valor): `var elapsed := 0.0`
- L18, `declaración` (regla/valor): `var balance := 0`
- L19, `declaración` (regla/valor): `var displayed_balance := 0`
- L22, `declaración` (regla/valor): `var particles: Array[Dictionary] = []`
- L23, `declaración` (regla/valor): `var pending_results: Array[Dictionary] = []`
- L34, `_ready` (texto): `card.add_theme_stylebox_override("panel",card_style)`
- L40, `play` (literal adicional (revisión)): `func play(success: bool, final_balance: int, starting_balance: int = -1) -> void:`
- L46, `play` (regla/valor): `displayed_balance = Global.coins if starting_balance < 0 else starting_balance`
- L47, `play` (literal adicional (revisión)): `elapsed = 0.0`
- L53, `play` (literal adicional (revisión)): `veil.color = Color(0.035, 0.025, 0.02, 0.76)`
- L56, `play` (literal adicional (revisión)): `_set_frame(0)`
- L57, `play` (visual): `coin.scale = Vector2.ZERO`
- L64, `_layout` (visual): `coin.offset_left=authored_coin_offsets.x`
- L65, `_layout` (visual): `coin.offset_top=authored_coin_offsets.y`
- L66, `_layout` (visual): `coin.offset_right=authored_coin_offsets.z`
- L67, `_layout` (visual): `coin.offset_bottom=authored_coin_offsets.w`
- L70, `_set_frame` (regla/valor): `coin.texture = frames[1 if index == 4 else index]`
- L71, `_set_frame` (literal adicional (revisión)): `coin.flip_h = index == 4`
- L76, `_process` (regla/valor): `if elapsed>=0.7 and not spin_announced:`
- L80, `_process` (literal adicional (revisión)): `veil.modulate.a = minf(1, elapsed / 0.16)`
- L81, `_process` (literal adicional (revisión)): `card.modulate.a = minf(1, elapsed / 0.16)`
- L82, `_process` (regla/valor): `if elapsed < 0.25:`
- L83, `_process` (visual): `coin.scale = Vector2.ZERO`
- L84, `_process` (regla/valor): `elif elapsed < 0.48:`
- L85, `_process` (visual): `coin.scale = Vector2.ONE * ease(clampf((elapsed - 0.25) / 0.23, 0, 1), 0.4)`
- L86, `_process` (regla/valor): `elif elapsed < 0.7:`
- L87, `_process` (visual): `coin.scale = Vector2.ONE`
- L88, `_process` (regla/valor): `elif elapsed < 1.7:`
- L89, `_process` (literal adicional (revisión)): `var spin_time := elapsed - 0.7`
- L91, `_process` (literal adicional (revisión)): `_set_frame(TURN[int(16.0 * spin_time + 28.0 * spin_time * spin_time) % TURN.size()])`
- L92, `_process` (visual): `coin.scale = Vector2.ONE`
- L93, `_process` (regla/valor): `elif elapsed < 1.84:`
- L94, `_process` (visual): `coin.scale = Vector2.ONE * pow(1.0 - (elapsed - 1.7) / 0.14, 2)`
- L96, `_process` (regla/valor): `_set_frame(0 if won else 3)`
- L97, `_process` (literal adicional (revisión)): `var reveal := clampf((elapsed - 1.84) / 0.18, 0, 1)`
- L98, `_process` (visual): `coin.scale = Vector2.ONE * 1.3 * (1.0 - pow(1.0 - reveal, 3))`
- L99, `_process` (visual): `card_style.bg_color = Color("342b25").lerp(Color("504025") if won else Color("512a2b"), reveal)`
- L100, `_process` (texto): `card_style.border_color = Color("b88a46").lerp(Color("d6a63c") if won else Color("a7564c"), reveal)`
- L101, `_process` (visual): `veil.color = Color(0.035, 0.025, 0.02, 0.76).lerp(Color(0.09, 0.06, 0.015, 0.76) if won else Color(0.12, 0.025, 0.025, 0.79), reveal)`
- L102, `_process` (regla/valor): `if reveal >= 1.0 and not revealed:`
- L107, `_process` (texto): `result_label.text = "X2" if won else "X0"`
- L108, `_process` (texto): `result_label.add_theme_color_override("font_color", Color("ffd344") if won else Color("ee6960"))`
- L112, `_process` (visual): `coin.scale *= 1.0 + 0.025 * sin(elapsed * 4.3)`
- L113, `_process` (regla/valor): `if elapsed >= 2.8 and not continue_button.visible:`
- L119, `_process` (regla/valor): `particle.velocity.y += 290.0 * delta`
- L125, `_celebrate` (texto): `var colors := [Color("fff2cb"), Color("ffc536"), Color("ed9131"), Color("e9c388")]`
- L126, `_celebrate` (literal adicional (revisión)): `for index in 220:`
- L127, `_celebrate` (regla/valor): `var left := index % 2 == 0`
- L128, `_celebrate` (visual): `var point := card.position + Vector2(8 if left else card.size.x - 8, card.size.y * randf_range(0.25, 0.75))`
- L129, `_celebrate` (regla/valor): `var velocity := Vector2(randf_range(180, 520) * (1 if left else -1), randf_range(-330, -80))`
- L130, `_celebrate` (texto): `particles.append({"point":point, "velocity":velocity, "age":0.0, "life":randf_range(0.9, 1.6), "angle":randf()*TAU, "spin":randf_range(-10,10), "size":Vector2(randf_range(4,9),randf_range(2,6)), "color":colors[index % colors.size()], "spark":false})`
- L131, `_celebrate` (literal adicional (revisión)): `for index in 75:`
- L132, `_celebrate` (texto): `particles.append({"point":card.position + coin.position + coin.size*0.5, "velocity":Vector2.from_angle(randf()*TAU)*randf_range(70,260), "age":0.0, "life":randf_range(0.5,1.0), "angle":randf()*TAU, "spin":randf_range(-5,5), "size":Vector2.ONE*randf_range(2,6), "color":colors[index % colors.size()], "spark":true})`
- L137, `_draw_particles` (literal adicional (revisión)): `color.a *= clampf((particle.life - particle.age) / 0.35, 0, 1)`
- L140, `_draw_particles` (literal adicional (revisión)): `particle_layer.draw_colored_polygon(PackedVector2Array([Vector2(0,-1.5),Vector2(0.4,-0.4),Vector2(1.5,0),Vector2(0.4,0.4),Vector2(0,1.5),Vector2(-0.4,0.4),Vector2(-1.5,0),Vector2(-0.4,-0.4)]), color)`
- L141, `_draw_particles` (literal adicional (revisión)): `else: particle_layer.draw_rect(Rect2(-1,-1,2,2),color)`
- L145, `close` (regla/valor): `if elapsed < 2.8: return`

## scenes/ui/shop/golden_yolk_control.gd

48 líneas; 2 anotaciones export; 0 uniforms; 10 candidatos.

### Ya expuesto en el editor

- L5: `@export var kind := "golden_yolk"`
- L6: `@export var display_name := "Yema de oro"`

### Candidatos / evidencia

- L23, `_ready` (regla/valor): `elif _charges() > 0:`
- L24, `_ready` (literal adicional (revisión)): `confirmation.popup_centered(Vector2i(590, 210))`
- L29, `_charges` (regla/valor): `if not is_instance_valid(Global.player): return 0`
- L30, `_charges` (literal adicional (revisión)): `return Global.player.passive_items.breading_charges if kind == "breading" else Global.player.passive_items.golden_yolks`
- L33, `refresh` (literal adicional (revisión)): `visible = _charges() > 0 or selecting`
- L34, `refresh` (literal adicional (revisión)): `text = ""`
- L35, `refresh` (texto): `$Count.text = str(_charges())`
- L36, `refresh` (literal adicional (revisión)): `disabled = _charges() <= 0 and not selecting`
- L37, `refresh` (texto): `hint_label.text = ""`
- L38, `refresh` (literal adicional (revisión)): `tooltip_text = ("Elegí un arma; pulsá de nuevo para cancelar." if kind == "breading" else "Elegí un ítem; pulsá de nuevo para cancelar.") if selecting else display_name`

## scenes/ui/shop/golden_yolk_reveal.gd

145 líneas; 0 anotaciones export; 0 uniforms; 53 candidatos.

Hallazgos: FX-02.

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var improvement := 0.0`
- L8, `declaración` (regla/valor): `var upgrade_queue: Array[Dictionary] = []`
- L28, `play_upgrade` (literal adicional (revisión)): `elapsed = 0.0`
- L36, `play_upgrade` (texto): `coin.material = load("res://effects/golden_visual.gd").material_for(original) if original.golden_multiplier > 1.0 else null`
- L44, `play_upgrade` (literal adicional (revisión)): `veil.color = Color(0.035,0.025,0.02,0.76)`
- L46, `play_upgrade` (visual): `coin.scale = Vector2.ZERO`
- L47, `play_upgrade` (visual): `yolk.scale = Vector2.ZERO`
- L54, `_process` (regla/valor): `if elapsed>=1.12 and not impact_announced:`
- L59, `_process` (literal adicional (revisión)): `var distance := minf(280, card.size.x * 0.25)`
- L60, `_process` (literal adicional (revisión)): `veil.modulate.a = minf(1, elapsed / 0.16)`
- L61, `_process` (literal adicional (revisión)): `card.modulate.a = minf(1, elapsed / 0.16)`
- L62, `_process` (literal adicional (revisión)): `flash.visible = elapsed >= 1.12 and elapsed < 1.17`
- L63, `_process` (regla/valor): `if elapsed < 0.4:`
- L64, `_process` (regla/valor): `var appear := 1.0 - pow(1.0 - clampf(elapsed / 0.3, 0, 1), 3)`
- L65, `_process` (visual): `coin.position = center - Vector2(distance,0)`
- L66, `_process` (visual): `yolk.position = center + Vector2(distance,0)`
- L67, `_process` (visual): `coin.scale = Vector2.ONE * appear * source_item.icon_scale`
- L68, `_process` (visual): `yolk.scale = Vector2.ONE * appear`
- L69, `_process` (regla/valor): `elif elapsed < 0.9:`
- L70, `_process` (regla/valor): `var anticipation := 1.0 - pow(1.0 - (elapsed - 0.4) / 0.5, 3)`
- L71, `_process` (regla/valor): `var stretch := Vector2.ONE.lerp(Vector2(0.82,1.15), anticipation)`
- L72, `_process` (visual): `coin.position = center - Vector2(distance + 90 * anticipation,0)`
- L73, `_process` (visual): `yolk.position = center + Vector2(distance + 90 * anticipation,0)`
- L74, `_process` (visual): `coin.scale = stretch * source_item.icon_scale`
- L75, `_process` (visual): `yolk.scale = stretch`
- L76, `_process` (regla/valor): `elif elapsed < 1.12:`
- L77, `_process` (literal adicional (revisión)): `var strike := pow((elapsed - 0.9) / 0.22, 3)`
- L78, `_process` (regla/valor): `var stretch := Vector2(0.82,1.15).lerp(Vector2(1.55,0.65), strike)`
- L79, `_process` (visual): `coin.position = center - Vector2((distance + 90) * (1 - strike),0)`
- L80, `_process` (visual): `yolk.position = center + Vector2((distance + 90) * (1 - strike),0)`
- L81, `_process` (visual): `coin.scale = stretch * source_item.icon_scale`
- L82, `_process` (visual): `yolk.scale = stretch`
- L83, `_process` (regla/valor): `elif elapsed < 1.3:`
- L88, `_process` (regla/valor): `var appear := 1.0 - pow(1.0 - clampf((elapsed - 1.3) / 0.24, 0, 1), 3)`
- L89, `_process` (visual): `coin.position = center`
- L90, `_process` (visual): `coin.scale = Vector2.ONE * 1.3 * source_item.icon_scale * appear * (1 + 0.02 * sin(elapsed * 4.3))`
- L92, `_process` (regla/valor): `if elapsed >= 2.8 and not continue_button.visible:`
- L98, `_process` (literal adicional (revisión)): `particle.velocity *= exp(-1.8 * delta)`
- L99, `_process` (regla/valor): `if not particle.spark: particle.velocity.y += 290.0 * delta`
- L109, `_reveal_upgrade` (visual): `card_style.bg_color = Color("504025") if success else Color("512a2b")`
- L110, `_reveal_upgrade` (texto): `card_style.border_color = Color("d6a63c") if success else Color("a7564c")`
- L111, `_reveal_upgrade` (visual): `veil.color = Color(0.09, 0.06, 0.015, 0.76) if success else Color(0.12, 0.025, 0.025, 0.79)`
- L116, `_reveal_upgrade` (texto): `coin.material = load("res://effects/golden_visual.gd").material_for(improved_item)`
- L118, `_reveal_upgrade` (texto): `result_label.text = "+%d%%" % roundi(improvement * 100)`
- L119, `_reveal_upgrade` (texto): `result_label.add_theme_color_override("font_color", Color("ffd344"))`
- L121, `_reveal_upgrade` (texto): `perfect_glints = load("res://effects/golden_sparkles.gd").new()`
- L122, `_reveal_upgrade` (visual): `perfect_glints.position = coin.size * 0.5`
- L123, `_reveal_upgrade` (literal adicional (revisión)): `perfect_glints.radius = 110`
- L128, `_reveal_upgrade` (texto): `result_label.text = "ITEM BROKEN"`
- L129, `_reveal_upgrade` (texto): `result_label.add_theme_color_override("font_color", Color("ee6960"))`
- L130, `_reveal_upgrade` (literal adicional (revisión)): `result_label.position.y = card.size.y * 0.5 - 36`
- L134, `_layout` (visual): `if revealed and not improved_item: result_label.position.y = card.size.y * 0.5 - 36`
- L137, `close` (regla/valor): `if elapsed < 2.8: return`

## scenes/ui/shop/item_card.gd

63 líneas; 1 anotaciones export; 0 uniforms; 12 candidatos.

### Ya expuesto en el editor

- L8: `@export var item: ItemBase: set  = _set_item`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var quantity := 1:`
- L12, `declaración` (literal adicional (revisión)): `quantity = maxi(1, value)`
- L43, `_refresh_marker` (texto): `load("res://scenes/ui/rarity_marker.gd").apply(self, int(item.item_tier), true)`
- L46, `_refresh_marker` (literal adicional (revisión)): `marker.visible = quantity > 1`
- L48, `_refresh_marker` (texto): `label.text = str(quantity)`
- L49, `_refresh_marker` (texto): `label.add_theme_color_override("font_color", UITheme.palette.text)`
- L52, `_refresh_golden_visual` (texto): `item_icon.material = load("res://effects/golden_visual.gd").material_for(item) if item.golden_multiplier > 1.0 else null`
- L58, `_refresh_golden_visual` (texto): `var stars = load("res://effects/golden_sparkles.gd").new()`
- L59, `_refresh_golden_visual` (literal adicional (revisión)): `stars.name = "GoldenSparkles"`
- L60, `_refresh_golden_visual` (visual): `stars.position = size * 0.5`
- L61, `_refresh_golden_visual` (literal adicional (revisión)): `stars.radius = minf(size.x, size.y) * 0.45`
- L63, `_refresh_golden_visual` (literal adicional (revisión)): `tooltip_text = ""`

## scenes/ui/shop/sale_badge.gd

26 líneas; 0 anotaciones export; 0 uniforms; 9 candidatos.

### Candidatos / evidencia

- L11, `set_caption` (texto): `caption.text = value`
- L16, `_draw` (literal adicional (revisión)): `var center := size * 0.5`
- L17, `_draw` (literal adicional (revisión)): `for index in 32:`
- L18, `_draw` (literal adicional (revisión)): `var angle := TAU * index / 32.0 - PI * 0.5`
- L19, `_draw` (regla/valor): `var radius := 1.0 if index % 2 == 0 else 0.76`
- L20, `_draw` (literal adicional (revisión)): `points.append(center + Vector2(cos(angle) * size.x * 0.5, sin(angle) * size.y * 0.5) * radius)`
- L22, `_draw` (literal adicional (revisión)): `for point in points: shadow.append(point + Vector2(0, 3))`
- L25, `_draw` (literal adicional (revisión)): `points.append(points[0])`
- L26, `_draw` (literal adicional (revisión)): `draw_polyline(points, Color("ce4708"), 1.5, true)`

## scenes/ui/shop/shop_card.gd

114 líneas; 1 anotaciones export; 0 uniforms; 26 candidatos.

Hallazgos: ECO-11, UI-10.

### Ya expuesto en el editor

- L38: `@export var shop_item: ItemBase: set = _set_shop_item`

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var shop_wave := 1`
- L8, `declaración` (regla/valor): `var title_maximum := 20`
- L12, `declaración` (regla/valor): `var sale_discount_percent := 0`
- L17, `has_sale` (regla/valor): `return sale_discount_percent > 0 or sale_two_for_one`
- L21, `get_effective_price` (regla/valor): `return maxi(1, floori(base * (100 - sale_discount_percent) / 100.0))`
- L23, `set_sale` (literal adicional (revisión)): `func set_sale(discount: int = 0, two_for_one: bool = false) -> void:`
- L25, `set_sale` (regla/valor): `sale_discount_percent = 0 if two_for_one else clampi(discount, 0, 90)`
- L30, `_refresh_sale` (texto): `item_cost.text = str(get_effective_price())`
- L32, `_refresh_sale` (texto): `sale_badge = preload("res://scenes/ui/shop/sale_badge.tscn").instantiate()`
- L36, `_refresh_sale` (literal adicional (revisión)): `sale_badge.set_caption("2×1" if sale_two_for_one else "−%d%%" % sale_discount_percent)`
- L55, `_on_lock_toggled` (texto): `lock_button.text = "LOCKED" if locked else "LOCK"`
- L62, `set_locked` (texto): `lock_button.text = "LOCKED" if value else "LOCK"`
- L73, `_set_shop_item` (literal adicional (revisión)): `sale_discount_percent = 0`
- L78, `_set_shop_item` (texto): `item_name.text = shop_item.item_name.replace("\n"," ")`
- L80, `_set_shop_item` (texto): `item_type.text = ItemBase.ItemType.keys()[shop_item.item_type]`
- L82, `_set_shop_item` (texto): `item_description.text = UITheme.rich_text((shop_item as ItemWeapon).get_description(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null))`
- L84, `_set_shop_item` (texto): `item_description.text = UITheme.rich_text(shop_item.get_description())`
- L85, `_set_shop_item` (texto): `item_cost.text = str(shop_item.get_shop_price(shop_wave))`
- L92, `_set_shop_item` (texto): `add_theme_stylebox_override("panel", style)`
- L93, `_set_shop_item` (texto): `load("res://scenes/ui/rarity_marker.gd").apply(self, int(shop_item.item_tier))`
- L98, `_fit_item_title` (visual): `if not is_instance_valid(item_name) or item_name.size.x<=0: return`
- L102, `_fit_item_title` (literal adicional (revisión)): `var measured: float=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,maximum).x`
- L103, `_fit_item_title` (visual): `var fitted: int=maximum if measured<=item_name.size.x else maxi(1,floori(maximum*item_name.size.x/measured))`
- L104, `_fit_item_title` (literal adicional (revisión)): `while fitted>1 and font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,fitted).x>item_name.size.x:`
- L105, `_fit_item_title` (literal adicional (revisión)): `fitted-=1`
- L107, `_fit_item_title` (texto): `item_name.add_theme_font_size_override("font_size",fitted)`

## scenes/ui/shop/shop_panel.gd

747 líneas; 3 anotaciones export; 0 uniforms; 135 candidatos.

Hallazgos: ECO-07, ECO-08, ITEM-10, UI-07, DEV-02.

### Ya expuesto en el editor

- L10: `@export var shop_items: Array[ItemBase]`
- L12: `@export var test_hoarder_chocolate_coin := true`
- L13: `@export var test_glass_egg_golden_yolk := true`

### Candidatos / evidencia

- L6, `declaración` (constante): `const MAX_WEAPON_OFFERS := 2`
- L7, `declaración` (constante): `const SHOP_CARD_SCENE = preload("res://scenes/ui/shop/shop_card.tscn")`
- L8, `declaración` (constante): `const WEAPON_TOOLTIP_SCENE = preload("res://scenes/ui/shop/weapon_tooltip.tscn")`
- L31, `declaración` (regla/valor): `var shop_wave := 1`
- L32, `declaración` (regla/valor): `var pending_level_rewards := 0`
- L33, `declaración` (regla/valor): `var reroll_count := 0`
- L37, `declaración` (regla/valor): `var next_stage_wave := 0`
- L56, `set_next_stage` (regla/valor): `var notices: Array[String] = []`
- L67, `set_next_stage` (texto): `next_stage_label.text = boss_settings.boss_name`
- L68, `set_next_stage` (texto): `next_stage_description.text = "BOSS · Defeat the boss to complete the wave"`
- L79, `set_next_stage` (texto): `next_stage_label.text = stage.display_name if special_arena else "EVENTS"`
- L80, `set_next_stage` (texto): `next_stage_description.text = " · ".join(notices)`
- L99, `_position_weapon_actions` (visual): `var desired := Vector2(rect.get_center().x - weapon_actions.size.x * 0.5, rect.position.y - weapon_actions.size.y - 12)`
- L101, `_position_weapon_actions` (literal adicional (revisión)): `weapon_actions.global_position = desired.clamp(bounds.position + Vector2(12, 12), bounds.end - weapon_actions.size - Vector2(12, 12))`
- L105, `_ready` (texto): `shop_items.append_array(load("res://resources/items/passives/catalogue.gd").items())`
- L106, `_ready` (texto): `for item in load("res://resources/items/weapons/melee_catalogue.gd").items(true):`
- L110, `_ready` (texto): `for item in load("res://resources/items/weapons/spicy_catalogue.gd").items(true):`
- L118, `_ready` (texto): `coin_animation = load("res://scenes/ui/shop/chocolate_coin_reveal.tscn").instantiate()`
- L120, `_ready` (texto): `golden_animation = load("res://scenes/ui/shop/golden_yolk_reveal.tscn").instantiate()`
- L124, `_ready` (regla/valor): `if Global.coins < 1: return`
- L148, `load_shop` (literal adicional (revisión)): `shop_wave = maxi(1, current_wave)`
- L150, `load_shop` (literal adicional (revisión)): `gamble_button.visible = is_instance_valid(Global.player) and Global.player.stats.unlock_id == "gambler"`
- L151, `load_shop` (literal adicional (revisión)): `reroll_count = 0`
- L157, `_locked_offer_keys` (regla/valor): `var keys: Array = []`
- L163, `_populate_offers` (regla/valor): `var next_offer := 0`
- L172, `_populate_offers` (regla/valor): `next_offer += 1`
- L183, `_populate_offers` (regla/valor): `next_offer += 1`
- L184, `_populate_offers` (texto): `var owned: Array[String] = load("res://resources/shop_weapon_bias.gd").families(load("res://resources/shop_weapon_bias.gd").equipped(Global.player))`
- L198, `_eligible_shop_items` (regla/valor): `var result: Array[ItemBase] = []`
- L199, `_eligible_shop_items` (texto): `var policy = load("res://resources/shop_weapon_bias.gd")`
- L203, `_eligible_shop_items` (literal adicional (revisión)): `if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and is_instance_valid(Global.player) and not item.available_for(Global.player): continue`
- L210, `_choose_shop_candidate` (texto): `var policy = load("res://resources/shop_weapon_bias.gd")`
- L214, `_draw_shop_items` (regla/valor): `var result: Array = []`
- L216, `_draw_shop_items` (literal adicional (revisión)): `var remaining_weapons := maxi(0, weapon_budget)`
- L217, `_draw_shop_items` (literal adicional (revisión)): `for slot in maxi(0, amount):`
- L218, `_draw_shop_items` (regla/valor): `var allowed := pool.filter(func(item): return remaining_weapons > 0 or not item is ItemWeapon)`
- L219, `_draw_shop_items` (literal adicional (revisión)): `var draw := Global.select_items_for_offer(allowed, wave, Global.SHOP_PROBABILITY_CONFIG, 1, excluded, _choose_shop_candidate)`
- L221, `_draw_shop_items` (literal adicional (revisión)): `var item: ItemBase = draw[0]`
- L224, `_draw_shop_items` (regla/valor): `if item is ItemWeapon: remaining_weapons -= 1`
- L232, `select_shop_offers` (regla/valor): `var offers: Array = []`
- L234, `select_shop_offers` (visual): `var slots := 4 - excluded_keys.size()`
- L236, `select_shop_offers` (literal adicional (revisión)): `var weapon_slots := maxi(0, MAX_WEAPON_OFFERS - retained_weapons)`
- L237, `select_shop_offers` (regla/valor): `if slots <= 0: return offers`
- L238, `select_shop_offers` (texto): `var policy = load("res://resources/shop_weapon_bias.gd")`
- L242, `select_shop_offers` (visual): `if weapon_slots > 0 and held.size() > 0 and held.size() < 3 and not equipped_guarantee_shown and not locked_match:`
- L246, `select_shop_offers` (literal adicional (revisión)): `var guaranteed := _draw_shop_items(matches, completed_wave, 1, keys)`
- L249, `select_shop_offers` (regla/valor): `if completed_wave <= 2:`
- L251, `select_shop_offers` (visual): `if completed_wave == 1 and offers.size() < mini(slots, weapon_slots):`
- L266, `_refill_offer` (regla/valor): `var keys: Array = []`
- L267, `_refill_offer` (regla/valor): `var retained_weapons := 0`
- L271, `_refill_offer` (regla/valor): `if other.shop_item is ItemWeapon: retained_weapons += 1`
- L272, `_refill_offer` (literal adicional (revisión)): `var weapon_budget := maxi(0, MAX_WEAPON_OFFERS - retained_weapons)`
- L274, `_refill_offer` (literal adicional (revisión)): `var offers := _draw_shop_items(_eligible_shop_items(), shop_wave, 1, keys + [purchased.get_offer_key()], weapon_budget)`
- L276, `_refill_offer` (literal adicional (revisión)): `offers = _draw_shop_items(_eligible_shop_items(), shop_wave, 1, keys, weapon_budget)`
- L280, `_refill_offer` (literal adicional (revisión)): `card.shop_item = offers[0]`
- L289, `get_reroll_cost` (texto): `var discount: float = 0.1 * Global.player.passive_items.power("butcher") if is_instance_valid(Global.player) else 0.0`
- L290, `get_reroll_cost` (regla/valor): `return maxi(0, floori(ItemBase.ECONOMY_RULES.reroll_price(shop_wave, reroll_count) * maxf(0.0, 1.0-discount)))`
- L297, `try_reroll` (regla/valor): `var previous_keys: Array = []`
- L300, `try_reroll` (visual): `var required := 4 - locked.size()`
- L301, `try_reroll` (regla/valor): `if required <= 0: return false`
- L306, `try_reroll` (regla/valor): `reroll_count += 1`
- L317, `_process` (regla/valor): `if is_instance_valid(gamble_button): gamble_button.disabled = Global.coins <= 0`
- L321, `_update_reroll_button` (texto): `reroll_cost_label.text = "refresh %s" % get_reroll_cost()`
- L322, `_update_reroll_button` (literal adicional (revisión)): `reroll_button.disabled = Global.coins < get_reroll_cost() or _locked_offer_keys().size() >= 4`
- L323, `_update_reroll_button` (texto): `reroll_cost_label.add_theme_color_override("font_color", UITheme.palette.disabled_text if reroll_button.disabled else UITheme.palette.text)`
- L360, `try_purchase_item` (literal adicional (revisión)): `func try_purchase_item(item: ItemBase, price_wave: int = -1, price_override: int = -1) -> bool:`
- L362, `try_purchase_item` (literal adicional (revisión)): `if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and not item.available_for(Global.player): return false`
- L364, `try_purchase_item` (regla/valor): `var price := item.get_shop_price(shop_wave if price_wave < 0 else price_wave)`
- L365, `try_purchase_item` (regla/valor): `if price_override >= 0: price = clampi(price_override, 1, price)`
- L376, `_on_item_purchased` (literal adicional (revisión)): `if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd" and not item.available_for(Global.player): return`
- L389, `_on_item_purchased` (regla/valor): `if owned is ItemCard and not owned.is_queued_for_deletion() and owned.item.get_offer_key() == item.get_offer_key() and owned.item.golden_multiplier == 1.0:`
- L390, `_on_item_purchased` (regla/valor): `owned.quantity += 1`
- L411, `_auto_upgrade_purchased_weapon` (regla/valor): `if equipment_index < 0: return`
- L418, `_auto_upgrade_purchased_weapon` (literal adicional (revisión)): `Progression.record("combines", 1.0)`
- L426, `_get_combine_weapons` (regla/valor): `var result: Array[Weapon] = []`
- L448, `_on_item_card_selected` (literal adicional (revisión)): `combine_button.disabled = _get_combine_weapons(card).size() != 2`
- L454, `_on_item_card_selected` (literal adicional (revisión)): `weapon_actions.get_child(0).get_child(1).grab_focus()`
- L461, `reset_offers` (literal adicional (revisión)): `reroll_count = 0`
- L484, `_on_combine_button_pressed` (visual): `if weapons_to_remove.size() < 2 or cards_to_remove.size() < 2: return`
- L495, `_on_combine_button_pressed` (literal adicional (revisión)): `var upgraded_weapon := _inherit_golden_upgrade(clicked_weapon.upgrade_to, [weapons_to_remove[0].data, weapons_to_remove[1].data])`
- L507, `_on_combine_button_pressed` (literal adicional (revisión)): `Progression.record("combines", 1.0)`
- L541, `_can_receive_two` (visual): `return Progression.is_weapon_unlocked(item) and player.stats.can_use_weapon(item) and maxi(player.current_weapons.size(), Global.equipped_weapons.size()) + 2 <= player.get_weapon_limit()`
- L542, `_can_receive_two` (literal adicional (revisión)): `if item is ItemPassive and item.get_script().resource_path == "res://resources/items/passives/catalogue_passive.gd":`
- L544, `_can_receive_two` (regla/valor): `if item.max_copies == 1: return false`
- L546, `_can_receive_two` (regla/valor): `if item.max_copies > 0 and player.passive_items.count(item.effect_key) + 2 > item.max_copies: return false`
- L547, `_can_receive_two` (texto): `if item.effect_key == "extra_slot" and player.passive_items.count("extra_slot") + 2 > 3: return false`
- L552, `_ensure_liquidation_offer` (regla/valor): `var candidates: Array[ShopCard] = []`
- L553, `_ensure_liquidation_offer` (regla/valor): `var fallback: Array[ShopCard] = []`
- L574, `_sync_weapon_slots` (regla/valor): `var occupied: Array[Node]=[]`
- L575, `_sync_weapon_slots` (regla/valor): `var empty: Array[Node]=[]`
- L580, `_sync_weapon_slots` (literal adicional (revisión)): `var needed:=maxi(0,Global.player.get_weapon_limit()-occupied.size())`
- L586, `_sync_weapon_slots` (texto): `var slot=preload("res://scenes/ui/shop/empty_weapon_slot.tscn").instantiate()`
- L588, `_sync_weapon_slots` (literal adicional (revisión)): `UITheme.style_slot(slot,0)`
- L596, `apply_golden_yolk` (literal adicional (revisión)): `func apply_golden_yolk(card: ItemCard, test_roll: float = -1.0) -> bool:`
- L600, `apply_golden_yolk` (regla/valor): `if manager.golden_yolks <= 0: return false`
- L601, `apply_golden_yolk` (regla/valor): `var owned_record: Dictionary = {}`
- L607, `apply_golden_yolk` (texto): `var enhancement = load("res://resources/items/golden_enhancement.gd")`
- L608, `apply_golden_yolk` (texto): `var config = load("res://resources/items/passives/catalogue/item_078.tres")`
- L610, `apply_golden_yolk` (literal adicional (revisión)): `manager.golden_yolks -= 1`
- L615, `apply_golden_yolk` (regla/valor): `var replacement: ItemBase = enhancement.improve(original, outcome) if outcome >= 0.0 else null`
- L621, `apply_golden_yolk` (regla/valor): `if index >= 0: Global.equipped_weapons[index] = replacement`
- L625, `apply_golden_yolk` (texto): `load("res://effects/golden_visual.gd").apply_weapon(weapon)`
- L628, `apply_golden_yolk` (regla/valor): `if index >= 0: Global.equipped_weapons.remove_at(index)`
- L636, `apply_golden_yolk` (regla/valor): `if card.quantity > 1:`
- L637, `apply_golden_yolk` (literal adicional (revisión)): `card.quantity -= 1`
- L662, `_inherit_golden_upgrade` (literal adicional (revisión)): `var best: ItemWeapon = donors[0]`
- L666, `_inherit_golden_upgrade` (regla/valor): `if best.golden_multiplier > 1.0:`
- L667, `_inherit_golden_upgrade` (texto): `result = load("res://resources/items/golden_enhancement.gd").improve(base, best.golden_multiplier - 1.0, best.golden_penalty_multiplier)`
- L669, `_inherit_golden_upgrade` (texto): `return load("res://resources/items/breading.gd").inherit_tags(result, donors)`
- L680, `apply_breading` (literal adicional (revisión)): `func apply_breading(card: ItemCard, test_tag: int = -1) -> bool:`
- L685, `apply_breading` (regla/valor): `if manager.breading_charges <= 0: return false`
- L686, `apply_breading` (texto): `var breading = load("res://resources/items/breading.gd")`
- L689, `apply_breading` (literal adicional (revisión)): `golden_result.title = "Rebozado"`
- L690, `apply_breading` (texto): `golden_result.dialog_text = "Esa arma ya tiene todas las tags compatibles. Elegí otra arma."`
- L691, `apply_breading` (regla/valor): `if is_visible_in_tree(): golden_result.popup_centered(Vector2i(590, 180))`
- L693, `apply_breading` (regla/valor): `var tag: int = choices.pick_random() if test_tag < 0 else test_tag`
- L699, `apply_breading` (regla/valor): `if index >= 0: Global.equipped_weapons[index] = replacement`
- L703, `apply_breading` (texto): `load("res://effects/golden_visual.gd").apply_weapon(weapon)`
- L705, `apply_breading` (literal adicional (revisión)): `manager.breading_charges -= 1`
- L712, `apply_breading` (literal adicional (revisión)): `golden_result.title = "Rebozado"`
- L713, `apply_breading` (texto): `golden_result.dialog_text = "%s recibió la tag %s." % [replacement.item_name, ItemWeapon.TAG_LABELS[tag]]`
- L714, `apply_breading` (regla/valor): `if is_visible_in_tree(): golden_result.popup_centered(Vector2i(590, 180))`
- L718, `set_pending_level_rewards` (literal adicional (revisión)): `pending_level_rewards = maxi(0, amount)`
- L719, `set_pending_level_rewards` (regla/valor): `var next_wave: int = next_stage_wave if next_stage_wave > 0 else shop_wave + 1`
- L720, `set_pending_level_rewards` (texto): `$MarginContainer/Control/VBoxContainer/NewWaveButton.text = "UPGRADES (%d)" % pending_level_rewards if pending_level_rewards > 0 else "next wave %d" % next_wave`
- L723, `show_ayahuasca_result` (literal adicional (revisión)): `golden_result.title = "Ayahuasca"`
- L724, `show_ayahuasca_result` (texto): `golden_result.dialog_text = message`
- L725, `show_ayahuasca_result` (regla/valor): `if is_visible_in_tree(): golden_result.popup_centered(Vector2i(620, 200))`
- L727, `resolve_chocolate_coin` (literal adicional (revisión)): `func resolve_chocolate_coin(forced_outcome: int = -1) -> bool:`
- L729, `resolve_chocolate_coin` (regla/valor): `var success := randf() < 0.5 if forced_outcome < 0 else forced_outcome == 1`
- L730, `resolve_chocolate_coin` (regla/valor): `Global.coins = Global.coins * 2 if success else 0`
- L737, `_ensure_test_consumable` (regla/valor): `var path := ""`
- L738, `_ensure_test_consumable` (texto): `if test_hoarder_chocolate_coin and character == "hoarder": path = "res://resources/items/passives/catalogue/item_034.tres"`
- L739, `_ensure_test_consumable` (texto): `elif test_glass_egg_golden_yolk and character == "glass_egg": path = "res://resources/items/passives/catalogue/item_078.tres"`
- L741, `_ensure_test_consumable` (regla/valor): `var test_item: ItemBase = load(path)`

## scenes/ui/shop/weapon_tooltip.gd

155 líneas; 2 anotaciones export; 0 uniforms; 32 candidatos.

Hallazgos: UI-08.

### Ya expuesto en el editor

- L4: `@export var manual_selection := false`
- L5: `@export var show_full_description := false`

### Candidatos / evidencia

- L7, `declaración` (regla/valor): `var shop_wave_override := -1`
- L11, `declaración` (constante): `const SCREEN_MARGIN := 12.0`
- L12, `declaración` (constante): `const SLOT_GAP := 10.0`
- L22, `declaración` (regla/valor): `var value_labels: Array[RichTextLabel] = []`
- L26, `_ready` (literal adicional (revisión)): `for i in 9:`
- L27, `_ready` (texto): `var cell=stats_grid.get_node("Value%d" % i) if i!=7 else stats_grid.get_node("ValueSaleMargin/Value7")`
- L84, `_update_weapon` (texto): `weapon_name.text = weapon.item_name`
- L85, `_update_weapon` (texto): `weapon_type.text = weapon.get_category_label()`
- L89, `_update_weapon` (literal adicional (revisión)): `style.set_border_width_all(2)`
- L92, `_update_weapon` (texto): `add_theme_stylebox_override("panel", style)`
- L94, `_update_weapon` (regla/valor): `var values: Array[String] = [`
- L98, `_update_weapon` (regla/valor): `"%s%%" % _format_number(weapon.get_effective_critical_chance(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null) * 100.0),`
- L99, `_update_weapon` (regla/valor): `"%s%%" % _format_number(weapon.get_effective_life_steal(preview_stats if preview_stats else Global.player.stats if is_instance_valid(Global.player) else null) * 100.0),`
- L102, `_update_weapon` (regla/valor): `str(weapon.get_sell_price(shop_wave_override if shop_wave_override>=0 else (get_parent() as ShopPanel).shop_wave if get_parent() is ShopPanel else 1)),`
- L106, `_update_weapon` (regla/valor): `var show_stat := index < 5 or index >= 7 or (weapon.has_tag(ItemWeapon.Tag.RANGED) and ((index == 5 and stats.unlimited_piercing) or int(values[index]) > 0))`
- L107, `_update_weapon` (literal adicional (revisión)): `stats_grid.get_child(index * 2).visible = show_stat`
- L109, `_update_weapon` (texto): `value_labels[index].add_theme_color_override("default_color", UITheme.palette.positive)`
- L110, `_update_weapon` (texto): `value_labels[index].text = "[right]%s[/right]" % UITheme.rich_text(values[index])`
- L113, `_update_weapon` (regla/valor): `var extra: PackedStringArray=[]`
- L115, `_update_weapon` (texto): `if line.get_slice(":",0).strip_edges().to_lower() not in ["damage","cooldown","range","critical chance","life steal","piercing","bounces"]: extra.append(line)`
- L117, `_update_weapon` (texto): `if full_description.text!=description: full_description.text=description`
- L128, `_update_passive` (texto): `weapon_name.text = item.item_name`
- L129, `_update_passive` (texto): `weapon_type.text = "Passive" + (" · ×%d" % hovered_card.quantity if hovered_card.quantity > 1 else "")`
- L132, `_update_passive` (literal adicional (revisión)): `style.set_border_width_all(2)`
- L135, `_update_passive` (texto): `add_theme_stylebox_override("panel", style)`
- L136, `_update_passive` (texto): `passive_description.text = item.get_description()`
- L137, `_update_passive` (regla/valor): `if item.golden_multiplier > 1.0:`
- L138, `_update_passive` (literal adicional (revisión)): `passive_description.text += "\nBeneficios ×%s · Penalizaciones ×%s%s" % [ItemWeapon.format_number(item.golden_multiplier), ItemWeapon.format_number(item.golden_penalty_multiplier), " · Perfecta" if item.golden_perfect else ""]`
- L142, `_update_passive` (texto): `if full_description.text!=passive_description.text: full_description.text=passive_description.text`
- L146, `_format_number` (regla/valor): `return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".")`
- L152, `_position_above_card` (visual): `var bounds:=Rect2(Vector2.ZERO,parent_control.size).grow(-SCREEN_MARGIN)`
- L153, `_position_above_card` (visual): `var target:=Vector2(slot_rect.get_center().x-size.x*.5,slot_rect.position.y-size.y-SLOT_GAP)`

## scenes/ui/start_panel/start_panel.gd

35 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L14, `_ready` (literal adicional (revisión)): `$DebugProgressTools.get_child(0).pressed.connect(_debug_progress_action.bind(true))`
- L15, `_ready` (literal adicional (revisión)): `$DebugProgressTools.get_child(1).pressed.connect(_debug_progress_action.bind(false))`
- L19, `_debug_progress_action` (texto): `debug_status.text = ("Progreso reseteado" if reset else "Todo desbloqueado") if saved else "No se pudo guardar el cambio"`

## scenes/ui/stats/stats_container.gd

111 líneas; 1 anotaciones export; 0 uniforms; 16 candidatos.

Hallazgos: UI-03.

### Ya expuesto en el editor

- L4: `@export var initial_secondary := false`

### Candidatos / evidencia

- L8, `declaración` (constante): `const PRIMARY := ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "effects", "weapon_range", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]`
- L9, `declaración` (constante): `const SECONDARY := ["slow_strength", "knockback", "experience_gain", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range", "piercing", "bounces", "dash_cooldown"]`
- L10, `declaración` (constante): `const TITLES := {"dash_cooldown":"Dash cooldown:", "chili_power":"Chili Power:", "explosive_damage":"Explosive damage:","slow_strength":"Slow potency:", "weapon_range":"Range:", "knockback":"Push:", "experience_gain":"Experience gain:", "critical_multiplier":"Crit multiplier bonus:", "area_of_effect":"Area of effect:", "effects":"Effects:", "crowd_control":"Crowd control:", "fire_tick_speed":"Fire tick speed:", "block_effectiveness":"Block Power:", "piercing":"Piercing:", "bounces":"Bounces:"}`
- L11, `declaración` (constante): `const PERCENT_STATS := ["slow_strength", "experience_gain", "life_steal", "damage_percent", "attack_speed", "critical_chance", "block_chance", "critical_multiplier", "area_of_effect", "chili_power", "explosive_damage", "crowd_control", "fire_tick_speed", "block_effectiveness", "pickup_range"]`
- L13, `declaración` (constante): `const HELP_TEXT := "Esta estadística modifica las capacidades de tu personaje. Descripción provisional: más adelante detallaremos su efecto y cómo se calcula."`
- L17, `declaración` (regla/valor): `var extra_labels: Dictionary = {}`
- L18, `declaración` (regla/valor): `var stat_labels: Dictionary = {}`
- L19, `declaración` (regla/valor): `var stat_rows: Dictionary = {}`
- L86, `_update_values` (literal adicional (revisión)): `if stat == "dash_cooldown":`
- L87, `_update_values` (texto): `stat_labels[stat].text = ItemWeapon.format_number(player.get_dash_cooldown()) + " s"`
- L89, `_update_values` (texto): `var value: float = player.stats.get_block_chance() if stat == "block_chance" else float(player.stats.get(stat))`
- L90, `_update_values` (texto): `stat_labels[stat].text = ItemWeapon.format_number(value) + ("%" if stat in PERCENT_STATS else "")`
- L99, `_show_stat_help` (texto): `stat_help_title.text = caption.trim_suffix(":")`
- L106, `_position_stat_help` (literal adicional (revisión)): `var bounds := get_viewport_rect().grow(-12)`
- L107, `_position_stat_help` (visual): `var point := Vector2(slot.position.x - stat_help.size.x - 12, slot.position.y)`
- L108, `_position_stat_help` (visual): `if point.x < bounds.position.x: point.x = slot.end.x + 12`

## scenes/ui/unlock_notice.gd

156 líneas; 0 anotaciones export; 0 uniforms; 32 candidatos.

Hallazgos: FX-03.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var pending: Array[Dictionary] = []`
- L5, `declaración` (regla/valor): `var elapsed := 0.0`
- L48, `_on_unlock_earned` (regla/valor): `if weapon is ItemWeapon and weapon.unlock_id == id and weapon.item_tier == 0:`
- L57, `_begin_next` (literal adicional (revisión)): `elapsed = 0`
- L81, `_begin_next` (texto): `material.shader = preload("res://shaders/locked_silhouette.gdshader")`
- L82, `_begin_next` (texto): `material.set_shader_parameter("silhouette_color",UITheme.palette.hud_text.darkened(0.8))`
- L84, `_begin_next` (texto): `name_label.text = ""`
- L85, `_begin_next` (texto): `requirement_label.text = ""`
- L87, `_begin_next` (literal adicional (revisión)): `details_panel.modulate.a = 0`
- L98, `_process` (literal adicional (revisión)): `elapsed += delta/maxf(0.01,Engine.time_scale)`
- L99, `_process` (literal adicional (revisión)): `var slide := smoothstep(0,1,clampf((elapsed-2.1)/0.7,0,1))`
- L100, `_process` (texto): `icon.position = icon_start.lerp(stage.get_node("IconEnd").position,slide)`
- L101, `_process` (texto): `name_label.position = name_start.lerp(stage.get_node("NameEnd").position,slide)`
- L102, `_process` (texto): `requirement_label.position = requirement_start.lerp(stage.get_node("RequirementEnd").position,slide)`
- L103, `_process` (regla/valor): `if elapsed < 1.25:`
- L104, `_process` (visual): `icon.scale = Vector2.ONE * lerpf(0.8,1.15,minf(1,elapsed/1.25))`
- L105, `_process` (regla/valor): `icon.rotation = sin(elapsed*65.0)*0.045 if elapsed > 0.65 else 0.0`
- L110, `_process` (visual): `sparks.position = icon.position+icon.size*0.5`
- L115, `_process` (texto): `name_label.text = resource.name if resource is UnitStats else resource.item_name`
- L116, `_process` (texto): `requirement_label.text = current.requirement`
- L118, `_process` (texto): `details.text = _character_details(resource)`
- L120, `_process` (texto): `details.text = UITheme.rich_text(resource.get_description())`
- L121, `_process` (literal adicional (revisión)): `var bounce := sin((elapsed-1.25)*22.0)*exp(-(elapsed-1.25)*5.0)*0.22`
- L122, `_process` (visual): `icon.scale = Vector2(1.22+bounce,1.22-bounce)`
- L123, `_process` (regla/valor): `icon.rotation = 0`
- L124, `_process` (regla/valor): `if elapsed >= 2.1:`
- L127, `_process` (regla/valor): `if elapsed >= 3.0 and continue_button.disabled:`
- L134, `_continue` (regla/valor): `if not active or elapsed < 3.0: return`
- L147, `_character_details` (regla/valor): `var lines: PackedStringArray = ["[b]CHARACTER[/b]"]`
- L149, `_character_details` (literal adicional (revisión)): `var value: float = preview.get(stat[0])`
- L150, `_character_details` (texto): `if is_zero_approx(value) and stat[0] not in ["health","speed"]: continue`
- L151, `_character_details` (regla/valor): `lines.append("%s: %s%s" % [stat[1],ItemWeapon.format_number(value),"%" if stat[2] else ""])`

## scenes/ui/upgrades/upgrade_card.gd

38 líneas; 1 anotaciones export; 0 uniforms; 8 candidatos.

### Ya expuesto en el editor

- L4: `@export var item: ItemUpgrade: set = _set_data`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var title_maximum := 30`
- L21, `_set_data` (texto): `item_name.text = item.item_name`
- L23, `_set_data` (literal adicional (revisión)): `var text_width := font.get_string_size(item.item_name, HORIZONTAL_ALIGNMENT_LEFT, -1, title_maximum).x`
- L24, `_set_data` (texto): `item_name.add_theme_font_size_override("font_size", int(clampf(float(title_maximum) * item_name.size.x / maxf(text_width,item_name.size.x), 1.0, float(title_maximum))))`
- L25, `_set_data` (texto): `item_description.text = item.description`
- L29, `_set_data` (texto): `add_theme_stylebox_override("panel", style)`
- L30, `_set_data` (texto): `load("res://scenes/ui/rarity_marker.gd").apply(self, int(item.item_tier))`
- L35, `_on_custom_button_pressed` (texto): `add_theme_stylebox_override("panel", UITheme.selected_tier_style(int(item.item_tier)))`

## scenes/ui/upgrades/upgrade_panel.gd

65 líneas; 1 anotaciones export; 0 uniforms; 15 candidatos.

### Ya expuesto en el editor

- L6: `@export var upgrades: Array[ItemUpgrade]`

### Candidatos / evidencia

- L4, `declaración` (constante): `const UPGRADE_CARD_SCENE = preload("res://scenes/ui/upgrades/upgrade_card.tscn")`
- L8, `declaración` (regla/valor): `var offer_level := 1`
- L9, `declaración` (regla/valor): `var completed_wave := 1`
- L10, `declaración` (regla/valor): `var reroll_count := 0`
- L16, `_ready` (literal adicional (revisión)): `for tier in range(1,5):`
- L17, `_ready` (texto): `var item = load("res://resources/items/upgrades/data/%s/upgrade_%s_%s.tres" % [stat, stat, tier])`
- L20, `_ready` (literal adicional (revisión)): `upgrades = upgrades.filter(func(item): return item.stat_id != "fire_tick_speed")`
- L21, `_ready` (texto): `$HBoxContainer/VBoxContainer/Label.add_theme_color_override("font_color", UITheme.palette.hud_text)`
- L27, `begin_wave_rewards` (literal adicional (revisión)): `completed_wave = maxi(1, wave)`
- L28, `begin_wave_rewards` (literal adicional (revisión)): `reroll_count = 0`
- L36, `try_reroll` (regla/valor): `reroll_count += 1`
- L45, `_process` (texto): `reroll_label.text = "refresh %d" % get_reroll_cost()`
- L47, `_process` (texto): `reroll_label.add_theme_color_override("font_color", UITheme.palette.disabled_text if reroll_button.disabled else UITheme.palette.text)`
- L53, `load_upgrades` (literal adicional (revisión)): `offer_level = maxi(1, character_level)`
- L54, `load_upgrades` (regla/valor): `if item_container.get_child_count() > 0:`

## scenes/units/enemies/charge_attack_behaviour.gd

60 líneas; 7 anotaciones export; 0 uniforms; 11 candidatos.

### Ya expuesto en el editor

- L5: `@export var enemy: Enemy`
- L6: `@export var anim_player: AnimationPlayer`
- L7: `@export var cooldown := 3.0`
- L8: `@export var preparation_duration := 0.8`
- L9: `@export var recovery_duration := 0.7`
- L10: `@export var charge_speed_multiplier := 5.0`
- L11: `@export var maximum_charge_distance := 650.0`

### Candidatos / evidencia

- L13, `declaración` (regla/valor): `var current_cooldown := 0.0`
- L14, `declaración` (regla/valor): `var state_time := 0.0`
- L16, `declaración` (regla/valor): `var charge_direction := Vector2.ZERO`
- L25, `_process` (regla/valor): `if enemy.get_movement_multiplier() <= 0.0 or enemy.launch_left > 0.0: return`
- L29, `_process` (regla/valor): `if current_cooldown <= 0.0: start_charge()`
- L32, `_process` (regla/valor): `if state_time <= 0.0:`
- L42, `_process` (visual): `if enemy.global_position.distance_to(charge_atk_position) <= 2.0: end_charge()`
- L45, `_process` (regla/valor): `if state_time <= 0.0:`
- L53, `start_charge` (literal adicional (revisión)): `state_time = maxf(0.05, preparation_duration)`
- L55, `start_charge` (literal adicional (revisión)): `anim_player.play("cherge", -1.0, 0.7 / state_time)`
- L59, `end_charge` (literal adicional (revisión)): `state_time = maxf(0.05, recovery_duration)`

## scenes/units/enemies/enemy.gd

315 líneas; 8 anotaciones export; 0 uniforms; 77 candidatos.

Hallazgos: UNIT-02.

### Ya expuesto en el editor

- L4: `@export var flock_push := 20.0`
- L5: `@export var displacement_immune := false`
- L6: `@export var targetable := true`
- L7: `@export var visual_scale := 1.0`
- L8: `@export_range(0.0, 1.0) var knockback_resistance := 0.0`
- L10: `@export_range(0.0,300.0,1.0) var pursuit_stop_distance := 60.0`
- L11: `@export_range(0.0, 90.0, 1.0) var airbourne_tilt_degrees := 35.0`
- L12: `@export_range(0.01, 1.0, 0.01) var airbourne_tilt_transition := 0.08`

### Candidatos / evidencia

- L15, `declaración` (regla/valor): `var desired_direction := Vector2.ZERO`
- L16, `declaración` (regla/valor): `var crowd_steering := Vector2.ZERO`
- L25, `declaración` (regla/valor): `var pins: Dictionary = {}`
- L26, `declaración` (visual): `var pinned_position := Vector2.ZERO`
- L27, `declaración` (regla/valor): `var slow_left := 0.0`
- L28, `declaración` (regla/valor): `var slow_factor := 1.0`
- L29, `declaración` (regla/valor): `var launch_left := 0.0`
- L30, `declaración` (regla/valor): `var launch_velocity := Vector2.ZERO`
- L32, `declaración` (regla/valor): `var _launch_duration := 0.0`
- L33, `declaración` (regla/valor): `var _tortilla_relaunches := 0`
- L34, `declaración` (regla/valor): `var _rest_visual_rotation := 0.0`
- L35, `declaración` (regla/valor): `var _airbourne_tilt := 0.0`
- L38, `_update_airbourne_tilt` (regla/valor): `var target := 0.0`
- L39, `_update_airbourne_tilt` (regla/valor): `if launch_left > 0.0 and absf(launch_velocity.x) > 0.001:`
- L42, `_update_airbourne_tilt` (literal adicional (revisión)): `var speed := deg_to_rad(airbourne_tilt_degrees) / maxf(0.01, airbourne_tilt_transition)`
- L45, `_update_airbourne_tilt` (regla/valor): `visuals.rotation = _rest_visual_rotation + _airbourne_tilt`
- L62, `get_movement_multiplier` (regla/valor): `return 0.0 if not pins.is_empty() else (slow_factor if slow_left > 0.0 else 1.0) * status_movement_multiplier`
- L64, `apply_slow` (literal adicional (revisión)): `func apply_slow(factor: float, duration: float, _text_duration: float = 1.3, _text_color: Color = Color("86a9be"), _text_value: String = "Slowed") -> void:`
- L66, `apply_slow` (regla/valor): `if duration <= 0.0 or factor >= 1.0: return`
- L67, `apply_slow` (regla/valor): `slow_factor = minf(slow_factor if slow_left > 0.0 else 1.0, clampf(factor, 0.0, 1.0))`
- L75, `launch_from` (literal adicional (revisión)): `launch_velocity = direction * hitbox.launch_speed * (1.0 - knockback_resistance)`
- L76, `launch_from` (regla/valor): `launch_left = hitbox.launch_duration if launch_velocity.length_squared() > 1.0 else 0.0`
- L78, `launch_from` (literal adicional (revisión)): `_tortilla_relaunches = 0`
- L81, `launch_from` (literal adicional (revisión)): `launch_hitbox.collision_layer = 0`
- L82, `launch_from` (literal adicional (revisión)): `launch_hitbox.collision_mask = 0`
- L85, `launch_from` (regla/valor): `var collision_damage := hitbox.launch_damage if hitbox.launch_damage > 0.0 else hitbox.base_damage`
- L87, `launch_from` (regla/valor): `collision_damage *= 1.0 + hitbox.source.passive_items.airbourne_collision_damage_percent / 100.0`
- L88, `launch_from` (literal adicional (revisión)): `launch_hitbox.setup(collision_damage, false, 0.0, hitbox.source)`
- L98, `_on_launch_collision` (regla/valor): `if not is_instance_valid(items) or items.airbourne_explosion_damage_percent <= 0.0: return`
- L102, `_on_launch_collision` (literal adicional (revisión)): `config.explosion_damage_multiplier = items.airbourne_explosion_damage_percent / 100.0`
- L103, `_on_launch_collision` (literal adicional (revisión)): `config.explosion_visual_duration = 0.18`
- L105, `_on_launch_collision` (texto): `var blast = load("res://scenes/projectiles/ranged_area_effect.gd").new()`
- L117, `_move_launched` (visual): `var radius := 29.0 * visual_scale * absf(global_scale.x)`
- L120, `_move_launched` (literal adicional (revisión)): `shape.height = travel.length() + radius * 2.0`
- L123, `_move_launched` (literal adicional (revisión)): `query.transform = Transform2D(travel.angle() - PI / 2.0, previous + travel * 0.5)`
- L124, `_move_launched` (literal adicional (revisión)): `query.collision_mask = 2`
- L128, `_move_launched` (literal adicional (revisión)): `for result in get_world_2d().direct_space_state.intersect_shape(query, 32):`
- L130, `_move_launched` (regla/valor): `if other is Enemy and other != self and not other.is_retiring and other.health_component.current_health > 0.0:`
- L132, `_move_launched` (literal adicional (revisión)): `launch_left = maxf(0.0, launch_left - delta)`
- L133, `_move_launched` (regla/valor): `if launch_left <= 0.0:`
- L148, `_ready` (literal adicional (revisión)): `vision_area.set_deferred("collision_mask",0)`
- L153, `_ready` (literal adicional (revisión)): `contact.setup(stats.damage, false, 0.0, self)`
- L157, `_ready` (literal adicional (revisión)): `contact.set_deferred("collision_mask",0)`
- L161, `_process` (regla/valor): `if is_retiring or health_component.current_health <= 0.0: return`
- L163, `_process` (literal adicional (revisión)): `slow_left = maxf(0.0, slow_left - delta)`
- L165, `_process` (regla/valor): `if movement_multiplier <= 0.0:`
- L168, `_process` (regla/valor): `if launch_left > 0.0:`
- L179, `_process` (regla/valor): `if not movement_override_enabled and (not player_valid or offset.length_squared()<=stop_distance*stop_distance) and knockback_power<=0.0: return`
- L180, `_process` (regla/valor): `var direction := Vector2.ZERO`
- L183, `_process` (regla/valor): `if targetable: direction = (direction+crowd_steering).limit_length(1.0)`
- L185, `_process` (regla/valor): `if not movement_override_enabled and knockback_power<=0.0:`
- L193, `_process` (visual): `var facing_scale := Vector2(-0.5,0.5)*visual_scale if next_position.x<player_position.x else Vector2(0.5,0.5)*visual_scale`
- L194, `_process` (visual): `if visuals.scale != facing_scale: visuals.scale = facing_scale`
- L198, `_apply_size` (visual): `visuals.scale = Vector2.ONE * 0.5 * visual_scale`
- L209, `_apply_size` (regla/valor): `if collision.shape is CircleShape2D:`
- L213, `_apply_size` (literal adicional (revisión)): `(body.shape as CircleShape2D).radius = 29.0 * visual_scale`
- L218, `get_move_direction` (regla/valor): `return Vector2.ZERO`
- L221, `get_move_direction` (regla/valor): `if targetable: direction = (direction+crowd_steering).limit_length(1.0)`
- L228, `apply_knockback` (literal adicional (revisión)): `knockback_power = maxf(0.0, knock_pow) * (1.0 - knockback_resistance)`
- L233, `reset_knockback` (literal adicional (revisión)): `knockback_power = 0`
- L240, `update_rotation` (visual): `var facing_scale := Vector2(-.5, .5) * visual_scale if moving_right else Vector2(.5, .5) * visual_scale`
- L241, `update_rotation` (visual): `if visuals.scale != facing_scale: visuals.scale = facing_scale`
- L245, `can_move_towards_player` (literal adicional (revisión)): `global_position.distance_squared_to(Global.nearest_player(global_position).global_position) > pow(pursuit_stop_distance * visual_scale,2)`
- L252, `destroy_enemy` (literal adicional (revisión)): `health_component.current_health = 0.0`
- L269, `destroy_enemy` (texto): `retirement.tween_property(self, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)`
- L271, `destroy_enemy` (texto): `load("res://effects/arena_bursts.gd").emit_at(self, global_position)`
- L281, `_on_hurtbox_component_on_damage` (regla/valor): `if hitbox.launch_on_hit and health_component.current_health > 0.0: launch_from(hitbox)`
- L282, `_on_hurtbox_component_on_damage` (regla/valor): `var impact_direction := Vector2.RIGHT`
- L285, `_on_hurtbox_component_on_damage` (regla/valor): `if impact_direction.is_zero_approx(): impact_direction = Vector2.RIGHT`
- L287, `_on_hurtbox_component_on_damage` (regla/valor): `if hitbox.knockback_power > 0 and is_instance_valid(hitbox.source):`
- L296, `_try_tortilla_relaunch` (literal adicional (revisión)): `func _try_tortilla_relaunch(test_roll: float = -1.0) -> bool:`
- L297, `_try_tortilla_relaunch` (regla/valor): `if launch_left > 0.0 or is_retiring or health_component.current_health <= 0.0: return false`
- L300, `_try_tortilla_relaunch` (regla/valor): `if not is_instance_valid(source_player) or source_player.is_queued_for_deletion() or source_player.health_component.current_health <= 0.0: return false`
- L302, `_try_tortilla_relaunch` (regla/valor): `if _tortilla_relaunches >= config.maximum or config.chance <= 0.0: return false`
- L305, `_try_tortilla_relaunch` (regla/valor): `if next_velocity.length_squared() <= 1.0 or next_duration <= 0.0: return false`
- L306, `_try_tortilla_relaunch` (regla/valor): `var success: bool = Global.get_chance_succes(config.chance) if test_roll < 0.0 else test_roll < config.chance`
- L308, `_try_tortilla_relaunch` (regla/valor): `_tortilla_relaunches += 1`

## scenes/units/enemies/fueguito.gd

37 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L9, `_ready` (literal adicional (revisión)): `contact_hitbox.setup(stats.damage, false, 0.0, self)`
- L10, `_ready` (texto): `contact_hitbox.status_effects.append(load("res://resources/statuses/fueguito_fire.tres"))`
- L15, `_process` (visual): `anim_player.speed_scale = 0.0 if Global.game_paused else 1.0`

## scenes/units/enemies/reward_roamer.gd

105 líneas; 12 anotaciones export; 0 uniforms; 32 candidatos.

Hallazgos: UNIT-03, UNIT-04, UNIT-05.

### Ya expuesto en el editor

- L4: `@export var reward_kind := RewardKind.YOLKS`
- L5: `@export_range(0,1000,1) var minimum_yolks := 10`
- L6: `@export_range(0,1000,1) var maximum_yolks := 25`
- L7: `@export_group("Yolk burst")`
- L8: `@export var burst_min_distance := 150.0`
- L9: `@export var burst_max_distance := 320.0`
- L10: `@export_range(0.1,1.5,0.05) var burst_flight_duration := 0.5`
- L11: `@export_group("Movement and animation")`
- L12: `@export_range(0.2,5.0,0.05) var bounce_period := 1.2`
- L13: `@export var bounce_height := 52.0`
- L14: `@export var wall_padding := 24.0`
- L15: `@export_flags_2d_physics var wall_mask := 1`

### Candidatos / evidencia

- L16, `declaración` (regla/valor): `var travel_direction := Vector2.RIGHT`
- L17, `declaración` (regla/valor): `var animation_clock := 0.0`
- L18, `declaración` (visual): `var _texture_scale := 1.0`
- L19, `declaración` (regla/valor): `var _draw_half := Vector2(70,88)`
- L20, `declaración` (visual): `var _shadow_scale := Vector2.ONE`
- L25, `_ready` (literal adicional (revisión)): `flock_push = 0.0`
- L32, `_ready` (literal adicional (revisión)): `_texture_scale = 176.0 / maxf(1.0,used.size.y)`
- L33, `_ready` (literal adicional (revisión)): `sprite.offset = sprite.texture.get_size()*0.5-Vector2(used.get_center())`
- L34, `_ready` (literal adicional (revisión)): `_draw_half = Vector2(used.size)*_texture_scale*0.5`
- L36, `_ready` (literal adicional (revisión)): `_animate(0.0)`
- L39, `roll_yolk_reward` (regla/valor): `if reward_kind!=RewardKind.YOLKS: return 0`
- L40, `roll_yolk_reward` (regla/valor): `return randi_range(minimum_yolks,maxi(minimum_yolks,maximum_yolks))`
- L43, `update_rotation` (visual): `visuals.scale = Vector2.ONE*0.5*visual_scale`
- L54, `_inside` (regla/valor): `elif not Rect2(-1000,-500,2000,985).has_point(sample): return false`
- L60, `_wall_between` (regla/valor): `return not get_world_2d().direct_space_state.intersect_ray(ray).is_empty()`
- L63, `choose_heading` (literal adicional (revisión)): `for attempt in 48:`
- L64, `choose_heading` (regla/valor): `var candidate := Vector2.from_angle(randf()*TAU)`
- L65, `choose_heading` (literal adicional (revisión)): `var probe := global_position+candidate*maxf(60.0,wall_padding*2.0)`
- L70, `choose_heading` (regla/valor): `var center := arena_environment.movement_bounds.get_center() if arena_environment else Vector2.ZERO`
- L75, `_process` (regla/valor): `if Global.game_paused or is_retiring or health_component.current_health<=0.0: return`
- L76, `_process` (regla/valor): `var moving := can_move and get_movement_multiplier()>0.0 and launch_left<=0.0`
- L89, `_animate` (literal adicional (revisión)): `var phase := fposmod(animation_clock/maxf(0.2,bounce_period),1.0)`
- L93, `_animate` (literal adicional (revisión)): `var contact := pow(absf(cos(TAU*phase)),14.0)`
- L94, `_animate` (regla/valor): `var stretch := Vector2(1.0+0.12*contact,1.0-0.12*contact)`
- L95, `_animate` (regla/valor): `sprite.rotation = turn`
- L96, `_animate` (visual): `sprite.scale = Vector2.ONE*_texture_scale*stretch`
- L99, `_animate` (visual): `sprite.position = Vector2(0,-extent*stretch.y-height)`
- L100, `_animate` (visual): `$Visuals/Shadow.scale = _shadow_scale*(1.0-0.3*height/maxf(1,bounce_height))`
- L102, `_animate` (literal adicional (revisión)): `var pulse := sin(animation_clock*6.0)`
- L103, `_animate` (regla/valor): `sprite.rotation = 0.025*pulse`
- L104, `_animate` (visual): `sprite.scale = Vector2(1.0+0.035*pulse,1.0-0.035*pulse)*_texture_scale`
- L105, `_animate` (visual): `sprite.position = Vector2(0,-_draw_half.y*(1.0-0.035*pulse))`

## scenes/units/enemies/shooting_behaviour.gd

83 líneas; 15 anotaciones export; 0 uniforms; 15 candidatos.

### Ya expuesto en el editor

- L5: `@export var enemy: Enemy`
- L6: `@export var fire_pos: Marker2D`
- L7: `@export var cooldown := 2.0`
- L8: `@export_range(1, 20) var projectile_count := 1`
- L9: `@export var arc_angle := 45.0`
- L10: `@export var projectile_scene: PackedScene`
- L11: `@export var projectile_speed := 400.0`
- L12: `@export var projectile_range := 700.0`
- L13: `@export var projectile_damage := 3.0`
- L14: `@export var projectile_damage_per_wave := 0.4`
- L15: `@export var preferred_min_distance := 320.0`
- L16: `@export var preferred_max_distance := 400.0`
- L17: `@export var minimum_firing_distance := 180.0`
- L18: `@export var preparation_duration := 0.5`
- L19: `@export var recovery_duration := 0.35`

### Candidatos / evidencia

- L20, `declaración` (regla/valor): `var damage_multiplier := 1.0`
- L21, `declaración` (regla/valor): `var wave_offset := 0`
- L23, `declaración` (regla/valor): `var current_cooldown := 0.0`
- L24, `declaración` (regla/valor): `var state_time := 0.0`
- L32, `_process` (regla/valor): `if enemy.get_movement_multiplier() <= 0.0 or enemy.launch_left > 0.0: return`
- L38, `_process` (regla/valor): `enemy.desired_direction = -direction if distance < preferred_min_distance else direction if distance > preferred_max_distance else Vector2.ZERO`
- L40, `_process` (visual): `if current_cooldown <= 0.0 and in_firing_position(distance):`
- L42, `_process` (literal adicional (revisión)): `state_time = maxf(0.05, preparation_duration)`
- L44, `_process` (literal adicional (revisión)): `enemy.sprite.modulate = Color(1.0, 0.8, 0.55)`
- L50, `_process` (regla/valor): `elif state_time <= 0.0:`
- L53, `_process` (literal adicional (revisión)): `state_time = maxf(0.05, recovery_duration)`
- L61, `_process` (regla/valor): `if state_time <= 0.0: finish_shot()`
- L73, `shoot` (regla/valor): `var start_angle := -arc_angle / 2.0 if projectile_count > 1 else 0.0`
- L74, `shoot` (regla/valor): `var step_angle := arc_angle / float(projectile_count - 1) if projectile_count > 1 else 0.0`
- L80, `shoot` (literal adicional (revisión)): `projectile.setup_projectile(velocity, (projectile_damage + projectile_damage_per_wave * wave_offset) * damage_multiplier, false, 0, enemy, projectile_range)`

## scenes/units/players/passive_items.gd

395 líneas; 0 anotaciones export; 0 uniforms; 147 candidatos.

Hallazgos: ITEM-01, ITEM-02.

### Candidatos / evidencia

- L4, `declaración` (regla/valor): `var counts: Dictionary = {}`
- L5, `declaración` (regla/valor): `var owned_records: Array[Dictionary] = []`
- L6, `declaración` (regla/valor): `var golden_yolks := 0`
- L7, `declaración` (regla/valor): `var breading_charges := 0`
- L8, `declaración` (regla/valor): `var shell_uses := 0`
- L9, `declaración` (regla/valor): `var _oil_interval_total := 0.0`
- L10, `declaración` (regla/valor): `var _oil_duration_total := 0.0`
- L11, `declaración` (regla/valor): `var shell_invulnerability := 0.0`
- L13, `declaración` (regla/valor): `var kills := 0`
- L16, `declaración` (regla/valor): `var fire_spread_chance := 0.0`
- L17, `declaración` (regla/valor): `var fire_spread_radius := 80.0`
- L18, `declaración` (regla/valor): `var yolk_heal_chance := 0.0`
- L19, `declaración` (regla/valor): `var yolk_heal_amount := 0.1`
- L20, `declaración` (regla/valor): `var yolk_magnet_chance := 0.0`
- L22, `declaración` (regla/valor): `var debug_yolk_magnet_chance := -1.0`
- L23, `declaración` (regla/valor): `var controlled_damage_percent := 0.0`
- L24, `declaración` (regla/valor): `var airbourne_collision_damage_percent := 0.0`
- L25, `declaración` (regla/valor): `var airbourne_explosion_damage_percent := 0.0`
- L26, `declaración` (regla/valor): `var airbourne_explosion_radius := 60.0`
- L27, `declaración` (regla/valor): `var burning_regen_total := 0.0`
- L28, `declaración` (regla/valor): `var flambe_damage_per_enemy := 0.0`
- L29, `declaración` (regla/valor): `var level_regen_bonus := 0.0`
- L30, `declaración` (regla/valor): `var electric_slow_strength := 0.0`
- L31, `declaración` (regla/valor): `var electric_slow_duration := 0.0`
- L34, `declaración` (regla/valor): `var last_bite_dash_multiplier := 1.0`
- L36, `declaración` (constante): `const PRIMARY = ["health", "hp_regen", "life_steal", "damage_percent", "melee_damage", "ranged_damage", "effects", "weapon_range", "attack_speed", "critical_chance", "armor", "block_chance", "speed", "luck", "harvesting"]`
- L37, `declaración` (regla/valor): `var slip_left := 0.0`
- L38, `declaración` (regla/valor): `var _slip_bonus := 0.0`
- L41, `count` (regla/valor): `return int(counts.get(key, 0))`
- L43, `refresh_last_bite` (literal adicional (revisión)): `func refresh_last_bite(_current: float = 0.0, _maximum: float = 0.0) -> void:`
- L45, `refresh_last_bite` (regla/valor): `var push_percent := 0.0`
- L46, `refresh_last_bite` (regla/valor): `var dash_reduction := 0.0`
- L50, `refresh_last_bite` (literal adicional (revisión)): `if item.effect_key != "last_bite": continue`
- L51, `refresh_last_bite` (regla/valor): `if health.current_health > 0.0 and health.current_health < health.max_health * item.last_bite_health_threshold:`
- L55, `refresh_last_bite` (literal adicional (revisión)): `player.stats.conditional_push_multiplier = maxf(0.0, 1.0 + push_percent / 100.0)`
- L56, `refresh_last_bite` (literal adicional (revisión)): `last_bite_dash_multiplier = maxf(0.0, 1.0 - dash_reduction)`
- L63, `acquire` (literal adicional (revisión)): `counts[key] = count(key) + 1`
- L66, `acquire` (texto): `var result: Dictionary = load("res://resources/items/ayahuasca.gd").apply(player, item)`
- L69, `acquire` (texto): `"golden_yolk": golden_yolks += 1`
- L70, `acquire` (texto): `"breading": breading_charges += 1`
- L92, `acquire` (literal adicional (revisión)): `yolk_magnet_chance = minf(1.0, yolk_magnet_chance + item.proc_chance)`
- L94, `acquire` (literal adicional (revisión)): `yolk_heal_chance = minf(1.0, yolk_heal_chance + item.proc_chance)`
- L97, `acquire` (literal adicional (revisión)): `fire_spread_chance = minf(1.0, fire_spread_chance + item.proc_chance)`
- L101, `acquire` (literal adicional (revisión)): `var config: StatusEffect = item.on_hit_effects[0]`
- L104, `acquire` (literal adicional (revisión)): `alcohol_fire.chance = 0.0`
- L106, `acquire` (literal adicional (revisión)): `alcohol_fire.chance = minf(1.0, alcohol_fire.chance + config.chance)`
- L111, `acquire` (regla/valor): `player.stats.energy_shakes += 1`
- L112, `acquire` (literal adicional (revisión)): `player.stats.apply_stat_change("speed", 0)`
- L114, `acquire` (literal adicional (revisión)): `"refrito": player.stats.apply_stat_change("bounces", 1)`
- L117, `acquire` (literal adicional (revisión)): `apron_conversion.source_stat = "armor"`
- L118, `acquire` (literal adicional (revisión)): `apron_conversion.target_stat = "health"`
- L119, `acquire` (literal adicional (revisión)): `apron_conversion.bonus_amount = 2.0`
- L121, `acquire` (literal adicional (revisión)): `player.stats.apply_stat_change("health", 0)`
- L122, `acquire` (literal adicional (revisión)): `"grocery": redistribute(50, 40)`
- L126, `acquire` (texto): `var stage_ids := {"stage_pan":"nonstick_pan", "stage_pot":"cooking_pot", "stage_oven":"oven_tray", "stage_wok":"deep_wok"}`
- L127, `acquire` (texto): `var stage = load("res://resources/environments/stages/%s.tres" % stage_ids[key])`
- L128, `acquire` (literal adicional (revisión)): `var wave: int = arena.spawner.wave_index + 1`
- L133, `acquire` (literal adicional (revisión)): `player.stats.apply_stat_change("effects", 0)`
- L135, `acquire` (regla/valor): `var deltas: Dictionary = {}`
- L142, `acquire` (literal adicional (revisión)): `if key == "oil_bath":`
- L148, `acquire` (literal adicional (revisión)): `player.health_component.max_health = maxf(1.0, player.stats.health)`
- L154, `begin_wave` (texto): `mushroom_runtime = load("res://resources/items/unknown_mushroom.gd").new()`
- L159, `begin_wave` (literal adicional (revisión)): `shell_uses = 0`
- L160, `begin_wave` (literal adicional (revisión)): `shell_invulnerability = 0.0`
- L162, `begin_wave` (literal adicional (revisión)): `player.stats.set_temporary_stat_bonus("thermal_glove", "hp_regen", 0.0)`
- L165, `on_level_gained` (texto): `if level_regen_bonus > 0.0: player.stats.apply_stat_change("hp_regen", level_regen_bonus)`
- L168, `refresh_burning_regen` (regla/valor): `var bonus := burning_regen_total if player.has_status(Unit.State.BURNING) else 0.0`
- L172, `on_yolks_collected` (regla/valor): `if Global.game_paused or amount <= 0 or yolk_heal_chance <= 0.0: return`
- L174, `on_yolks_collected` (regla/valor): `if health.current_health <= 0.0 or health.current_health >= health.max_health: return`
- L175, `on_yolks_collected` (regla/valor): `var successes := 0`
- L177, `on_yolks_collected` (regla/valor): `if Global.get_chance_succes(yolk_heal_chance): successes += 1`
- L178, `on_yolks_collected` (regla/valor): `if successes == 0: return`
- L182, `on_yolks_collected` (regla/valor): `if healed > 0.0: Global.on_create_heal_text.emit(player, healed)`
- L185, `should_attract_spawned_yolk` (regla/valor): `var chance := debug_yolk_magnet_chance if debug_yolk_magnet_chance>=0 else yolk_magnet_chance`
- L186, `should_attract_spawned_yolk` (regla/valor): `return chance > 0.0 and player.health_component.current_health > 0.0 and Global.get_chance_succes(chance)`
- L189, `on_block` (texto): `if count("slippery_shell") == 0: return`
- L190, `on_block` (regla/valor): `if slip_left <= 0.0:`
- L191, `on_block` (literal adicional (revisión)): `_slip_bonus = player.stats.unmodified_stat("speed") * 0.2 * maximum_power("slippery_shell")`
- L193, `on_block` (literal adicional (revisión)): `slip_left = 3.0 * maximum_power("slippery_shell")`
- L196, `_clear_slip` (texto): `if _slip_bonus != 0.0: player.stats.apply_stat_change("speed", -_slip_bonus)`
- L197, `_clear_slip` (literal adicional (revisión)): `_slip_bonus = 0.0`
- L198, `_clear_slip` (literal adicional (revisión)): `slip_left = 0.0`
- L201, `_process` (regla/valor): `if burning_regen_total > 0.0: refresh_burning_regen()`
- L202, `_process` (literal adicional (revisión)): `shell_invulnerability = maxf(0.0, shell_invulnerability - delta)`
- L203, `_process` (regla/valor): `if slip_left > 0.0:`
- L205, `_process` (regla/valor): `if slip_left <= 0.0: _clear_slip()`
- L208, `prevent_lethal` (texto): `if shell_uses >= floori(maximum_power("extra_shell") + 0.00001): return false`
- L209, `prevent_lethal` (regla/valor): `shell_uses += 1`
- L211, `prevent_lethal` (literal adicional (revisión)): `shell_invulnerability = 1.0`
- L212, `prevent_lethal` (literal adicional (revisión)): `player.hit_invulnerability_left = maxf(player.hit_invulnerability_left, 1.0)`
- L218, `on_status_applied` (texto): `if kind == StatusEffect.Kind.FIRE and count("reheated") > 0:`
- L219, `on_status_applied` (literal adicional (revisión)): `player.stats.apply_stat_change("attack_speed", 5.0 * power("reheated"))`
- L220, `on_status_applied` (texto): `if kind == StatusEffect.Kind.ELECTRICITY and count("overload") > 0:`
- L221, `on_status_applied` (literal adicional (revisión)): `player.stats.apply_stat_change("damage_percent", 5.0 * power("overload"))`
- L228, `redistribute` (literal adicional (revisión)): `player.stats.apply_stat_change(others.pick_random(), -1.0)`
- L234, `finish_wave` (texto): `if record.item.effect_key == "lunchbox": redistribute(5 * record.item.golden_multiplier, 3 * record.item.golden_penalty_multiplier)`
- L237, `enemy_killed` (texto): `if not enemy.last_hit_grants_rewards or enemy.get_meta("stage_hazard", false) or count("printer") == 0: return`
- L238, `enemy_killed` (regla/valor): `kills += 1`
- L239, `enemy_killed` (texto): `if kills % 100 != 0 or count("printer") == 0: return`
- L240, `enemy_killed` (regla/valor): `var candidates: Array = []`
- L241, `enemy_killed` (texto): `for item in load("res://resources/items/passives/catalogue.gd").items():`
- L242, `enemy_killed` (regla/valor): `if item.item_tier == Global.UpgradeTier.COMMON and count(item.effect_key) > 0: candidates.append(item)`
- L254, `power` (regla/valor): `var total := 0.0`
- L260, `discrete_power` (regla/valor): `var total := 0`
- L263, `discrete_power` (literal adicional (revisión)): `total += maxi(1, floori(record.item.golden_multiplier + 0.00001))`
- L267, `weapon_slot_bonus` (regla/valor): `var total := 0`
- L269, `weapon_slot_bonus` (texto): `if record.item.effect_key == "extra_slot": total += 2 if record.item.golden_perfect else 1`
- L279, `replace_owned` (regla/valor): `var adjustments: Dictionary = {}`
- L280, `replace_owned` (regla/valor): `var new_deltas: Dictionary = {}`
- L281, `replace_owned` (regla/valor): `var gain_factor := replacement.golden_multiplier / old.golden_multiplier if replacement else 0.0`
- L282, `replace_owned` (regla/valor): `var loss_factor := replacement.golden_penalty_multiplier / old.golden_penalty_multiplier if replacement and old.golden_penalty_multiplier > 0.0 else 0.0`
- L285, `replace_owned` (regla/valor): `var updated := previous * (gain_factor if previous > 0.0 else loss_factor)`
- L287, `replace_owned` (texto): `if stat_id in ["bounces", "piercing"]: updated = floorf(updated + 0.00001)`
- L296, `replace_owned` (literal adicional (revisión)): `if old.effect_key != "alcohol": player.stats.attack_effects.append_array(replacement.on_hit_effects)`
- L297, `replace_owned` (regla/valor): `if record.conversion: record.conversion.bonus_amount = 2.0 * replacement.golden_multiplier`
- L299, `replace_owned` (literal adicional (revisión)): `counts[old.effect_key] = maxi(0, count(old.effect_key) - 1)`
- L305, `_rebuild_continuous_effects` (literal adicional (revisión)): `fire_spread_chance = 0.0`
- L306, `_rebuild_continuous_effects` (literal adicional (revisión)): `fire_spread_radius = 0.0`
- L307, `_rebuild_continuous_effects` (literal adicional (revisión)): `yolk_heal_chance = 0.0`
- L308, `_rebuild_continuous_effects` (literal adicional (revisión)): `yolk_heal_amount = 0.0`
- L309, `_rebuild_continuous_effects` (literal adicional (revisión)): `yolk_magnet_chance = 0.0`
- L310, `_rebuild_continuous_effects` (literal adicional (revisión)): `controlled_damage_percent = 0.0`
- L311, `_rebuild_continuous_effects` (literal adicional (revisión)): `airbourne_collision_damage_percent = 0.0`
- L312, `_rebuild_continuous_effects` (literal adicional (revisión)): `airbourne_explosion_damage_percent = 0.0`
- L313, `_rebuild_continuous_effects` (literal adicional (revisión)): `airbourne_explosion_radius = 0.0`
- L314, `_rebuild_continuous_effects` (literal adicional (revisión)): `burning_regen_total = 0.0`
- L315, `_rebuild_continuous_effects` (literal adicional (revisión)): `flambe_damage_per_enemy = 0.0`
- L316, `_rebuild_continuous_effects` (literal adicional (revisión)): `level_regen_bonus = 0.0`
- L317, `_rebuild_continuous_effects` (literal adicional (revisión)): `electric_slow_strength = 0.0`
- L318, `_rebuild_continuous_effects` (literal adicional (revisión)): `electric_slow_duration = 0.0`
- L320, `_rebuild_continuous_effects` (regla/valor): `var interval := 0.0`
- L321, `_rebuild_continuous_effects` (regla/valor): `var duration := 0.0`
- L322, `_rebuild_continuous_effects` (regla/valor): `var alcohol_chance := 0.0`
- L349, `_rebuild_continuous_effects` (regla/valor): `if not item.on_hit_effects.is_empty(): alcohol_chance += item.on_hit_effects[0].chance`
- L351, `_rebuild_continuous_effects` (literal adicional (revisión)): `alcohol_fire.chance = minf(1.0, alcohol_chance)`
- L352, `_rebuild_continuous_effects` (regla/valor): `if alcohol_chance <= 0.0:`
- L360, `_rebuild_continuous_effects` (literal adicional (revisión)): `player.stats.infernal_reduction = count("reduction") > 0`
- L361, `_rebuild_continuous_effects` (literal adicional (revisión)): `player.stats.infernal_reduction_multiplier = maxf(1.0, maximum_power("reduction"))`
- L368, `penalty_power` (regla/valor): `var total := 0.0`
- L374, `maximum_power` (regla/valor): `var highest := 0.0`
- L380, `get_tortilla_relaunch` (regla/valor): `var chance := 0.0`
- L381, `get_tortilla_relaunch` (regla/valor): `var speed_multiplier := 0.0`
- L382, `get_tortilla_relaunch` (regla/valor): `var duration_multiplier := 0.0`
- L383, `get_tortilla_relaunch` (regla/valor): `var maximum := 0`
- L386, `get_tortilla_relaunch` (literal adicional (revisión)): `if item.effect_key != "tortilla_flip": continue`
- L391, `get_tortilla_relaunch` (texto): `return {"chance": minf(1.0, chance), "speed_multiplier": speed_multiplier, "duration_multiplier": duration_multiplier, "maximum": maximum}`
- L394, `refresh_flambe_damage` (texto): `var amount: float = flambe_damage_per_enemy * load("res://effects/status_controller.gd").burning_enemy_count`

## scenes/units/players/player.gd

250 líneas; 3 anotaciones export; 0 uniforms; 62 candidatos.

Hallazgos: COM-03, COM-04, COM-05, ITEM-04.

### Ya expuesto en el editor

- L12: `@export var dash_duration := .5`
- L13: `@export var dash_speed_multi := 2.5`
- L14: `@export var dash_cooldown := 2.0`

### Candidatos / evidencia

- L8, `get_weapon_limit` (regla/valor): `return Global.MAX_EQUIPPED_WEAPONS + (passive_items.weapon_slot_bonus() if is_instance_valid(passive_items) else 0)`
- L24, `get_weapon_limit` (constante): `const HIT_INVULNERABILITY := 0.5`
- L25, `get_weapon_limit` (constante): `const LIFE_STEAL_INTERVAL := 0.1`
- L26, `get_weapon_limit` (constante): `const RECOVERY_STEP := 0.1`
- L27, `get_weapon_limit` (constante): `const REGEN_PER_POINT_PER_SECOND := 0.1`
- L28, `get_weapon_limit` (regla/valor): `var _regen_credit := 0.0`
- L29, `get_weapon_limit` (regla/valor): `var hit_invulnerability_left := 0.0`
- L30, `get_weapon_limit` (regla/valor): `var life_steal_cooldown := 0.0`
- L32, `get_weapon_limit` (regla/valor): `var current_weapons: Array[Weapon] = []`
- L34, `get_weapon_limit` (regla/valor): `var health_drain_per_second := 0.0`
- L35, `get_weapon_limit` (regla/valor): `var max_health_drain_percent_per_second := 0.0`
- L36, `get_weapon_limit` (regla/valor): `var _drain_elapsed := 0.0`
- L37, `get_weapon_limit` (regla/valor): `var _effective_dash_cooldown := 2.0`
- L40, `get_dash_cooldown` (texto): `return maxf(0.05, maxf(0.05, dash_cooldown - passive_items.power("guarana")) * passive_items.last_bite_dash_multiplier)`
- L47, `refresh_dash_cooldown` (literal adicional (revisión)): `dash_cooldown_timer.start(maxf(0.00001, dash_cooldown_timer.time_left * updated / _effective_dash_cooldown))`
- L51, `refresh_equipment_modifiers` (regla/valor): `var combined: Dictionary = {}`
- L52, `refresh_equipment_modifiers` (literal adicional (revisión)): `health_drain_per_second = 0.0`
- L53, `refresh_equipment_modifiers` (literal adicional (revisión)): `max_health_drain_percent_per_second = 0.0`
- L56, `refresh_equipment_modifiers` (texto): `var chili_factor: float = 1.0 + 0.1 * (passive_items.power("wasabi") if is_instance_valid(passive_items) and equipped.data.has_tag(ItemWeapon.Tag.CHILI) else 0)`
- L57, `refresh_equipment_modifiers` (texto): `var chili_penalty: float = 1.0 + 0.1 * (passive_items.penalty_power("wasabi") if is_instance_valid(passive_items) and equipped.data.has_tag(ItemWeapon.Tag.CHILI) else 0)`
- L59, `refresh_equipment_modifiers` (regla/valor): `combined[key] = float(combined.get(key, 0.0)) + float(equipped.data.final_stat_modifiers[key]) * (chili_factor if float(equipped.data.final_stat_modifiers[key]) > 0.0 else chili_penalty)`
- L62, `refresh_equipment_modifiers` (regla/valor): `if health_drain_per_second <= 0.0 and max_health_drain_percent_per_second <= 0.0: _drain_elapsed = 0.0`
- L63, `refresh_equipment_modifiers` (literal adicional (revisión)): `stats.chili_crit_enabled = is_instance_valid(passive_items) and passive_items.count("pepper") > 0`
- L70, `_ready` (texto): `passive_items = load("res://scenes/units/players/passive_items.gd").new()`
- L81, `_ready` (texto): `shadow.material.set_shader_parameter("outline_color", trail.default_color)`
- L84, `_sync_max_health` (literal adicional (revisión)): `health_component.max_health = maxf(1.0, stats.health)`
- L91, `_process` (regla/valor): `if (health_drain_per_second > 0.0 or max_health_drain_percent_per_second > 0.0) and health_component.current_health > 0.0:`
- L93, `_process` (literal adicional (revisión)): `while _drain_elapsed >= 1.0 and health_component.current_health > 0.0:`
- L94, `_process` (literal adicional (revisión)): `_drain_elapsed -= 1.0`
- L96, `_process` (literal adicional (revisión)): `health_component.take_damage(health_drain_per_second+health_component.max_health*max_health_drain_percent_per_second/100.0)`
- L97, `_process` (literal adicional (revisión)): `hit_invulnerability_left = maxf(0.0, hit_invulnerability_left - delta)`
- L98, `_process` (literal adicional (revisión)): `life_steal_cooldown = maxf(0.0, life_steal_cooldown - delta)`
- L110, `_process` (literal adicional (revisión)): `position.x = clamp(position.x, -1000, 1000)`
- L111, `_process` (literal adicional (revisión)): `position.y = clamp(position.y, -500, 485)`
- L136, `start_dash` (literal adicional (revisión)): `visuals.modulate.a = .9`
- L139, `start_dash` (texto): `shadow.material.set_shader_parameter("outline_color", Color(.0,.0,.0,.0))`
- L150, `update_animations` (regla/valor): `if move_dir.length() > 0:`
- L157, `update_rotation` (regla/valor): `if move_dir == Vector2.ZERO:`
- L160, `update_rotation` (regla/valor): `if move_dir.x >= .1:`
- L161, `update_rotation` (visual): `visuals.scale = Vector2(-.5, .5)`
- L162, `update_rotation` (regla/valor): `elif move_dir.x < 0:`
- L163, `update_rotation` (visual): `visuals.scale = Vector2(.5, .5)`
- L166, `prepare_for_new_wave` (literal adicional (revisión)): `_regen_credit = 0.0`
- L168, `prepare_for_new_wave` (literal adicional (revisión)): `_drain_elapsed = 0.0`
- L174, `prepare_for_new_wave` (literal adicional (revisión)): `hit_invulnerability_left = 0.0`
- L175, `prepare_for_new_wave` (literal adicional (revisión)): `life_steal_cooldown = 0.0`
- L183, `prepare_for_new_wave` (literal adicional (revisión)): `visuals.modulate.a = 1.0`
- L185, `prepare_for_new_wave` (texto): `shadow.material.set_shader_parameter("outline_color", trail.default_color)`
- L189, `is_facing_right` (visual): `return visuals.scale.x == -.5`
- L193, `_on_dash_timer_timeout` (literal adicional (revisión)): `visuals.modulate.a = 1`
- L207, `_update_regeneration` (regla/valor): `if is_queued_for_deletion() or health_component.current_health <= 0.0 or health_component.current_health >= health_component.max_health or stats.hp_regen <= 0.0:`
- L208, `_update_regeneration` (literal adicional (revisión)): `_regen_credit = 0.0`
- L211, `_update_regeneration` (literal adicional (revisión)): `_regen_credit += maxf(0.0, delta) * stats.hp_regen * REGEN_PER_POINT_PER_SECOND`
- L214, `_update_regeneration` (regla/valor): `if _regen_credit + 0.00000001 < amount: break`
- L215, `_update_regeneration` (literal adicional (revisión)): `_regen_credit = maxf(0.0, _regen_credit-amount)`
- L219, `_update_regeneration` (regla/valor): `if healed > 0.0: Global.on_create_heal_text.emit(self, healed)`
- L221, `_update_regeneration` (literal adicional (revisión)): `_regen_credit = 0.0`
- L234, `_on_dash_cooldown_timer_timeout` (texto): `shadow.material.set_shader_parameter("outline_color", trail.default_color)`
- L237, `_on_hurtbox_component_on_damage` (regla/valor): `if Global.game_paused or is_dashing or hit_invulnerability_left > 0.0: return`
- L241, `try_life_steal` (regla/valor): `if Global.game_paused or is_queued_for_deletion() or life_steal_cooldown > 0.0: return false`
- L242, `try_life_steal` (regla/valor): `if health_component.current_health <= 0.0 or health_component.current_health >= health_component.max_health: return false`
- L244, `try_life_steal` (literal adicional (revisión)): `chance = clampf(chance, 0.0, 1.0)`

## scenes/units/players/player_trail.gd

32 líneas; 3 anotaciones export; 0 uniforms; 1 candidatos.

### Ya expuesto en el editor

- L4: `@export var player: Player`
- L5: `@export var trail_length := 25`
- L6: `@export var trail_duration := 1`

### Candidatos / evidencia

- L10, `declaración` (regla/valor): `var points_array: Array[Vector2] = []`

## scenes/units/players/weapons_container.gd

41 líneas; 0 anotaciones export; 0 uniforms; 11 candidatos.

Hallazgos: ARM-02, ARM-03.

### Candidatos / evidencia

- L4, `declaración` (constante): `const SLOT_DISTANCE_SCALE := 0.75`
- L20, `update_weapons_position` (regla/valor): `if count > 6:`
- L21, `update_weapons_position` (regla/valor): `var radius := 60.0 * SLOT_DISTANCE_SCALE`
- L24, `update_weapons_position` (literal adicional (revisión)): `var angle := TAU * index / count - PI * 0.5`
- L25, `update_weapons_position` (literal adicional (revisión)): `weapons[index].global_position = to_global(Vector2(cos(angle) * radius, sin(angle) * radius * 0.65))`
- L29, `update_weapons_position` (literal adicional (revisión)): `1: reference_node = one`
- L30, `update_weapons_position` (literal adicional (revisión)): `2: reference_node = two`
- L31, `update_weapons_position` (literal adicional (revisión)): `3: reference_node = three`
- L32, `update_weapons_position` (literal adicional (revisión)): `4: reference_node = four`
- L33, `update_weapons_position` (literal adicional (revisión)): `5: reference_node = five`
- L34, `update_weapons_position` (literal adicional (revisión)): `6: reference_node = six`

## scenes/units/unit.gd

113 líneas; 2 anotaciones export; 0 uniforms; 22 candidatos.

Hallazgos: UNIT-06.

### Ya expuesto en el editor

- L24: `@export var status_immune := false`
- L25: `@export var stats: UnitStats`

### Candidatos / evidencia

- L6, `declaración` (constante): `const STATE_NAMES := ["Burning", "Shoked", "Slow", "Rooted", "Airbourne"]`
- L9, `has_status` (regla/valor): `if not is_instance_valid(status_controller) or health_component.current_health <= 0.0: return false`
- L13, `get_active_statuses` (regla/valor): `var result: Array[State] = []`
- L28, `has_status_named` (regla/valor): `var status_movement_multiplier := 1.0`
- L45, `_ready` (literal adicional (revisión)): `sprite.z_index = 0`
- L49, `_ready` (literal adicional (revisión)): `ground_shadow.z_index = -1`
- L51, `_ready` (texto): `status_controller = load("res://effects/status_controller.gd").new()`
- L52, `_ready` (literal adicional (revisión)): `status_controller.name = "StatusController"`
- L61, `immobilize_for` (regla/valor): `status_controller.add_slow(0.0, duration * (source_stats.get_crowd_control_multiplier() if source_stats else 1.0))`
- L73, `receive_hit` (regla/valor): `if Global.game_paused or is_queued_for_deletion() or health_component.current_health <= 0.0:`
- L75, `receive_hit` (regla/valor): `if not is_instance_valid(hitbox) or hitbox.damage <= 0.0: return false`
- L76, `receive_hit` (literal adicional (revisión)): `var blocked := hitbox.can_be_blocked and Global.get_chance_succes(stats.get_block_chance() / 100.0)`
- L81, `receive_hit` (regla/valor): `if stats.block_effectiveness >= 100.0: return false`
- L90, `receive_hit` (regla/valor): `var incoming_damage := hitbox.damage * (stats.get_incoming_damage_multiplier() if self is Player else 1.0)`
- L94, `receive_hit` (regla/valor): `incoming_damage *= 1.0 + items.controlled_damage_percent / 100.0`
- L95, `receive_hit` (texto): `if hitbox.critical and has_status(State.SHOKED): incoming_damage *= 1.0 + 0.5 * items.power("electric_stove")`
- L96, `receive_hit` (texto): `if hitbox.launch_on_hit and items.power("table_slam") > 0: incoming_damage *= 1.0 + hitbox.source.stats.block_effectiveness / 100.0 * items.power("table_slam")`
- L97, `receive_hit` (texto): `if hitbox.critical and has_status(State.SLOW) and items.count("paste") > 0: immobilize_for(items.maximum_power("paste"), hitbox.source.stats)`
- L98, `receive_hit` (regla/valor): `if blocked: incoming_damage *= 1.0 - clampf(stats.block_effectiveness / 100.0, 0.0, 1.0)`
- L101, `receive_hit` (regla/valor): `if dealt <= 0.0: return false`
- L105, `receive_hit` (regla/valor): `if not hitbox.is_status_damage and health_component.current_health > 0.0:`
- L108, `receive_hit` (texto): `load("res://effects/status_controller.gd").apply_effect(self, effect, hitbox)`

## scenes/weapons/melee/catalogue_melee_behaviour.gd

347 líneas; 1 anotaciones export; 0 uniforms; 79 candidatos.

Hallazgos: ARM-07.

### Ya expuesto en el editor

- L4: `@export var style: Style = Style.HAMMER`

### Candidatos / evidencia

- L15, `declaración` (regla/valor): `var pulse_count := 0`
- L16, `declaración` (regla/valor): `var rotor_angle := 0.0`
- L17, `declaración` (regla/valor): `var captured_enemies: Array[Enemy] = []`
- L18, `declaración` (regla/valor): `var attack_distance := 0.0`
- L19, `declaración` (regla/valor): `var swing_side := 1.0`
- L20, `declaración` (regla/valor): `var attack_angle := 0.0`
- L21, `declaración` (regla/valor): `var previous_contact := Vector2.ZERO`
- L23, `declaración` (regla/valor): `var grater_anchor := Vector2.ZERO`
- L24, `declaración` (regla/valor): `var grater_offset := Vector2.ZERO`
- L25, `declaración` (regla/valor): `var grater_angle := 0.0`
- L27, `declaración` (regla/valor): `var ladle_start_point := Vector2.ZERO`
- L28, `declaración` (regla/valor): `var ladle_travel_direction := Vector2.RIGHT`
- L33, `_ready` (literal adicional (revisión)): `z_index = 0`
- L34, `_ready` (regla/valor): `if style == Style.GRATER: hitbox.collision_layer = 0`
- L49, `_draw` (literal adicional (revisión)): `draw_arc(center, radius, rotor_angle, rotor_angle + tuning.rotor_arc, 8, tuning.rotor_color, tuning.rotor_width, true)`
- L66, `execute_attack` (literal adicional (revisión)): `pulse_count = 0`
- L84, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, stats.back_duration * _timing())`
- L85, `execute_attack` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, stats.back_duration * _timing())`
- L95, `_timing` (regla/valor): `return timing / maxf(0.01, tuning.animation_speed)`
- L98, `_tip` (regla/valor): `return weapon.atk_start_pos + Vector2(distance, 0)`
- L100, `_begin_pulse` (literal adicional (revisión)): `func _begin_pulse(damage_multiplier: float = 1.0, knockback: float = -1.0) -> void:`
- L102, `_begin_pulse` (regla/valor): `hitbox.setup(get_base_damage() * damage_multiplier, false, weapon.data.stats.knockback if knockback < 0.0 else knockback, weapon.get_parent())`
- L109, `_begin_pulse` (regla/valor): `hitbox.launch_damage = get_base_damage() * tuning.collision_damage_multiplier if style == Style.GLOVE else 0.0`
- L110, `_begin_pulse` (literal adicional (revisión)): `hitbox.cancel_knockback_on_hit = style == Style.HAMMER and knockback == 0.0`
- L114, `_begin_pulse` (regla/valor): `pulse_count += 1`
- L124, `_swept_contacts` (regla/valor): `var radius: float = 8.0`
- L125, `_swept_contacts` (regla/valor): `if hitbox.bb.shape is RectangleShape2D:`
- L127, `_swept_contacts` (literal adicional (revisión)): `radius = minf(extent.x, extent.y) * 0.5`
- L129, `_swept_contacts` (literal adicional (revisión)): `shape.radius = maxf(2.0, radius)`
- L130, `_swept_contacts` (literal adicional (revisión)): `shape.height = travel.length() + shape.radius * 2.0`
- L133, `_swept_contacts` (literal adicional (revisión)): `query.transform = Transform2D(travel.angle() - PI / 2.0, previous_contact + travel * 0.5)`
- L134, `_swept_contacts` (literal adicional (revisión)): `query.collision_mask = 8`
- L137, `_swept_contacts` (literal adicional (revisión)): `for result in weapon.get_world_2d().direct_space_state.intersect_shape(query, 64):`
- L144, `_slam` (texto): `tween.tween_property(weapon.sprite_2d, "rotation", deg_to_rad(tuning.raised_angle), tuning.preparation_duration * timing).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)`
- L145, `_slam` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)`
- L148, `_slam` (texto): `tween.tween_property(weapon.sprite_2d, "position", _tip(weapon.get_effective_range() * tuning.reach_multiplier), tuning.forward_duration * timing).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)`
- L149, `_slam` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.forward_duration * timing)`
- L158, `_jabs` (texto): `tween.tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)`
- L161, `_jabs` (regla/valor): `var offset := Vector2(0, (1 if index % 2 == 0 else -1) * tuning.lateral_offset) if style == Style.WHISK else Vector2.ZERO`
- L162, `_jabs` (texto): `tween.tween_property(weapon.sprite_2d, "position", _tip(distance) + offset, tuning.forward_duration * timing)`
- L163, `_jabs` (visual): `if tuning.contact_duration > 0.0: tween.tween_interval(tuning.contact_duration * timing)`
- L165, `_jabs` (texto): `tween.tween_property(weapon.sprite_2d, "position", _tip(distance * tuning.repeated_retract_multiplier if count > 1 else 0.0), tuning.return_duration * timing)`
- L172, `_scrape` (visual): `if enemy is Enemy and not enemy.is_retiring and enemy.health_component.current_health > 0.0 and enemy.global_position.distance_to(center) <= tuning.capture_radius * absf(weapon.global_scale.x) * weapon.get_parent().stats.get_area_radius_multiplier():`
- L183, `_scrape` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", tuning.scrape_rotation, tuning.forward_duration * timing)`
- L186, `_scrape` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", -tuning.scrape_rotation, tuning.return_duration * timing)`
- L190, `_ladle` (texto): `var point := weapon.to_local(weapon.closest_target.get_node("HurtboxComponent/CollisionShape2D").global_position) if is_instance_valid(weapon.closest_target) else Vector2(weapon.get_effective_range() * tuning.reach_multiplier, 0)`
- L198, `_ladle` (regla/valor): `if next_point.distance_squared_to(point) > 0.001:`
- L200, `_ladle` (literal adicional (revisión)): `_set_ladle_progress(0.0)`
- L203, `_ladle` (literal adicional (revisión)): `tween.tween_method(_set_ladle_progress, 0.0, 1.0, tuning.forward_duration * timing)`
- L209, `_set_ladle_angle` (visual): `weapon.sprite_2d.position = Vector2.from_angle(angle) * attack_distance - head_offset.rotated(angle)`
- L210, `_set_ladle_angle` (regla/valor): `weapon.sprite_2d.rotation = angle`
- L215, `_roll` (texto): `tween.tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.preparation_duration * timing)`
- L217, `_roll` (literal adicional (revisión)): `tween.tween_method(_set_roll_progress, 0.0, 1.0, tuning.forward_duration * timing)`
- L221, `_roll` (literal adicional (revisión)): `tween.tween_method(_set_roll_progress, 1.0, 0.0, tuning.return_duration * timing)`
- L228, `_set_roll_progress` (visual): `weapon.sprite_2d.position = weapon.atk_start_pos + Vector2(reach, 0) - Vector2.from_angle(angle) * reach * (1.0 - progress)`
- L229, `_set_roll_progress` (regla/valor): `weapon.sprite_2d.rotation = angle`
- L231, `_set_roll_progress` (visual): `weapon.sprite_2d.position = weapon.atk_start_pos + Vector2(progress * reach, 0)`
- L232, `_set_roll_progress` (regla/valor): `weapon.sprite_2d.rotation = 0.0`
- L242, `_second_ladle_target` (regla/valor): `var eligible: Array[Enemy] = []`
- L244, `_second_ladle_target` (visual): `if enemy is Enemy and enemy.targetable and not enemy.is_queued_for_deletion() and not enemy.is_retiring and enemy.health_component.current_health > 0.0 and enemy.global_position.distance_squared_to(origin) <= radius * radius:`
- L251, `_second_ladle_target` (visual): `if eligible.size() < 2: return null`
- L252, `_second_ladle_target` (regla/valor): `if eligible[1] != weapon.closest_target: return eligible[1]`
- L254, `_second_ladle_target` (regla/valor): `return eligible[0] if eligible[0] != weapon.closest_target else null`
- L260, `_set_ladle_progress` (visual): `weapon.sprite_2d.position = ladle_start_point + offset - head_offset.rotated(orientation)`
- L261, `_set_ladle_progress` (regla/valor): `weapon.sprite_2d.rotation = orientation`
- L270, `_update_grater_anchor` (visual): `weapon.sprite_2d.position = weapon.to_local(world_point) - head_offset.rotated(weapon.sprite_2d.rotation)`
- L286, `_pan_impact` (texto): `var effect = load("res://effects/pan_slow_burst.gd")`
- L307, `_hammer` (texto): `tween.tween_property(weapon.sprite_2d, "rotation", deg_to_rad(tuning.raised_angle), tuning.preparation_duration * timing)`
- L308, `_hammer` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "position", _tip(tuning.windup_offset), tuning.preparation_duration * timing)`
- L310, `_hammer` (texto): `tween.tween_property(weapon.sprite_2d, "position", _tip(weapon.get_effective_range() * tuning.reach_multiplier), tuning.forward_duration * timing)`
- L311, `_hammer` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, tuning.forward_duration * timing)`
- L320, `_mace` (texto): `attack_angle = weapon.to_local(weapon.closest_target.get_node("HurtboxComponent/CollisionShape2D").global_position).angle() if is_instance_valid(weapon.closest_target) else 0.0`
- L321, `_mace` (literal adicional (revisión)): `tween.tween_method(_set_ladle_angle, 0.0, deg_to_rad(tuning.sweep_start_angle), tuning.preparation_duration * timing)`
- L329, `_blend` (texto): `tween.tween_property(weapon.sprite_2d, "position", contact, tuning.preparation_duration * timing)`
- L332, `_blend` (texto): `tween.tween_property(weapon.sprite_2d, "rotation", tuning.blend_rotation, tuning.forward_duration * timing)`
- L333, `_blend` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "position", contact + Vector2(0, tuning.blend_offset), tuning.forward_duration * timing)`
- L334, `_blend` (texto): `tween.tween_property(weapon.sprite_2d, "rotation", -tuning.blend_rotation, tuning.return_duration * timing)`
- L335, `_blend` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "position", contact - Vector2(0, tuning.blend_offset), tuning.return_duration * timing)`
- L342, `reset_attack` (literal adicional (revisión)): `rotor_angle = 0.0`

## scenes/weapons/melee/melee_behaviour.gd

86 líneas; 2 anotaciones export; 0 uniforms; 13 candidatos.

### Ya expuesto en el editor

- L4: `@export var hitbox: HitboxComponent`
- L6: `@export var attack_motion: AttackMotion = AttackMotion.THRUST`

### Candidatos / evidencia

- L21, `execute_attack` (literal adicional (revisión)): `var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration) / maxf(0.01, stats.melee_settings.animation_speed)`
- L22, `execute_attack` (regla/valor): `var recoild_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)`
- L23, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", recoild_pos, weapon.data.stats.recoil_duration * time_scale)`
- L33, `execute_attack` (regla/valor): `var attack_pos := Vector2(weapon.atk_start_pos.x + weapon.get_effective_range(), weapon.atk_start_pos.y)`
- L34, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", attack_pos, weapon.data.stats.attack_duration * time_scale)`
- L41, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, weapon.data.stats.back_duration * time_scale)`
- L51, `_execute_semicircle` (literal adicional (revisión)): `var time_scale := weapon.get_animation_time_scale(stats.recoil_duration + stats.attack_duration + stats.back_duration) / maxf(0.01, stats.melee_settings.animation_speed)`
- L58, `_execute_semicircle` (texto): `tween.tween_property(weapon.sprite_2d, "position", arc_start, stats.recoil_duration * time_scale)`
- L59, `_execute_semicircle` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", first_angle, stats.recoil_duration * time_scale)`
- L69, `_execute_semicircle` (texto): `tween.tween_property(weapon.sprite_2d, "position", start_position, stats.back_duration * time_scale)`
- L70, `_execute_semicircle` (texto): `tween.parallel().tween_property(weapon.sprite_2d, "rotation", 0.0, stats.back_duration * time_scale)`
- L85, `_set_sweep_angle` (visual): `weapon.sprite_2d.position = _sweep_center() + Vector2.from_angle(angle) * radius`
- L86, `_set_sweep_angle` (regla/valor): `weapon.sprite_2d.rotation = angle`

## scenes/weapons/melee/weapon_behaviour.gd

48 líneas; 1 anotaciones export; 0 uniforms; 3 candidatos.

### Ya expuesto en el editor

- L4: `@export var weapon: Weapon`

### Candidatos / evidencia

- L17, `reset_attack` (visual): `weapon.sprite_2d.position = weapon.atk_start_pos`
- L18, `reset_attack` (regla/valor): `weapon.sprite_2d.rotation = 0.0`
- L37, `get_life_steal_chance` (regla/valor): `if not is_instance_valid(weapon.get_parent()): return 0.0`

## scenes/weapons/range/hydrant_weapon.gd

9 líneas; 0 anotaciones export; 0 uniforms; 0 candidatos.


## scenes/weapons/range/kitchen_torch_stream.gd

15 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L5, `_ready` (literal adicional (revisión)): `line.z_index=0`
- L6, `_ready` (texto): `stream_material.shader=preload("res://shaders/kitchen_torch_flame.gdshader")`
- L10, `_update_trace` (literal adicional (revisión)): `line.width=weapon.data.stats.ranged_settings.stream_width*1.25`

## scenes/weapons/range/mayonnaise_stream.gd

172 líneas; 0 anotaciones export; 0 uniforms; 44 candidatos.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var tick_left := 0.0`
- L8, `declaración` (regla/valor): `var current_targets: Array[Enemy] = []`
- L9, `declaración` (regla/valor): `var stream_start := Vector2.ZERO`
- L10, `declaración` (regla/valor): `var stream_end := Vector2.ZERO`
- L11, `declaración` (regla/valor): `var flow_phase := 0.0`
- L12, `declaración` (regla/valor): `var particle_left := 0.0`
- L19, `_ready` (literal adicional (revisión)): `trace_query.collision_mask = 8`
- L24, `_ready` (literal adicional (revisión)): `line.z_index = 2`
- L32, `_ready` (literal adicional (revisión)): `white_texture.width = 8`
- L33, `_ready` (literal adicional (revisión)): `white_texture.height = 8`
- L37, `_ready` (texto): `stream_material.shader = preload("res://shaders/mayonnaise_stream.gdshader")`
- L42, `_ready` (literal adicional (revisión)): `hit.collision_layer = 0`
- L43, `_ready` (literal adicional (revisión)): `hit.collision_mask = 0`
- L49, `update_stream` (regla/valor): `if not has_target or not is_instance_valid(weapon.closest_target) or not weapon.closest_target.targetable or weapon.closest_target.is_retiring or weapon.closest_target.health_component.current_health <= 0.0 or weapon.data == null or weapon.data.stats.ranged_settings == null:`
- L54, `update_stream` (literal adicional (revisión)): `tick_left = 0.0`
- L66, `update_stream` (regla/valor): `var ticks := 0`
- L67, `update_stream` (literal adicional (revisión)): `while tick_left <= 0.0 and ticks < 4:`
- L70, `update_stream` (regla/valor): `ticks += 1`
- L71, `update_stream` (regla/valor): `if tick_left < 0.0: tick_left = 0.0`
- L77, `_update_trace` (regla/valor): `if direction.is_zero_approx(): direction = Vector2.RIGHT.rotated(weapon.rotation)`
- L80, `_update_trace` (regla/valor): `var count := 1 + weapon.data.get_effective_piercing(weapon.get_parent().stats)`
- L83, `_update_trace` (visual): `if count == 1: length = minf(length,stream_start.distance_to(target_position))`
- L85, `_update_trace` (literal adicional (revisión)): `trace_shape.radius = width * 0.5`
- L87, `_update_trace` (literal adicional (revisión)): `trace_query.transform = Transform2D(direction.angle() + PI * 0.5, stream_start + direction * length * 0.5)`
- L89, `_update_trace` (regla/valor): `var distances: Array[float] = []`
- L92, `_update_trace` (literal adicional (revisión)): `for result in get_world_2d().direct_space_state.intersect_shape(trace_query, 256):`
- L96, `_update_trace` (regla/valor): `if not enemy is Enemy or not enemy.targetable or enemy.is_retiring or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0: continue`
- L97, `_update_trace` (regla/valor): `if count == 1:`
- L112, `_update_trace` (regla/valor): `if count == 1:`
- L118, `_update_trace` (literal adicional (revisión)): `stream_end = stream_start + direction * clampf(distance, 0.0, length)`
- L127, `_update_trace` (literal adicional (revisión)): `var segments := maxi(6,ceili(strand_length/10.0))`
- L128, `_update_trace` (literal adicional (revisión)): `for i in range(segments+1):`
- L130, `_update_trace` (literal adicional (revisión)): `var wobble := (sin(t*strand_length*0.12-flow_phase)*0.7+sin(t*strand_length*0.23-flow_phase*1.3)*0.3)*sin(t*PI)`
- L131, `_update_trace` (literal adicional (revisión)): `points.append(local_start.lerp(local_end,t)+side*wobble*minf(config.stream_wobble,config.stream_width*0.2))`
- L133, `_update_trace` (texto): `stream_material.set_shader_parameter("phase",flow_phase)`
- L134, `_update_trace` (texto): `stream_material.set_shader_parameter("strand_length",strand_length)`
- L135, `_update_trace` (texto): `stream_material.set_shader_parameter("mayo_color",config.stream_color)`
- L136, `_update_trace` (texto): `stream_material.set_shader_parameter("core_color",config.stream_core_color)`
- L137, `_update_trace` (texto): `stream_material.set_shader_parameter("edge_color",config.stream_edge_color)`
- L141, `_emit_particles` (regla/valor): `if particle_left > 0.0: return`
- L145, `_emit_particles` (texto): `var particles = load("res://effects/mayonnaise_particles.gd")`
- L158, `_damage_tick` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.health_component.current_health <= 0: continue`
- L165, `_stop_stream` (literal adicional (revisión)): `tick_left = 0.0`
- L166, `_stop_stream` (literal adicional (revisión)): `particle_left = 0.0`

## scenes/weapons/range/range_behaviour.gd

100 líneas; 0 anotaciones export; 0 uniforms; 18 candidatos.

### Candidatos / evidencia

- L5, `declaración` (regla/valor): `var burst_generation := 0`
- L9, `reset_attack` (regla/valor): `burst_generation += 1`
- L16, `execute_attack` (literal adicional (revisión)): `lock_aim_during_attack = settings != null and settings.lock_burst_aim and settings.burst_count > 1`
- L17, `execute_attack` (regla/valor): `if settings and settings.burst_count > 1:`
- L20, `execute_attack` (regla/valor): `get_tree().create_timer(shot * settings.burst_interval, false).timeout.connect(func():`
- L28, `execute_attack` (literal adicional (revisión)): `var time_scale := weapon.get_animation_time_scale(weapon.data.stats.recoil_duration * 2.0)`
- L29, `execute_attack` (regla/valor): `var attack_pos := Vector2(weapon.atk_start_pos.x - weapon.data.stats.recoil, weapon.atk_start_pos.y)`
- L30, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", attack_pos, weapon.data.stats.recoil_duration * time_scale)`
- L31, `execute_attack` (texto): `tween.tween_property(weapon.sprite_2d, "position", weapon.atk_start_pos, weapon.data.stats.recoil_duration * time_scale)`
- L34, `execute_attack` (literal adicional (revisión)): `var burst_duration := (settings.burst_count - 1) * settings.burst_interval + 0.01`
- L35, `execute_attack` (literal adicional (revisión)): `var recoil_duration := weapon.data.stats.recoil_duration * 2.0 * time_scale`
- L47, `create_projectile` (regla/valor): `var count := settings.projectile_count if settings else 1`
- L49, `create_projectile` (regla/valor): `var offset := deg_to_rad(settings.spread_degrees) * (float(index) / maxf(1.0, count - 1) - 0.5) if settings and count > 1 else 0.0`
- L54, `create_projectile` (texto): `var pit = load("res://scenes/projectiles/ranged_area_effect.gd").new()`
- L56, `create_projectile` (literal adicional (revisión)): `pit.global_position = weapon.get_parent().global_position + Vector2.from_angle(randf() * TAU) * 28.0`
- L69, `_spawn_pit` (regla/valor): `var deviation := deg_to_rad(randf_range(-settings.pit_deviation_degrees, settings.pit_deviation_degrees))`
- L70, `_spawn_pit` (regla/valor): `var direction := Vector2.RIGHT.rotated(weapon.rotation + PI + deviation)`
- L85, `_spawn_projectile` (regla/valor): `var velocity := Vector2.RIGHT.rotated(aim_angle + angle_offset) * weapon.data.stats.projectile_speed`

## scenes/weapons/spicy/aura_behaviour.gd

99 líneas; 0 anotaciones export; 0 uniforms; 26 candidatos.

Hallazgos: ARM-05.

### Candidatos / evidencia

- L6, `declaración` (regla/valor): `var elapsed := 0.0`
- L12, `_ready` (literal adicional (revisión)): `aura.z_index = -1`
- L18, `_ready` (texto): `aura_material.shader = preload("res://shaders/spicy_aura.gdshader")`
- L23, `_process` (literal adicional (revisión)): `aura.visible = aura_contributors()[0] == weapon`
- L29, `_process` (regla/valor): `var extent := Vector2.ZERO`
- L36, `_process` (literal adicional (revisión)): `coverage.resize(6)`
- L37, `_process` (literal adicional (revisión)): `for index in mini(6, contributors.size()):`
- L41, `_process` (texto): `aura_material.set_shader_parameter("coverage_count", mini(6, contributors.size()))`
- L42, `_process` (texto): `aura_material.set_shader_parameter("coverage_extents", coverage)`
- L43, `_process` (visual): `surface.position = -extent`
- L44, `_process` (visual): `surface.size = extent * 2.0`
- L45, `_process` (texto): `aura_material.set_shader_parameter("elapsed", elapsed)`
- L46, `_process` (texto): `aura_material.set_shader_parameter("heat_color", settings.color)`
- L47, `_process` (texto): `aura_material.set_shader_parameter("opacity", settings.opacity)`
- L48, `_process` (texto): `aura_material.set_shader_parameter("breathing_speed", settings.breathing_speed)`
- L49, `_process` (texto): `aura_material.set_shader_parameter("breathing_strength", settings.breathing_strength)`
- L51, `_process` (visual): `aura_material.set_shader_parameter(property, settings.get(property))`
- L54, `can_execute_attack` (regla/valor): `return aura_contributors()[0] == weapon`
- L61, `execute_attack` (literal adicional (revisión)): `hit.setup(0.0, false, weapon.data.stats.knockback, source)`
- L66, `execute_attack` (regla/valor): `if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or enemy.is_retiring or enemy.health_component.current_health <= 0.0: continue`
- L67, `execute_attack` (regla/valor): `var shares: Array[Dictionary] = []`
- L68, `execute_attack` (regla/valor): `var total := 0.0`
- L78, `execute_attack` (literal adicional (revisión)): `for share in shares: share.weight /= maxf(0.00001, total)`
- L81, `execute_attack` (literal adicional (revisión)): `hit.weapon_damage_record = {"wave_damage": 0.0, "total_damage": 0.0, "contributors": shares}`
- L87, `reset_attack` (literal adicional (revisión)): `elapsed = 0.0`
- L90, `aura_contributors` (regla/valor): `var result: Array[Weapon] = []`

## scenes/weapons/spicy/explosion_behaviour.gd

48 líneas; 0 anotaciones export; 0 uniforms; 12 candidatos.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var explosions_remaining := 0`
- L4, `declaración` (regla/valor): `var next_explosion := 0.0`
- L15, `_process` (regla/valor): `if not is_instance_valid(source) or source.health_component.current_health <= 0.0:`
- L19, `_process` (regla/valor): `if next_explosion > 0.0: return`
- L20, `_process` (regla/valor): `if explosions_remaining > 0:`
- L32, `_spawn_next` (regla/valor): `var angle := randf_range(0.0, TAU)`
- L33, `_spawn_next` (regla/valor): `var distance := sqrt(randf_range(min_distance * min_distance, max_distance * max_distance))`
- L34, `_spawn_next` (regla/valor): `var offset := Vector2.from_angle(angle) * distance`
- L38, `_spawn_next` (texto): `var blast = load("res://effects/spicy_explosion.gd").new()`
- L41, `_spawn_next` (literal adicional (revisión)): `explosions_remaining -= 1`
- L46, `reset_attack` (literal adicional (revisión)): `explosions_remaining = 0`
- L47, `reset_attack` (literal adicional (revisión)): `next_explosion = 0.0`

## scenes/weapons/spicy/pattern_behaviour.gd

179 líneas; 0 anotaciones export; 0 uniforms; 35 candidatos.

Hallazgos: ARM-06.

### Candidatos / evidencia

- L3, `declaración` (regla/valor): `var owned: Array[WeakRef] = []`
- L4, `declaración` (visual): `var last_trail_position := Vector2.ZERO`
- L6, `declaración` (regla/valor): `var spiral_angle := 0.0`
- L11, `can_execute_attack` (regla/valor): `var active := 0`
- L14, `can_execute_attack` (regla/valor): `if is_instance_valid(effect) and not effect.is_queued_for_deletion(): active += 1`
- L16, `can_execute_attack` (regla/valor): `if settings.mode == SpicyPatternSettings.Mode.TRAIL and trail_contributors()[0] != weapon: return false`
- L17, `can_execute_attack` (regla/valor): `if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE and shockwave_contributors()[0] != weapon: return false`
- L29, `execute_attack` (regla/valor): `if settings.mode == SpicyPatternSettings.Mode.TRAIL and trail_contributors()[0] != weapon: return`
- L30, `execute_attack` (regla/valor): `if settings.mode == SpicyPatternSettings.Mode.SHOCKWAVE and shockwave_contributors()[0] != weapon: return`
- L33, `execute_attack` (literal adicional (revisión)): `var direction_offset := TAU*contributors.find(weapon)/maxi(1,contributors.size())`
- L51, `execute_attack` (literal adicional (revisión)): `var spawn_count := maxi(0,settings.count-owned.size()) if settings.mode == SpicyPatternSettings.Mode.TORNADO else settings.count`
- L59, `execute_attack` (regla/valor): `if point == Vector2.INF: continue`
- L63, `execute_attack` (literal adicional (revisión)): `point += Vector2.from_angle(randf()*TAU) * weapon.get_effective_range() * Global.GAME_ENTITY_SCALE * 0.35`
- L65, `execute_attack` (texto): `var effect = load("res://effects/spicy_pattern_effect.gd").new()`
- L69, `execute_attack` (regla/valor): `if settings.mode == SpicyPatternSettings.Mode.ORBIT: weapon.sprite_2d.hide()`
- L78, `reset_attack` (literal adicional (revisión)): `spiral_angle = 0.0`
- L82, `trail_contributors` (regla/valor): `var result: Array[Weapon] = []`
- L94, `_cloud_spawn_point` (regla/valor): `var active: Array[Node2D] = []`
- L100, `_cloud_spawn_point` (literal adicional (revisión)): `var reach := maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE`
- L102, `_cloud_spawn_point` (regla/valor): `var best := Vector2.INF`
- L103, `_cloud_spawn_point` (regla/valor): `var best_score := -1.0`
- L104, `_cloud_spawn_point` (regla/valor): `var best_distance := 0.0`
- L113, `_cloud_spawn_point` (literal adicional (revisión)): `var separation: float = settings.cloud_min_separation*(own_radius+cloud.radius)*0.5`
- L114, `_cloud_spawn_point` (literal adicional (revisión)): `score = minf(score,distance/maxf(0.001,separation))`
- L120, `_cloud_spawn_point` (regla/valor): `if score >= 1.0 and nearest > 0.01: return point`
- L122, `_cloud_spawn_point` (regla/valor): `if best_distance > maxf(0.01,minf(12.0*Global.GAME_ENTITY_SCALE,reach*0.1)): return best`
- L123, `_cloud_spawn_point` (regla/valor): `return Vector2.INF`
- L126, `_random_cloud_point` (regla/valor): `return _local_spawn_point(source, maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE,settings.area_y_ratio)`
- L129, `_local_spawn_point` (regla/valor): `var offset := Vector2.from_angle(randf()*TAU)*sqrt(randf())*reach`
- L135, `_local_spawn_point` (regla/valor): `var normalized := Vector2(offset.x,offset.y/y_ratio)`
- L136, `_local_spawn_point` (regla/valor): `if normalized.length() > reach and normalized.length() > 0.0:`
- L141, `spiral_contributors` (regla/valor): `var result: Array[Weapon] = []`
- L152, `mine_contributors` (regla/valor): `var result: Array[Weapon] = []`
- L165, `get_mine_spawn_radius` (regla/valor): `return maxf(0.0,weapon.get_effective_range())*Global.GAME_ENTITY_SCALE*(1.0+maxi(0,copies-1)*config.mine_spawn_growth_per_copy)`
- L171, `shockwave_contributors` (regla/valor): `var result: Array[Weapon] = []`

## scenes/weapons/spicy/seed_behaviour.gd

6 líneas; 0 anotaciones export; 0 uniforms; 1 candidatos.

### Candidatos / evidencia

- L6, `create_projectile` (regla/valor): `_spawn_projectile(randf_range(0.0, TAU))`

## scenes/weapons/spicy/spicy_weapon.gd

18 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L12, `rotate_to_target` (literal adicional (revisión)): `rotation = 0.0`
- L15, `calculate_spread` (literal adicional (revisión)): `weapon_spread = 0.0`
- L18, `update_visuals` (visual): `sprite_2d.scale = sprite_base_scale`

## scenes/weapons/weapon.gd

187 líneas; 3 anotaciones export; 0 uniforms; 20 candidatos.

Hallazgos: ARM-01.

### Ya expuesto en el editor

- L5: `@export var attack_sound: AudioStream`
- L6: `@export var impact_sound: AudioStream`
- L7: `@export var continuous_sound: AudioStream`

### Candidatos / evidencia

- L4, `declaración` (constante): `const VISUAL_SCALE := 0.75`
- L16, `declaración` (regla/valor): `static var damage_records: Array[Dictionary] = []`
- L17, `declaración` (regla/valor): `var damage_record: Dictionary = {}`
- L20, `begin_damage_wave` (literal adicional (revisión)): `for record in damage_records: record.wave_damage = 0.0`
- L32, `finish_damage_wave` (regla/valor): `var spatial_target_deadline := 0.0`
- L36, `_ready` (literal adicional (revisión)): `range_area.set_deferred("collision_mask",0)`
- L48, `center_range_on_weapon` (visual): `range_area.position = Vector2.ZERO`
- L65, `setup_weapon` (literal adicional (revisión)): `damage_record = {"weapon": weapon_data, "instance_id": get_instance_id(), "wave_damage": 0.0, "last_wave_damage": 0.0, "total_damage": 0.0}`
- L68, `setup_weapon` (literal adicional (revisión)): `damage_record["impact_event"] = "weapon_impact:"+scene_file_path`
- L75, `setup_weapon` (texto): `load("res://effects/golden_visual.gd").apply_weapon(self)`
- L82, `_refresh_range` (literal adicional (revisión)): `spatial_target_deadline = 0.0`
- L99, `get_animation_time_scale` (regla/valor): `return minf(1.0, get_effective_cooldown() * data.stats.animation_cooldown_fraction / maxf(animation_duration, 0.001))`
- L126, `get_idle_rotation` (regla/valor): `return 0`
- L141, `get_closest_target` (visual): `if EnemyCrowd.clock<spatial_target_deadline and is_instance_valid(spatial_target) and spatial_target.targetable and not spatial_target.is_queued_for_deletion() and not spatial_target.is_retiring and spatial_target.health_component.current_health>0 and origin.distance_squared_to(spatial_target.global_position)<=range_squared:`
- L144, `get_closest_target` (literal adicional (revisión)): `spatial_target_deadline = EnemyCrowd.clock+0.06`
- L146, `get_closest_target` (literal adicional (revisión)): `for index in range(targets.size() - 1, -1, -1):`
- L152, `get_closest_target` (regla/valor): `if target.health_component.current_health <= 0.0:`
- L163, `calculate_spread` (regla/valor): `weapon_spread = randf_range(-1 + data.stats.accuracy, 1 - data.stats.accuracy)`
- L167, `update_visuals` (regla/valor): `if abs(rotation) > PI/2:`
- L178, `apply_tier_outline` (texto): `sprite_2d.material.set_shader_parameter("outline_color", outline_color)`

## shaders/badge_fire_glow.gdshader

19 líneas; 0 anotaciones export; 4 uniforms; 9 candidatos.

### Uniforms editables

- L3: `uniform float phase=0.0;`
- L4: `uniform int shape=0;`
- L5: `uniform vec4 glow_color : source_color = vec4(1.0,0.34,0.035,1.0);`
- L6: `uniform float strength=1.15;`

### Candidatos / evidencia

- L7, `shader` (shader interno): `float segment(vec2 p,vec2 a,vec2 b){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.0,1.0));}`
- L9, `shader` (shader interno): `vec2 p=(UV-0.5)*110.0;`
- L10, `shader` (shader interno): `float d=abs(length(p)-37.2);`
- L11, `shader` (shader interno): `if(shape==1){`
- L12, `shader` (shader interno): `float shaft=length(max(abs(p-vec2(-7.5,0.0))-vec2(14.5,4.5),vec2(0.0)));`
- L13, `shader` (shader interno): `float head=min(segment(p,vec2(7,-18),vec2(30,0)),min(segment(p,vec2(30,0),vec2(7,18)),segment(p,vec2(7,18),vec2(7,-18))));`
- L14, `shader` (shader interno): `if(p.x>=7.0 && p.x<=30.0 && abs(p.y)<(30.0-p.x)*18.0/23.0) head=0.0;`
- L17, `shader` (shader interno): `float halo=exp(-d*d/50.0)*0.6+exp(-d*d/160.0)*0.22;`
- L18, `shader` (shader interno): `COLOR=vec4(glow_color.rgb,clamp(halo*strength,0.0,1.0));`

## shaders/boss_fire_line.gdshader

20 líneas; 0 anotaciones export; 4 uniforms; 12 candidatos.

### Uniforms editables

- L3: `uniform float phase = 0.0;`
- L4: `uniform float flash : hint_range(0.0,1.0) = 0.0;`
- L5: `uniform vec4 flash_color : source_color = vec4(1.0,0.58,0.12,1.0);`
- L6: `uniform float world_length = 1000.0;`

### Candidatos / evidencia

- L8, `shader` (shader interno): `float x = UV.x * world_length / 38.0;`
- L9, `shader` (shader interno): `float drift = sin(x * 2.1 - phase * 5.0) * 0.035 + sin(x * 4.7 + phase * 3.0) * 0.025;`
- L10, `shader` (shader interno): `float y = abs(UV.y - 0.5 - drift);`
- L11, `shader` (shader interno): `float licks = 0.28 + sin(x * 3.6 - phase * 6.0) * 0.055 + sin(x * 6.3 + phase * 4.0) * 0.025;`
- L12, `shader` (shader interno): `float flame = 1.0 - smoothstep(licks * 0.6, licks, y);`
- L13, `shader` (shader interno): `float core = 1.0 - smoothstep(0.06,0.19,y);`
- L14, `shader` (shader interno): `float hot = 1.0 - smoothstep(0.01,0.08,y);`
- L15, `shader` (shader interno): `vec3 color = mix(vec3(0.75,0.08,0.018),vec3(1.0,0.48,0.045),core);`
- L16, `shader` (shader interno): `color = mix(color,vec3(1.0,0.86,0.33),hot * 0.9);`
- L17, `shader` (shader interno): `color = mix(color,flash_color.rgb,flash*0.45);`
- L18, `shader` (shader interno): `float ends = smoothstep(0.0,0.005,UV.x) * (1.0 - smoothstep(0.995,1.0,UV.x));`
- L19, `shader` (shader interno): `COLOR = vec4(color, flame * ends);`

## shaders/boss_grill_surface.gdshader

37 líneas; 0 anotaciones export; 9 uniforms; 20 candidatos.

### Uniforms editables

- L3: `uniform vec2 surface_size = vec2(2800.0,1866.67);`
- L4: `uniform vec4 grill_rect = vec4(-1181.25,-641.667,2362.5,1297.92);`
- L5: `uniform float corner_radius = 142.188;`
- L6: `uniform vec4 metal_color : source_color = vec4(0.105,0.112,0.12,1.0);`
- L7: `uniform vec4 metal_shadow : source_color = vec4(0.023,0.025,0.03,1.0);`
- L8: `uniform vec4 rib_highlight : source_color = vec4(0.18,0.19,0.20,1.0);`
- L9: `uniform float rib_spacing : hint_range(40.0,200.0) = 105.0;`
- L10: `uniform float rib_width : hint_range(4.0,40.0) = 18.0;`
- L11: `uniform float rib_angle : hint_range(-90.0,90.0) = -15.0;`

### Candidatos / evidencia

- L12, `shader` (shader interno): `varying vec4 vertex_tint;`
- L14, `shader` (shader interno): `float rounded_rect(vec2 p,vec2 half_size,float radius) {`
- L15, `shader` (shader interno): `vec2 q=abs(p)-half_size+radius;`
- L16, `shader` (shader interno): `return length(max(q,vec2(0.0)))+min(max(q.x,q.y),0.0)-radius;`
- L19, `shader` (shader interno): `vec4 source=texture(TEXTURE,UV);`
- L20, `shader` (shader interno): `float light=dot(source.rgb,vec3(0.299,0.587,0.114));`
- L21, `shader` (shader interno): `vec3 metal=mix(metal_shadow.rgb,metal_color.rgb,clamp(light*1.65,0.0,1.0));`
- L22, `shader` (shader interno): `vec2 p=(UV-0.5)*surface_size;`
- L23, `shader` (shader interno): `vec2 center=grill_rect.xy+grill_rect.zw*0.5;`
- L24, `shader` (shader interno): `float edge=rounded_rect(p-center,grill_rect.zw*0.5,corner_radius);`
- L25, `shader` (shader interno): `float aa=max(fwidth(edge),1.0);`
- L26, `shader` (shader interno): `float interior=1.0-smoothstep(-aa,aa,edge);`
- L28, `shader` (shader interno): `float stripe=dot(p,vec2(-sin(angle),cos(angle)));`
- L29, `shader` (shader interno): `float d=abs(mod(stripe+rib_spacing*0.5,rib_spacing)-rib_spacing*0.5);`
- L30, `shader` (shader interno): `float stripe_aa=max(fwidth(stripe),1.0);`
- L31, `shader` (shader interno): `float ribs=1.0-smoothstep(rib_width*0.5-stripe_aa,rib_width*0.5+stripe_aa,d);`
- L32, `shader` (shader interno): `float crest=1.0-smoothstep(1.0,3.0,abs(d-rib_width*0.5));`
- L33, `shader` (shader interno): `vec3 surface=mix(metal,metal_shadow.rgb,ribs*0.8);`
- L34, `shader` (shader interno): `surface=mix(surface,rib_highlight.rgb,crest*0.35);`
- L36, `shader` (shader interno): `COLOR=vec4(metal,source.a)*vertex_tint;`

## shaders/boss_impact_flash.gdshader

6 líneas; 0 anotaciones export; 3 uniforms; 1 candidatos.

### Uniforms editables

- L3: `uniform float progress=0.0;`
- L4: `uniform float strength=1.0;`
- L5: `uniform vec4 flash_color : source_color = vec4(1.0,0.62,0.18,1.0);`

### Candidatos / evidencia

- L6, `shader` (shader interno): `void fragment(){ float d=length((UV-0.5)*2.0); float halo=exp(-d*d*5.0); COLOR=vec4(flash_color.rgb,halo*pow(1.0-progress,2.0)*strength); }`

## shaders/boss_laser_glow.gdshader

15 líneas; 0 anotaciones export; 5 uniforms; 6 candidatos.

### Uniforms editables

- L3: `uniform float phase=0.0;`
- L4: `uniform float world_length=1000.0;`
- L5: `uniform float intensity=1.0;`
- L6: `uniform float ripple_strength : hint_range(0.0,0.2) = 0.06;`
- L7: `uniform vec4 glow_color : source_color = vec4(1.0,0.32,0.025,1.0);`

### Candidatos / evidencia

- L9, `shader` (shader interno): `float x=UV.x*world_length/75.0;`
- L10, `shader` (shader interno): `float y=abs(UV.y-0.5)*2.0;`
- L11, `shader` (shader interno): `float ripple=1.0-ripple_strength+ripple_strength*sin(x*2.1-phase*5.0);`
- L12, `shader` (shader interno): `float halo=exp(-y*y*16.0)*0.66+exp(-y*y*5.0)*0.14;`
- L13, `shader` (shader interno): `float ends=smoothstep(0.0,0.004,UV.x)*(1.0-smoothstep(0.996,1.0,UV.x));`
- L14, `shader` (shader interno): `COLOR=vec4(glow_color.rgb,clamp(halo*intensity*ripple*ends,0.0,1.0));`

## shaders/boss_laser_warning.gdshader

44 líneas; 0 anotaciones export; 13 uniforms; 25 candidatos.

### Uniforms editables

- L3: `uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;`
- L4: `uniform float phase = 0.0;`
- L5: `uniform bool oval = false;`
- L6: `uniform float warning_progress : hint_range(0.0,1.0) = 0.0;`
- L7: `uniform float world_length = 1000.0;`
- L8: `uniform float distortion_pixels : hint_range(0.0,50.0) = 22.0;`
- L9: `uniform float initial_intensity : hint_range(0.0,1.0) = 0.2;`
- L10: `uniform float initial_edge_brightness : hint_range(0.0,1.0) = 0.25;`
- L11: `uniform float peak_progress : hint_range(0.1,1.0) = 0.92;`
- L12: `uniform float refraction_split_pixels : hint_range(0.0,5.0) = 1.6;`
- L13: `uniform vec4 edge_red : source_color = vec4(0.8,0.10,0.018,1.0);`
- L14: `uniform vec4 edge_orange : source_color = vec4(1.0,0.48,0.045,1.0);`
- L15: `uniform vec4 edge_yellow : source_color = vec4(1.0,0.78,0.23,1.0);`

### Candidatos / evidencia

- L16, `shader` (shader interno): `varying vec2 screen_normal;`
- L18, `shader` (shader interno): `screen_normal=normalize((CANVAS_MATRIX*MODEL_MATRIX*vec4(0.0,1.0,0.0,0.0)).xy);`
- L21, `shader` (shader interno): `float ramp=smoothstep(0.0,peak_progress,warning_progress);`
- L22, `shader` (shader interno): `float intensity=mix(initial_intensity,1.0,ramp);`
- L23, `shader` (shader interno): `float brightness=mix(initial_edge_brightness,1.0,ramp);`
- L24, `shader` (shader interno): `float x=UV.x*world_length/75.0;`
- L25, `shader` (shader interno): `float across=oval ? length((UV-0.5)*2.0) : abs(UV.y-0.5)*2.0;`
- L26, `shader` (shader interno): `float envelope=1.0-smoothstep(0.65,1.0,across);`
- L27, `shader` (shader interno): `float ends=oval ? 1.0 : smoothstep(0.0,0.006,UV.x)*(1.0-smoothstep(0.994,1.0,UV.x));`
- L28, `shader` (shader interno): `float turbulence=sin(x*3.1-phase*7.0+sin(UV.y*10.0+phase*3.0))*0.58+sin(x*7.3+phase*5.4+UV.y*14.0)*0.28+sin(x*13.0-phase*9.0)*0.14;`
- L29, `shader` (shader interno): `vec2 tangent=vec2(-screen_normal.y,screen_normal.x);`
- L30, `shader` (shader interno): `float strength=distortion_pixels*1.2*intensity*envelope;`
- L31, `shader` (shader interno): `vec2 offset=(screen_normal*turbulence+tangent*sin(x*4.0+phase*5.0)*0.28)*strength*SCREEN_PIXEL_SIZE;`
- L32, `shader` (shader interno): `vec2 sample_uv=clamp(SCREEN_UV+offset,SCREEN_PIXEL_SIZE,vec2(1.0)-SCREEN_PIXEL_SIZE);`
- L33, `shader` (shader interno): `vec2 split=screen_normal*refraction_split_pixels*intensity*envelope*SCREEN_PIXEL_SIZE;`
- L34, `shader` (shader interno): `vec3 refracted=vec3(texture(screen_texture,sample_uv+split).r,texture(screen_texture,sample_uv).g,texture(screen_texture,sample_uv-split).b);`
- L35, `shader` (shader interno): `float edge=exp(-pow((across-0.87)*13.0,2.0));`
- L36, `shader` (shader interno): `float glow=exp(-pow((across-0.83)*4.0,2.0));`
- L37, `shader` (shader interno): `float flicker=0.8+0.2*sin(x*3.7-phase*8.0);`
- L38, `shader` (shader interno): `vec3 heat=mix(edge_red.rgb,edge_orange.rgb,0.55+0.4*ramp);`
- L39, `shader` (shader interno): `heat=mix(heat,edge_yellow.rgb,edge*0.4*flicker);`
- L40, `shader` (shader interno): `vec3 color=mix(refracted,edge_red.rgb,0.045*intensity*envelope);`
- L41, `shader` (shader interno): `color=mix(color,heat,clamp((edge*0.95*flicker+glow*0.18)*brightness,0.0,1.0));`
- L42, `shader` (shader interno): `float alpha=(1.0-smoothstep(0.97,1.0,across))*ends;`
- L43, `shader` (shader interno): `COLOR=vec4(color,alpha);`

## shaders/burning_flame_sprite.gdshader

31 líneas; 0 anotaciones export; 9 uniforms; 12 candidatos.

### Uniforms editables

- L3: `uniform sampler2D flame_texture : source_color, filter_linear, repeat_disable;`
- L4: `uniform float elapsed = 0.0;`
- L5: `uniform float fade = 1.0;`
- L6: `uniform float opacity = 0.85;`
- L7: `uniform float size_pulse = 0.22;`
- L8: `uniform float flicker_speed = 1.0;`
- L9: `uniform float distortion_strength = 0.018;`
- L10: `uniform float distortion_frequency = 38.0;`
- L11: `uniform float distortion_speed = 2.2;`

### Candidatos / evidencia

- L16, `shader` (shader interno): `float pulse = sin(time*INSTANCE_CUSTOM.g*6.2831853+phase);`
- L17, `shader` (shader interno): `float flip = mod(floor(time/max(0.1,INSTANCE_CUSTOM.b)+phase),2.0) < 1.0 ? 1.0 : -1.0;`
- L18, `shader` (shader interno): `VERTEX.x *= (1.0-pulse*size_pulse*0.45)*flip;`
- L19, `shader` (shader interno): `VERTEX.y *= 1.0+pulse*size_pulse;`
- L22, `shader` (shader interno): `// QuadMesh uses 3D UV orientation; invert Y for upright 2D flame artwork.`
- L23, `shader` (shader interno): `vec2 uv = vec2(UV.x,1.0-UV.y);`
- L24, `shader` (shader interno): `float anchored = 1.0-smoothstep(0.75,1.0,uv.y);`
- L25, `shader` (shader interno): `float wave = sin(uv.y*distortion_frequency-elapsed*distortion_speed*3.0+phase);`
- L26, `shader` (shader interno): `wave += sin(uv.y*distortion_frequency*1.7+elapsed*distortion_speed*2.0+phase*2.0)*0.35;`
- L28, `shader` (shader interno): `uv.y += sin(uv.x*distortion_frequency+elapsed*distortion_speed+phase)*distortion_strength*0.2*anchored;`
- L29, `shader` (shader interno): `vec4 paint = texture(flame_texture,uv);`
- L30, `shader` (shader interno): `COLOR *= vec4(paint.rgb,paint.a*opacity*fade);`

## shaders/burning_unit.gdshader

47 líneas; 0 anotaciones export; 14 uniforms; 21 candidatos.

### Uniforms editables

- L3: `uniform vec4 heat_color : source_color = vec4(1.0,0.35,0.05,1.0);`
- L4: `uniform vec4 core_color : source_color = vec4(1.0,0.82,0.416,1.0);`
- L5: `uniform float elapsed = 0.0;`
- L6: `uniform float variation = 0.0;`
- L7: `uniform float fade = 1.0;`
- L8: `uniform float flicker_speed = 1.0;`
- L9: `uniform int ember_count = 16;`
- L10: `uniform float ember_size = 0.008;`
- L11: `uniform float ember_opacity = 0.65;`
- L12: `uniform float heat_opacity = 0.16;`
- L13: `uniform bool coverage_enabled = false;`
- L14: `uniform int coverage_count = 0;`
- L15: `uniform vec2 coverage_extents[6];`
- L16: `uniform float coverage_weights[6];`

### Candidatos / evidencia

- L17, `shader` (shader interno): `float coverage_at(vec2 point) {`
- L18, `shader` (shader interno): `if (!coverage_enabled) { return 1.0; }`
- L19, `shader` (shader interno): `float density = 0.0;`
- L20, `shader` (shader interno): `for (int i = 0; i < 6; i++) {`
- L22, `shader` (shader interno): `density += (1.0 - smoothstep(0.82, 1.0, length(point / max(coverage_extents[i], vec2(0.001))))) * coverage_weights[i];`
- L24, `shader` (shader interno): `return min(density, 1.0) * (1.0 + max(density - 1.0, 0.0) * 0.14);`
- L27, `shader` (shader interno): `vec2 p = UV;`
- L29, `shader` (shader interno): `float embers = 0.0;`
- L30, `shader` (shader interno): `for (int i = 0; i < 32; i++) {`
- L33, `shader` (shader interno): `float cycle = time*mix(0.6,1.1,fract(seed*0.41421))+seed*0.618034;`
- L35, `shader` (shader interno): `float x = mix(0.2,0.8,fract(seed*0.754877+floor(cycle)*0.37+variation));`
- L36, `shader` (shader interno): `vec2 center = vec2(x+sin(age*5.0+seed)*0.04,0.76-age*0.65);`
- L37, `shader` (shader interno): `float size = ember_size*mix(0.5,1.5,fract(seed*0.56984));`
- L38, `shader` (shader interno): `float life = smoothstep(0.0,0.12,age)*(1.0-smoothstep(0.5,1.0,age));`
- L39, `shader` (shader interno): `embers += exp(-pow(length((p-center)*vec2(1.0,0.7))/size,2.0))*life*coverage_at(vec2((x-0.5)*2.0,0.0));`
- L41, `shader` (shader interno): `vec2 aura_p = (p-vec2(0.5,0.80))/vec2(0.43,0.14);`
- L42, `shader` (shader interno): `float aura = exp(-dot(aura_p,aura_p)*2.0)*heat_opacity*(0.85+0.15*sin(time*4.0+variation));`
- L43, `shader` (shader interno): `aura *= coverage_at((p-vec2(0.5,0.80))*2.0);`
- L44, `shader` (shader interno): `float alpha = 1.0-(1.0-clamp(embers*ember_opacity,0.0,1.0))*(1.0-aura);`
- L45, `shader` (shader interno): `vec3 tint = mix(heat_color.rgb,core_color.rgb,clamp(embers*0.4,0.0,0.8));`
- L46, `shader` (shader interno): `COLOR = vec4(tint,alpha*fade*heat_color.a);`

## shaders/electric_bolts.gdshader

59 líneas; 0 anotaciones export; 2 uniforms; 35 candidatos.

### Uniforms editables

- L3: `uniform float ray_count = 7.0;`
- L4: `uniform bool burst_mode = false;`

### Candidatos / evidencia

- L8, `shader` (shader interno): `vec2 aura_point(int index, vec2 start, vec2 direction, vec2 tangent, float jitter) {`
- L9, `shader` (shader interno): `if (index==0) return start;`
- L10, `shader` (shader interno): `if (index==1) return start+tangent*5.0+direction*4.0;`
- L11, `shader` (shader interno): `if (index==2) return start+tangent*10.0-direction*(4.0+jitter);`
- L12, `shader` (shader interno): `return start+tangent*16.0+direction*5.0;`
- L14, `shader` (shader interno): `vec2 burst_point(int index, vec2 direction, vec2 side, float reach, float wobble) {`
- L15, `shader` (shader interno): `if (index==0) return direction*reach*0.12;`
- L16, `shader` (shader interno): `if (index==1) return direction*reach*0.38+side*wobble;`
- L17, `shader` (shader interno): `if (index==2) return direction*reach*0.58-side*wobble;`
- L18, `shader` (shader interno): `if (index==3) return direction*reach*0.78+side*3.0;`
- L22, `shader` (shader interno): `vec2 corner = VERTEX;`
- L26, `shader` (shader interno): `vec2 a;`
- L27, `shader` (shader interno): `vec2 b;`
- L29, `shader` (shader interno): `float angle = 6.28318530718*ray/ray_count+0.19;`
- L30, `shader` (shader interno): `vec2 direction = vec2(cos(angle),sin(angle)*0.6);`
- L31, `shader` (shader interno): `vec2 side = vec2(-direction.y,direction.x);`
- L32, `shader` (shader interno): `float reach = INSTANCE_CUSTOM.x*(0.65+INSTANCE_CUSTOM.y*0.65);`
- L33, `shader` (shader interno): `float wobble = sin(ray*13.7+floor(elapsed*35.0)*2.1)*6.0;`
- L35, `shader` (shader interno): `b = burst_point(segment+1,direction,side,reach,wobble);`
- L37, `shader` (shader interno): `float frame = floor(elapsed*18.0);`
- L38, `shader` (shader interno): `float angle = 6.28318530718*ray/ray_count+frame*0.17;`
- L39, `shader` (shader interno): `vec2 direction = vec2(cos(angle),sin(angle));`
- L40, `shader` (shader interno): `vec2 tangent = vec2(-direction.y,direction.x);`
- L41, `shader` (shader interno): `vec2 start = direction*INSTANCE_CUSTOM.xy*0.75;`
- L42, `shader` (shader interno): `float jitter = sin(frame*3.1+ray*9.7)*5.0;`
- L44, `shader` (shader interno): `b = aura_point(segment+1,start,direction,tangent,jitter);`
- L45, `shader` (shader interno): `COLOR.a *= 0.7+0.3*sin(elapsed*35.0+ray);`
- L47, `shader` (shader interno): `vec2 axis = (b-a)/max(0.00001,length(b-a));`
- L48, `shader` (shader interno): `VERTEX = mix(a,b,corner.x)+axis*(corner.x-0.5)*1.5+vec2(-axis.y,axis.x)*corner.y*12.0;`
- L49, `shader` (shader interno): `across = corner.y*2.0;`
- L54, `shader` (shader interno): `float glow = exp(-edge*edge*5.0)*0.24*glow_strength;`
- L55, `shader` (shader interno): `float body = 1.0-smoothstep(0.15,0.27,edge);`
- L56, `shader` (shader interno): `float core = 1.0-smoothstep(0.045,0.10,edge);`
- L57, `shader` (shader interno): `vec3 color = mix(COLOR.rgb,vec3(0.88,0.98,1.0),core);`
- L58, `shader` (shader interno): `COLOR = vec4(color,COLOR.a*(glow+body*0.7+core*0.5));`

## shaders/electric_ray.gdshader

12 líneas; 0 anotaciones export; 0 uniforms; 6 candidatos.

### Candidatos / evidencia

- L6, `shader` (shader interno): `float edge = abs(UV.y*2.0-1.0);`
- L7, `shader` (shader interno): `float glow = exp(-edge*edge*5.0)*0.24*glow_strength;`
- L8, `shader` (shader interno): `float body = 1.0-smoothstep(0.15,0.27,edge);`
- L9, `shader` (shader interno): `float core = 1.0-smoothstep(0.045,0.10,edge);`
- L10, `shader` (shader interno): `vec3 color = mix(COLOR.rgb,vec3(0.88,0.98,1.0),core);`
- L11, `shader` (shader interno): `COLOR = vec4(color,COLOR.a*(glow+body*0.7+core*0.5));`

## shaders/fire_column_base.gdshader

20 líneas; 0 anotaciones export; 5 uniforms; 9 candidatos.

### Uniforms editables

- L3: `uniform vec4 flame_color : source_color = vec4(1.0,0.18,0.025,1.0);`
- L4: `uniform vec4 core_color : source_color = vec4(1.0,0.87,0.35,1.0);`
- L5: `uniform float elapsed = 0.0;`
- L6: `uniform float fade = 1.0;`
- L7: `uniform float opacity = 0.65;`

### Candidatos / evidencia

- L9, `shader` (shader interno): `vec2 p = UV*2.0-1.0;`
- L12, `shader` (shader interno): `float flicker = 0.88+0.12*sin(elapsed*13.0+a*8.0);`
- L13, `shader` (shader interno): `float hot = (1.0-smoothstep(0.0,0.9,r))*0.62;`
- L14, `shader` (shader interno): `float edge = exp(-pow((r-0.86)/0.08,2.0))*flicker;`
- L15, `shader` (shader interno): `float ripple_r = fract(elapsed*2.2)*0.8+0.12;`
- L16, `shader` (shader interno): `float ripple = exp(-pow((r-ripple_r)/0.055,2.0))*(1.0-ripple_r)*0.3;`
- L17, `shader` (shader interno): `float limit = 1.0-smoothstep(0.93,1.0,r);`
- L18, `shader` (shader interno): `vec3 tint = mix(flame_color.rgb,core_color.rgb,clamp(hot+edge*0.85+ripple,0.0,1.0));`
- L19, `shader` (shader interno): `COLOR = vec4(tint,(hot+edge+ripple)*limit*opacity*fade);`

## shaders/fire_column_contact.gdshader

17 líneas; 0 anotaciones export; 5 uniforms; 7 candidatos.

### Uniforms editables

- L3: `uniform float elapsed = 0.0;`
- L4: `uniform float opacity = 0.95;`
- L5: `uniform float fade = 1.0;`
- L6: `uniform float distortion = 0.06;`
- L7: `uniform float front_start = 0.56;`

### Candidatos / evidencia

- L9, `shader` (shader interno): `vec2 uv = UV;`
- L11, `shader` (shader interno): `float front = smoothstep(front_start,front_start+0.065,UV.y);`
- L12, `shader` (shader interno): `float anchored = 1.0-smoothstep(0.84,1.0,UV.y);`
- L13, `shader` (shader interno): `uv.x += sin(uv.y*32.0-elapsed*7.0)*distortion*0.25*anchored;`
- L14, `shader` (shader interno): `uv.y += sin(uv.x*24.0+elapsed*8.0)*distortion*0.1*anchored;`
- L15, `shader` (shader interno): `vec4 paint = texture(TEXTURE,uv);`
- L16, `shader` (shader interno): `COLOR *= vec4(paint.rgb,paint.a*front*opacity*fade);`

## shaders/fire_column_fill.gdshader

35 líneas; 0 anotaciones export; 10 uniforms; 14 candidatos.

### Uniforms editables

- L3: `uniform float elapsed = 0.0;`
- L4: `uniform float opacity = 0.96;`
- L5: `uniform float fade = 1.0;`
- L6: `uniform float distortion = 0.025;`
- L7: `uniform float flow_speed = 1.8;`
- L8: `uniform float base_roundness = 0.05;`
- L9: `uniform float world_height = 800.0;`
- L10: `uniform float base_depth = 0.0;`
- L11: `uniform float flare_height = 750.0;`
- L12: `uniform float top_width_multiplier = 2.1;`

### Candidatos / evidencia

- L19, `shader` (shader interno): `vec2 uv = UV;`
- L21, `shader` (shader interno): `float height = max(0.0,(1.0-UV.y)*world_height-base_depth);`
- L22, `shader` (shader interno): `float flare = pow(clamp(height/max(1.0,flare_height),0.0,1.0),0.8);`
- L23, `shader` (shader interno): `float width = mix(1.0,top_width_multiplier,flare);`
- L24, `shader` (shader interno): `uv.x = (UV.x-0.5)*top_width_multiplier/width+0.5;`
- L26, `shader` (shader interno): `uv.x += (sin(UV.y*19.0-time*1.8)*0.65+sin(UV.y*33.0+time*1.2)*0.35)*distortion;`
- L27, `shader` (shader interno): `uv.y = UV.y*0.8+0.1+sin(time*0.65)*0.075;`
- L28, `shader` (shader interno): `vec4 paint = texture(TEXTURE,uv);`
- L29, `shader` (shader interno): `float x = clamp((uv.x-0.5)/0.36,-1.0,1.0);`
- L30, `shader` (shader interno): `float bottom = 1.0-base_roundness*(1.0-sqrt(max(0.0,1.0-x*x)));`
- L31, `shader` (shader interno): `float mask = 1.0-smoothstep(bottom-0.006,bottom,UV.y);`
- L32, `shader` (shader interno): `float tip = 0.04+0.08*(0.5+0.5*sin(uv.x*37.0+sin(time*0.8)))+0.035*(0.5+0.5*sin(uv.x*73.0-time*1.2));`
- L33, `shader` (shader interno): `mask *= smoothstep(tip,tip+0.035,UV.y);`
- L34, `shader` (shader interno): `COLOR *= vec4(paint.rgb,paint.a*opacity*fade*mask);`

## shaders/fire_column_heat.gdshader

29 líneas; 0 anotaciones export; 9 uniforms; 11 candidatos.

### Uniforms editables

- L3: `uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;`
- L4: `uniform float elapsed = 0.0;`
- L5: `uniform float fade = 1.0;`
- L6: `uniform float opacity = 0.85;`
- L7: `uniform float strength_pixels = 8.0;`
- L8: `uniform float world_height = 800.0;`
- L9: `uniform float flare_height = 750.0;`
- L10: `uniform float top_width_multiplier = 2.1;`
- L11: `uniform float base_depth = 0.0;`

### Candidatos / evidencia

- L16, `shader` (shader interno): `vec2 p = UV*2.0-1.0;`
- L17, `shader` (shader interno): `float height = max(0.0,(1.0-UV.y)*world_height-base_depth);`
- L18, `shader` (shader interno): `float flare = pow(clamp(height/max(1.0,flare_height),0.0,1.0),0.8);`
- L19, `shader` (shader interno): `p.x *= top_width_multiplier/mix(1.0,top_width_multiplier,flare);`
- L21, `shader` (shader interno): `float sides = exp(-pow((abs(p.x)-0.57)/0.25,2.0));`
- L22, `shader` (shader interno): `float vertical = smoothstep(0.0,0.03,UV.y)*(1.0-smoothstep(0.94,1.0,UV.y));`
- L24, `shader` (shader interno): `float flow = UV.y*world_height*0.035;`
- L25, `shader` (shader interno): `vec2 wave = vec2(sin(flow-time*7.0+p.x*4.0)+sin(flow*1.73-time*4.0)*0.35, cos(flow*0.83-time*5.0+p.x*6.0)*0.45);`
- L26, `shader` (shader interno): `vec2 offset = wave*SCREEN_PIXEL_SIZE*strength_pixels*mask;`
- L27, `shader` (shader interno): `vec3 scene = texture(screen_texture,SCREEN_UV+offset).rgb;`
- L28, `shader` (shader interno): `COLOR = vec4(scene,mask);`

## shaders/fire_column_ring.gdshader

46 líneas; 0 anotaciones export; 15 uniforms; 17 candidatos.

### Uniforms editables

- L3: `uniform sampler2D ring_texture : source_color, filter_linear_mipmap, repeat_disable;`
- L4: `uniform float elapsed = 0.0;`
- L5: `uniform float opacity = 0.48;`
- L6: `uniform float fade = 1.0;`
- L7: `uniform float center_opacity = 0.28;`
- L8: `uniform float distortion = 0.045;`
- L9: `uniform float flow_speed = 1.8;`
- L10: `uniform sampler2D body_texture : source_color, filter_linear_mipmap, repeat_disable;`
- L11: `uniform float body_height = 800.0;`
- L12: `uniform float body_depth = 30.0;`
- L13: `uniform float body_width = 140.0;`
- L14: `uniform float flare_height = 750.0;`
- L15: `uniform float top_width_multiplier = 2.1;`
- L16: `uniform vec2 column_screen_origin = vec2(0.0);`
- L17: `uniform vec2 column_screen_scale = vec2(1.0);`

### Candidatos / evidencia

- L24, `shader` (shader interno): `vec2 uv = vec2(UV.x,1.0-UV.y);`
- L25, `shader` (shader interno): `if (mod(floor(phase),2.0)>0.5) { uv.x = 1.0-uv.x; }`
- L27, `shader` (shader interno): `float anchored = 1.0-smoothstep(0.75,1.0,uv.y);`
- L28, `shader` (shader interno): `uv.x += (sin(uv.y*29.0-time*4.0+phase)+sin(uv.y*47.0+time*3.0+phase)*0.3)*distortion*anchored*0.55;`
- L29, `shader` (shader interno): `uv.y += sin(uv.x*25.0+time*4.0+phase)*distortion*0.16*anchored;`
- L30, `shader` (shader interno): `vec4 paint = texture(ring_texture,uv);`
- L33, `shader` (shader interno): `vec2 point = (SCREEN_UV/SCREEN_PIXEL_SIZE-column_screen_origin)/column_screen_scale;`
- L36, `shader` (shader interno): `float scale_x = mix(1.0,top_width_multiplier,pow(clamp(max(0.0,height)/max(1.0,flare_height),0.0,1.0),0.8));`
- L37, `shader` (shader interno): `vec2 body_uv = vec2(point.x/(body_width*scale_x)+0.5,body_y);`
- L38, `shader` (shader interno): `body_uv.x += (sin(body_y*19.0-time*1.8)*0.65+sin(body_y*33.0+time*1.2)*0.35)*distortion;`
- L39, `shader` (shader interno): `body_uv.y = body_y*0.8+0.1+sin(time*0.65)*0.075;`
- L40, `shader` (shader interno): `float body_mask = smoothstep(0.05,0.55,texture(body_texture,body_uv).a);`
- L41, `shader` (shader interno): `body_mask *= step(0.0,body_y)*step(body_y,1.0);`
- L42, `shader` (shader interno): `float tip = 0.04+0.08*(0.5+0.5*sin(body_uv.x*37.0+sin(time*0.8)))+0.035*(0.5+0.5*sin(body_uv.x*73.0-time*1.2));`
- L43, `shader` (shader interno): `body_mask *= smoothstep(tip,tip+0.035,body_y);`
- L44, `shader` (shader interno): `float flicker = 0.9+0.1*sin(time*5.0+phase);`
- L45, `shader` (shader interno): `COLOR *= vec4(paint.rgb,paint.a*body_mask*opacity*fade*flicker*mix(center_opacity,1.0,smoothstep(0.15,0.85,abs(UV.x-0.5)*2.0)));`

## shaders/fire_column_spark.gdshader

12 líneas; 0 anotaciones export; 0 uniforms; 8 candidatos.

### Candidatos / evidencia

- L4, `shader` (shader interno): `vec2 p = UV*2.0-1.0;`
- L5, `shader` (shader interno): `float r2 = dot(p,p);`
- L6, `shader` (shader interno): `float core = exp(-r2*12.0);`
- L7, `shader` (shader interno): `float ember = exp(-r2*4.0);`
- L8, `shader` (shader interno): `float glow = exp(-r2*1.7)*0.17;`
- L9, `shader` (shader interno): `float edge = 1.0-smoothstep(0.7,1.0,length(p));`
- L10, `shader` (shader interno): `vec3 tint = mix(COLOR.rgb,vec3(1.0,0.97,0.65),core*0.8);`
- L11, `shader` (shader interno): `COLOR = vec4(tint,clamp(core+ember*0.65+glow,0.0,1.0)*edge*COLOR.a);`

## shaders/ghost_cloud.gdshader

20 líneas; 0 anotaciones export; 6 uniforms; 6 candidatos.

### Uniforms editables

- L3: `uniform sampler2D cloud_texture : source_color, filter_linear_mipmap, repeat_disable;`
- L4: `uniform float elapsed = 0.0;`
- L5: `uniform float fade = 1.0;`
- L6: `uniform float opacity = 0.62;`
- L7: `uniform float distortion = 0.018;`
- L8: `uniform float billow_speed = 0.65;`

### Candidatos / evidencia

- L13, `shader` (shader interno): `vec2 uv = vec2(UV.x,1.0-UV.y);`
- L14, `shader` (shader interno): `if (mirror>0.5) { uv.x = 1.0-uv.x; }`
- L16, `shader` (shader interno): `uv.x += sin(uv.y*13.0+time*1.7+phase)*distortion;`
- L17, `shader` (shader interno): `uv.y += sin(uv.x*15.0-time*1.4+phase)*distortion*0.55;`
- L18, `shader` (shader interno): `vec4 paint = texture(cloud_texture,uv);`
- L19, `shader` (shader interno): `COLOR *= vec4(paint.rgb,pow(paint.a,1.25)*opacity*fade*(0.82+0.18*sin(uv.x*5.0+uv.y*7.0+time+phase)));`

## shaders/ghost_cloud_ground.gdshader

9 líneas; 0 anotaciones export; 2 uniforms; 3 candidatos.

### Uniforms editables

- L3: `uniform vec4 tint : source_color = vec4(0.8,0.18,0.15,1.0);`
- L4: `uniform float fade = 1.0;`

### Candidatos / evidencia

- L6, `shader` (shader interno): `float r = length(UV*2.0-1.0);`
- L7, `shader` (shader interno): `float fog = (1.0-smoothstep(0.3,1.0,r))*0.18;`
- L8, `shader` (shader interno): `COLOR = vec4(tint.rgb,fog*fade*tint.a);`

## shaders/habanero_blast.gdshader

42 líneas; 0 anotaciones export; 9 uniforms; 24 candidatos.

### Uniforms editables

- L3: `uniform float progress = 0.0;`
- L4: `uniform bool detonated = false;`
- L5: `uniform vec4 heat_color : source_color = vec4(1.0,0.33,0.035,1.0);`
- L6: `uniform vec4 core_color : source_color = vec4(1.0,0.945,0.678,1.0);`
- L7: `uniform vec4 flame_color : source_color = vec4(1.0,0.314,0.114,1.0);`
- L8: `uniform float opacity = 0.75;`
- L9: `uniform float anticipation_opacity = 0.4;`
- L10: `uniform float flame_strength = 1.0;`
- L11: `uniform float variation = 0.0;`

### Candidatos / evidencia

- L13, `shader` (shader interno): `vec2 p = (UV*2.0-1.0)*1.35;`
- L16, `shader` (shader interno): `float t = clamp(progress,0.0,1.0);`
- L17, `shader` (shader interno): `vec3 tint = heat_color.rgb;`
- L18, `shader` (shader interno): `float alpha = 0.0;`
- L20, `shader` (shader interno): `float gathering = mix(0.75,0.30,t);`
- L21, `shader` (shader interno): `float inward = exp(-pow((r-gathering)/0.10,2.0));`
- L22, `shader` (shader interno): `float heat = exp(-r*r/0.22);`
- L23, `shader` (shader interno): `float flecks = pow(max(0.0,sin(angle*9.0+variation+t*3.0)),12.0);`
- L24, `shader` (shader interno): `alpha = (heat*0.6+inward*(0.22+flecks*0.3))*smoothstep(0.0,0.4,t)*anticipation_opacity;`
- L25, `shader` (shader interno): `tint = mix(heat_color.rgb,core_color.rgb,t*0.22*heat);`
- L27, `shader` (shader interno): `float expansion = mix(0.30,0.92,1.0-pow(1.0-t,3.0));`
- L28, `shader` (shader interno): `float lobes = pow(0.5+0.5*sin(angle*9.0+variation-t*7.0),3.0);`
- L29, `shader` (shader interno): `float small_lobes = 0.5+0.5*sin(angle*17.0-variation+t*11.0);`
- L30, `shader` (shader interno): `float fire_edge = expansion + (lobes*0.16+small_lobes*0.045)*(1.0-t)*flame_strength;`
- L31, `shader` (shader interno): `float body = 1.0-smoothstep(fire_edge*0.55,fire_edge,r);`
- L32, `shader` (shader interno): `float contour = exp(-pow((r-fire_edge)/0.065,2.0));`
- L33, `shader` (shader interno): `float outer_glow = exp(-pow((r-fire_edge)/0.17,2.0))*0.25;`
- L34, `shader` (shader interno): `float core = exp(-r*r/max(0.015,expansion*expansion*0.25));`
- L35, `shader` (shader interno): `float flash = exp(-t*8.0);`
- L36, `shader` (shader interno): `float fade = 1.0-smoothstep(0.35,1.0,t);`
- L37, `shader` (shader interno): `alpha = (body*0.65+contour*0.8+outer_glow+core*flash)*fade*opacity;`
- L38, `shader` (shader interno): `tint = mix(flame_color.rgb,heat_color.rgb,body*0.65);`
- L39, `shader` (shader interno): `tint = mix(tint,core_color.rgb,clamp(core*(0.65+flash)+contour*0.22,0.0,1.0));`
- L41, `shader` (shader interno): `COLOR = vec4(tint,clamp(alpha,0.0,1.0)*heat_color.a);`

## shaders/hot_zone_air.gdshader

25 líneas; 0 anotaciones export; 5 uniforms; 14 candidatos.

### Uniforms editables

- L2: `uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;`
- L3: `uniform float phase = 0.0;`
- L4: `uniform float intensity : hint_range(0.0, 1.0) = 1.0;`
- L5: `uniform float strength_pixels : hint_range(0.0, 20.0) = 5.5;`
- L6: `uniform float vertical_strength_pixels : hint_range(0.0, 10.0) = 1.5;`

### Candidatos / evidencia

- L7, `shader` (shader interno): `float hash(vec2 p) {`
- L8, `shader` (shader interno): `return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);`
- L10, `shader` (shader interno): `float flow(vec2 p) {`
- L11, `shader` (shader interno): `vec2 cell = floor(p);`
- L12, `shader` (shader interno): `vec2 f = fract(p);`
- L13, `shader` (shader interno): `f = f * f * (3.0 - 2.0 * f);`
- L14, `shader` (shader interno): `return mix(mix(hash(cell), hash(cell + vec2(1, 0)), f.x), mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1, 1)), f.x), f.y) * 2.0 - 1.0;`
- L17, `shader` (shader interno): `vec2 p = UV * 2.0 - 1.0;`
- L18, `shader` (shader interno): `float envelope = 1.0 - smoothstep(0.50, 1.0, length(p));`
- L19, `shader` (shader interno): `float mask = envelope * smoothstep(0.0, 0.30, UV.y) * (1.0 - smoothstep(0.85, 1.0, UV.y)) * intensity;`
- L21, `shader` (shader interno): `vec2 movement = vec2(phase * 0.13, phase * 1.2);`
- L22, `shader` (shader interno): `vec2 drift = vec2(flow(p * 7.0 + movement), flow(p * 5.0 + movement + vec2(19.3, 7.8)));`
- L23, `shader` (shader interno): `vec2 offset = drift * vec2(strength_pixels, vertical_strength_pixels) * SCREEN_PIXEL_SIZE * mask;`
- L24, `shader` (shader interno): `COLOR = vec4(texture(screen_texture, SCREEN_UV + offset).rgb, mask);`

## shaders/hot_zone_ground.gdshader

27 líneas; 0 anotaciones export; 10 uniforms; 12 candidatos.

### Uniforms editables

- L2: `uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;`
- L3: `uniform float phase = 0.0;`
- L4: `uniform float intensity : hint_range(0.0, 1.0) = 1.0;`
- L5: `uniform float shape_phase = 0.0;`
- L6: `uniform float breath : hint_range(0.0, 1.0) = 0.5;`
- L7: `uniform float damage_core_ratio : hint_range(0.2, 0.9) = 0.60;`
- L8: `uniform float zone_radius = 350.0;`
- L9: `uniform vec2 zone_center = vec2(0.0);`
- L10: `uniform vec4 arena_rect = vec4(-1021.5, -511.7, 2041.0, 1015.6);`
- L11: `uniform float arena_corner = 109.4;`

### Candidatos / evidencia

- L13, `shader` (shader interno): `vec2 p = UV * 2.0 - 1.0;`
- L15, `shader` (shader interno): `float boundary = 0.75 + 0.13 * sin(angle * 3.0 + shape_phase) + 0.08 * cos(angle * 2.0 - shape_phase * 0.7);`
- L17, `shader` (shader interno): `float halo = 1.0 - smoothstep(0.20, 1.0, r);`
- L18, `shader` (shader interno): `vec2 at = zone_center + p * zone_radius;`
- L19, `shader` (shader interno): `vec2 q = abs(at - (arena_rect.xy + arena_rect.zw * 0.5)) - (arena_rect.zw * 0.5 - vec2(arena_corner));`
- L20, `shader` (shader interno): `float floor_edge = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - arena_corner;`
- L21, `shader` (shader interno): `halo *= 1.0 - smoothstep(-8.0, 0.0, floor_edge);`
- L22, `shader` (shader interno): `float core = 1.0 - smoothstep(0.15, damage_core_ratio + 0.12, r);`
- L23, `shader` (shader interno): `vec3 metal = texture(screen_texture, SCREEN_UV).rgb;`
- L24, `shader` (shader interno): `vec3 warm_metal = metal * vec3(1.15, 0.74, 0.52);`
- L25, `shader` (shader interno): `vec3 emission = vec3(0.68, 0.18, 0.035) * core * mix(0.65, 1.0, breath);`
- L26, `shader` (shader interno): `COLOR = vec4(warm_metal + emission, halo * (0.32 + core * mix(0.28, 0.50, breath)) * intensity);`

## shaders/kitchen_torch_flame.gdshader

24 líneas; 0 anotaciones export; 2 uniforms; 14 candidatos.

### Uniforms editables

- L3: `uniform float phase = 0.0;`
- L4: `uniform float strand_length = 100.0;`

### Candidatos / evidencia

- L9, `shader` (shader interno): `float drift = sin(x*21.0-time*2.4)*0.035+sin(x*37.0-time*3.1)*0.018;`
- L10, `shader` (shader interno): `float y = abs(UV.y-0.5-drift*x);`
- L11, `shader` (shader interno): `float licks = sin(x*29.0-time*3.6)*0.028+sin(x*47.0-time*2.7)*0.018;`
- L12, `shader` (shader interno): `float width = mix(0.12,0.36,smoothstep(0.0,0.6,x));`
- L13, `shader` (shader interno): `width *= 1.0-smoothstep(0.72,1.0,x)*0.7;`
- L14, `shader` (shader interno): `width += licks*smoothstep(0.0,0.2,x);`
- L15, `shader` (shader interno): `float edge = 1.0-smoothstep(width*0.7,width,y);`
- L16, `shader` (shader interno): `float tail = 1.0-smoothstep(0.76,1.0,x+sin(UV.y*35.0-time*2.1)*0.045);`
- L18, `shader` (shader interno): `float border = smoothstep(0.0,0.035,x)*(1.0-smoothstep(0.965,1.0,x));`
- L19, `shader` (shader interno): `border *= smoothstep(0.0,0.05,UV.y)*(1.0-smoothstep(0.95,1.0,UV.y));`
- L20, `shader` (shader interno): `float core = 1.0-smoothstep(width*0.12,width*0.65,y);`
- L21, `shader` (shader interno): `vec3 color = mix(vec3(0.85,0.14,0.035),vec3(1.0,0.57,0.08),core);`
- L22, `shader` (shader interno): `color = mix(color,vec3(1.0,0.88,0.38),core*(1.0-smoothstep(0.15,0.85,x))*0.8);`
- L23, `shader` (shader interno): `COLOR = vec4(color,edge*tail*border*0.95);`

## shaders/locked_silhouette.gdshader

6 líneas; 0 anotaciones export; 1 uniforms; 0 candidatos.

### Uniforms editables

- L2: `uniform vec4 silhouette_color : source_color = vec4(0.12, 0.10, 0.09, 1.0);`


## shaders/mayonnaise_droplet.gdshader

8 líneas; 0 anotaciones export; 0 uniforms; 3 candidatos.

### Candidatos / evidencia

- L4, `shader` (shader interno): `float distance_from_center = length(UV * 2.0 - 1.0);`
- L5, `shader` (shader interno): `float softness = max(fwidth(distance_from_center), 0.025);`
- L6, `shader` (shader interno): `float coverage = 1.0 - smoothstep(1.0 - softness, 1.0, distance_from_center);`

## shaders/mayonnaise_stream.gdshader

18 líneas; 0 anotaciones export; 5 uniforms; 8 candidatos.

### Uniforms editables

- L3: `uniform vec4 mayo_color : source_color = vec4(1.0, 0.94, 0.75, 1.0);`
- L4: `uniform vec4 core_color : source_color = vec4(1.0, 0.99, 0.94, 1.0);`
- L5: `uniform vec4 edge_color : source_color = vec4(0.77, 0.71, 0.53, 1.0);`
- L6: `uniform float phase = 0.0;`
- L7: `uniform float strand_length = 100.0;`

### Candidatos / evidencia

- L10, `shader` (shader interno): `float flow = UV.x * strand_length * 0.09 - phase;`
- L11, `shader` (shader interno): `float thickness = 0.85 + 0.08 * sin(flow) + 0.055 * sin(flow * 1.73 + 1.2);`
- L12, `shader` (shader interno): `float edge = abs(UV.y * 2.0 - 1.0) / thickness;`
- L13, `shader` (shader interno): `float alpha = 1.0 - smoothstep(0.86, 1.0, edge);`
- L14, `shader` (shader interno): `float center = 1.0 - smoothstep(0.1, 0.72, edge);`
- L15, `shader` (shader interno): `vec3 cream = mix(edge_color.rgb, mayo_color.rgb, 1.0 - smoothstep(0.55, 0.95, edge));`
- L16, `shader` (shader interno): `cream = mix(cream, core_color.rgb, center * (0.85 + 0.1 * sin(flow * 0.65)));`
- L17, `shader` (shader interno): `COLOR = vec4(cream, alpha * mayo_color.a);`

## shaders/oil_translucency.gdshader

10 líneas; 0 anotaciones export; 0 uniforms; 5 candidatos.

### Candidatos / evidencia

- L3, `shader` (shader interno): `vec4 sprite = texture(TEXTURE, UV);`
- L6, `shader` (shader interno): `float outline = 1.0 - smoothstep(0.15, 0.30, brightest);`
- L7, `shader` (shader interno): `float highlight = smoothstep(0.88, 0.97, darkest);`
- L8, `shader` (shader interno): `float opacity = mix(0.32, 1.0, max(outline, highlight));`
- L9, `shader` (shader interno): `COLOR.a *= opacity * smoothstep(0.06, 0.18, sprite.a);`

## shaders/oil_water_background.gdshader

37 líneas; 0 anotaciones export; 9 uniforms; 16 candidatos.

### Uniforms editables

- L2: `uniform vec4 color_a : source_color = vec4(0.70, 0.66, 0.62, 1.0);`
- L3: `uniform vec4 color_b : source_color = vec4(0.74, 0.70, 0.66, 1.0);`
- L4: `uniform float speed : hint_range(0.0, 1.0) = 0.16;`
- L5: `uniform float pattern_scale : hint_range(0.5, 6.0) = 2.0;`
- L6: `uniform float flow_strength : hint_range(0.0, 3.0) = 2.0;`
- L7: `uniform float pattern_world_size : hint_range(200.0, 4000.0) = 1600.0;`
- L8: `uniform float edge_softness : hint_range(0.0, 0.2) = 0.015;`
- L9: `uniform float seed = 0.0;`
- L10: `uniform float phase = 0.0;`

### Candidatos / evidencia

- L11, `shader` (shader interno): `varying vec2 world_position;`
- L13, `shader` (shader interno): `world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;`
- L15, `shader` (shader interno): `float hash(vec2 p) {`
- L16, `shader` (shader interno): `vec3 value = fract(vec3(p.xyx) * 0.1031 + seed * 0.013);`
- L17, `shader` (shader interno): `value += dot(value, value.yzx + 33.33);`
- L20, `shader` (shader interno): `float noise(vec2 p) {`
- L21, `shader` (shader interno): `vec2 cell = floor(p);`
- L22, `shader` (shader interno): `vec2 f = fract(p);`
- L23, `shader` (shader interno): `f = f * f * (3.0 - 2.0 * f);`
- L24, `shader` (shader interno): `return mix(mix(hash(cell), hash(cell + vec2(1, 0)), f.x), mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1, 1)), f.x), f.y);`
- L27, `shader` (shader interno): `vec2 p = world_position / pattern_world_size * pattern_scale;`
- L29, `shader` (shader interno): `float n = noise(p * 1.1 + vec2(t * 0.17, -t * 0.12));`
- L30, `shader` (shader interno): `float angle = flow_strength * (n - 0.5) * 2.0 + 0.35 * sin(t * 0.5 + length(p));`
- L31, `shader` (shader interno): `p = mat2(vec2(cos(angle), sin(angle)), vec2(-sin(angle), cos(angle))) * p;`
- L32, `shader` (shader interno): `p += vec2(sin(p.y * 1.7 + t + n * 3.0), cos(p.x * 1.6 - t * 0.7 + n * 2.0)) * flow_strength * 0.45;`
- L33, `shader` (shader interno): `float marble = sin(p.x * 2.2 + p.y * 1.3 + noise(p * 1.8 - t * 0.08) * 5.0);`

## shaders/outline.gdshader

26 líneas; 0 anotaciones export; 3 uniforms; 12 candidatos.

### Uniforms editables

- L3: `uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);`
- L4: `uniform float outline_width : hint_range(0.0, 10.0) = 2.0;`
- L5: `uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;`

### Candidatos / evidencia

- L8, `shader` (shader interno): `vec4 color = texture(TEXTURE, UV);`
- L9, `shader` (shader interno): `vec2 size = TEXTURE_PIXEL_SIZE * outline_width;`
- L11, `shader` (shader interno): `// Muestrear los 4 lados para el outline`
- L12, `shader` (shader interno): `float alpha = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a +`
- L13, `shader` (shader interno): `texture(TEXTURE, UV + vec2(size.x, 0.0)).a +`
- L14, `shader` (shader interno): `texture(TEXTURE, UV + vec2(0.0, -size.y)).a +`
- L15, `shader` (shader interno): `texture(TEXTURE, UV + vec2(0.0, size.y)).a;`
- L18, `shader` (shader interno): `alpha += (texture(TEXTURE, UV + vec2(-size.x, -size.y)).a +`
- L19, `shader` (shader interno): `texture(TEXTURE, UV + vec2(size.x, -size.y)).a +`
- L20, `shader` (shader interno): `texture(TEXTURE, UV + vec2(-size.x, size.y)).a +`
- L21, `shader` (shader interno): `texture(TEXTURE, UV + vec2(size.x, size.y)).a) * 0.5;`
- L24, `shader` (shader interno): `vec4 glow = vec4(outline_color.rgb, outline_color.a * alpha * glow_intensity);`

## shaders/pot_oil_tint.gdshader

12 líneas; 0 anotaciones export; 4 uniforms; 3 candidatos.

### Uniforms editables

- L2: `uniform vec2 floor_center = vec2(0.496, 0.513);`
- L3: `uniform vec2 floor_radii = vec2(0.342, 0.328);`
- L4: `uniform vec4 oil_tint : source_color = vec4(0.76, 0.60, 0.35, 1.0);`
- L5: `uniform float tint_strength : hint_range(0.0, 1.0) = 0.55;`

### Candidatos / evidencia

- L8, `shader` (shader interno): `float mask = 1.0 - smoothstep(0.90, 1.02, radius);`
- L9, `shader` (shader interno): `float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));`
- L10, `shader` (shader interno): `vec3 warmed = oil_tint.rgb * luminance * 1.7;`

## shaders/rocoto_fragment.gdshader

8 líneas; 0 anotaciones export; 0 uniforms; 4 candidatos.

### Candidatos / evidencia

- L4, `shader` (shader interno): `vec2 p = UV*2.0-1.0;`
- L5, `shader` (shader interno): `float core = exp(-dot(p,p)*5.0);`
- L6, `shader` (shader interno): `float edge = 1.0-smoothstep(0.5,1.0,length(p));`
- L7, `shader` (shader interno): `COLOR = vec4(COLOR.rgb,core*edge*COLOR.a);`

## shaders/rocoto_shockwave.gdshader

31 líneas; 0 anotaciones export; 8 uniforms; 17 candidatos.

### Uniforms editables

- L3: `uniform vec4 heat_color : source_color = vec4(1.0,0.15,0.05,1.0);`
- L4: `uniform vec4 core_color : source_color = vec4(1.0,0.95,0.72,1.0);`
- L5: `uniform float elapsed = 0.0;`
- L6: `uniform float duration = 0.18;`
- L7: `uniform float tail_duration = 0.18;`
- L8: `uniform float rim_width = 0.035;`
- L9: `uniform float opacity = 0.9;`
- L10: `uniform float variation = 0.0;`

### Candidatos / evidencia

- L12, `shader` (shader interno): `vec2 p = (UV*2.0-1.0)*1.15;`
- L15, `shader` (shader interno): `float t = clamp(elapsed/max(duration,0.01),0.0,1.0);`
- L16, `shader` (shader interno): `float fade = 1.0-smoothstep(duration,duration+max(tail_duration,0.01),elapsed);`
- L17, `shader` (shader interno): `float front = max(0.01,t);`
- L18, `shader` (shader interno): `float ripples = sin(a*13.0+variation+elapsed*19.0)*0.008;`
- L19, `shader` (shader interno): `float ring = exp(-pow((r-front-ripples)/rim_width,2.0));`
- L20, `shader` (shader interno): `float hot_edge = exp(-pow((r-front)/max(0.007,rim_width*0.3),2.0));`
- L21, `shader` (shader interno): `float glow = exp(-pow((r-front)/0.10,2.0))*0.08;`
- L22, `shader` (shader interno): `float echo = exp(-pow((r-front*0.78)/0.023,2.0))*0.2;`
- L23, `shader` (shader interno): `echo += exp(-pow((r-front*0.53)/0.035,2.0))*0.08;`
- L24, `shader` (shader interno): `float rays = pow(max(0.0,sin(a*27.0+variation)),20.0);`
- L25, `shader` (shader interno): `float streaks = rays*exp(-pow((r-front*0.87)/0.13,2.0))*0.22;`
- L26, `shader` (shader interno): `float impact = exp(-r*r/0.025)*exp(-elapsed*38.0);`
- L27, `shader` (shader interno): `float pressure = (1.0-smoothstep(front*0.5,front,r))*0.12*exp(-elapsed*9.0);`
- L28, `shader` (shader interno): `float alpha = (ring*0.7+glow+echo*0.55+streaks+impact*0.55+pressure)*fade*opacity;`
- L29, `shader` (shader interno): `vec3 tint = mix(heat_color.rgb,core_color.rgb,clamp(hot_edge*0.3+impact*0.55+streaks*0.25,0.0,1.0));`
- L30, `shader` (shader interno): `COLOR = vec4(tint,clamp(alpha,0.0,1.0));`

## shaders/spatula_shadow.gdshader

6 líneas; 0 anotaciones export; 1 uniforms; 2 candidatos.

### Uniforms editables

- L2: `uniform vec4 shadow_color : source_color = vec4(0.12, 0.08, 0.04, 0.52);`

### Candidatos / evidencia

- L4, `shader` (shader interno): `float silhouette = smoothstep(0.20, 0.60, texture(TEXTURE, UV).a);`
- L5, `shader` (shader interno): `COLOR = vec4(shadow_color.rgb, silhouette * shadow_color.a * COLOR.a);`

## shaders/spicy_aura.gdshader

85 líneas; 0 anotaciones export; 18 uniforms; 43 candidatos.

### Uniforms editables

- L3: `uniform vec4 heat_color : source_color = vec4(1.0, 0.31, 0.08, 1.0);`
- L4: `uniform vec4 ember_color : source_color = vec4(1.0, 0.455, 0.208, 1.0);`
- L5: `uniform float opacity = 0.22;`
- L6: `uniform float elapsed = 0.0;`
- L7: `uniform float breathing_speed = 2.0;`
- L8: `uniform float breathing_strength = 0.2;`
- L9: `uniform int orbit_particle_count = 16;`
- L10: `uniform float orbit_speed = 0.65;`
- L11: `uniform float orbit_particle_size = 0.025;`
- L12: `uniform float orbit_opacity = 0.4;`
- L13: `uniform float ring_opacity = 0.25;`
- L14: `uniform int central_particle_count = 24;`
- L15: `uniform float central_particle_size = 0.008;`
- L16: `uniform float central_travel = 0.14;`
- L17: `uniform float central_lifetime = 0.9;`
- L18: `uniform float central_opacity = 0.45;`
- L20: `uniform int coverage_count = 0;`
- L21: `uniform vec2 coverage_extents[6];`

### Candidatos / evidencia

- L22, `shader` (shader interno): `float coverage_at(vec2 point) {`
- L23, `shader` (shader interno): `if (coverage_count == 0) { return 1.0; }`
- L24, `shader` (shader interno): `float density = 0.0;`
- L25, `shader` (shader interno): `for (int i = 0; i < 6; i++) {`
- L27, `shader` (shader interno): `density += 1.0 - smoothstep(0.84, 1.0, length(point / max(coverage_extents[i], vec2(0.001))));`
- L33, `shader` (shader interno): `vec2 p = UV * 2.0 - 1.0;`
- L35, `shader` (shader interno): `float breath = 1.0 - breathing_strength * 0.5 + sin(elapsed * breathing_speed) * breathing_strength * 0.5;`
- L36, `shader` (shader interno): `float fill = (1.0 - smoothstep(0.15, 1.0, radius)) * opacity * breath * 0.65;`
- L37, `shader` (shader interno): `float rim = exp(-pow((radius - 0.80) / 0.085, 2.0)) * ring_opacity * breath;`
- L38, `shader` (shader interno): `float inner_rim = exp(-pow((radius - 0.57) / 0.045, 2.0)) * ring_opacity * 0.22;`
- L39, `shader` (shader interno): `float glow = 0.0;`
- L40, `shader` (shader interno): `float cores = 0.0;`
- L41, `shader` (shader interno): `for (int i = 0; i < 32; i++) {`
- L44, `shader` (shader interno): `float lane = mix(0.58, 0.86, fract(seed * 0.6180339));`
- L45, `shader` (shader interno): `float speed = orbit_speed * mix(0.75, 1.25, fract(seed * 0.381966));`
- L46, `shader` (shader interno): `float angle = seed * 2.399963 + elapsed * speed;`
- L47, `shader` (shader interno): `float size = orbit_particle_size * mix(0.7, 1.3, fract(seed * 0.754877));`
- L48, `shader` (shader interno): `float twinkle = 0.72 + 0.28 * sin(elapsed * 3.0 + seed * 1.7);`
- L49, `shader` (shader interno): `vec2 center = vec2(cos(angle), sin(angle)) * lane;`
- L51, `shader` (shader interno): `cores += exp(-pow(d / size, 2.0)) * twinkle;`
- L52, `shader` (shader interno): `glow += exp(-pow(d / (size * 2.0), 2.0)) * 0.12 * twinkle;`
- L54, `shader` (shader interno): `for (int j = 1; j <= 3; j++) {`
- L55, `shader` (shader interno): `float trail_angle = angle - float(j) * 0.045;`
- L56, `shader` (shader interno): `vec2 trail_center = vec2(cos(trail_angle), sin(trail_angle)) * lane;`
- L57, `shader` (shader interno): `float trail = exp(-pow(length(p - trail_center) / (size * 0.75), 2.0));`
- L58, `shader` (shader interno): `glow += trail * (1.0 - float(j) / 4.0) * 0.22;`
- L61, `shader` (shader interno): `float central_sparks = 0.0;`
- L62, `shader` (shader interno): `for (int i = 0; i < 32; i++) {`
- L65, `shader` (shader interno): `float cycle = elapsed / max(central_lifetime, 0.1) + seed * 0.6180339;`
- L68, `shader` (shader interno): `float angle = seed * 2.399963 + generation * 1.71;`
- L69, `shader` (shader interno): `float start_radius = mix(0.10, 0.28, fract(seed * 0.381966));`
- L71, `shader` (shader interno): `vec2 center = vec2(cos(angle), sin(angle)) * travel_radius;`
- L72, `shader` (shader interno): `center.y -= sin(age * 3.14159265) * 0.025;`
- L73, `shader` (shader interno): `float size = central_particle_size * mix(0.7, 1.2, fract(seed * 0.754877));`
- L74, `shader` (shader interno): `float fade = smoothstep(0.0, 0.15, age) * (1.0 - smoothstep(0.45, 1.0, age));`
- L75, `shader` (shader interno): `central_sparks += exp(-pow(length(p - center) / size, 2.0)) * fade;`
- L77, `shader` (shader interno): `float spark_alpha = clamp((cores + glow) * orbit_opacity + central_sparks * central_opacity, 0.0, 1.0);`
- L78, `shader` (shader interno): `float base_alpha = clamp(fill + rim + inner_rim, 0.0, 0.7);`
- L79, `shader` (shader interno): `float alpha = (1.0 - (1.0 - base_alpha) * (1.0 - spark_alpha)) * (1.0 - smoothstep(0.94, 1.0, radius));`
- L80, `shader` (shader interno): `vec3 tint = mix(heat_color.rgb, ember_color.rgb, clamp(cores * 0.3 + glow * 0.1 + central_sparks * 0.2, 0.0, 1.0));`
- L82, `shader` (shader interno): `float strength = min(density, 1.0) * (1.0 + max(density - 1.0, 0.0) * 0.14);`
- L83, `shader` (shader interno): `tint = mix(tint, ember_color.rgb, clamp((density - 1.0) * 0.06, 0.0, 0.25));`
- L84, `shader` (shader interno): `COLOR = vec4(tint, min(alpha * strength, 0.85) * heat_color.a);`

## shaders/spicy_pattern.gdshader

38 líneas; 0 anotaciones export; 6 uniforms; 26 candidatos.

### Uniforms editables

- L3: `uniform int mode = 0;`
- L4: `uniform vec4 tint : source_color = vec4(1.0,0.35,0.05,1.0);`
- L5: `uniform float elapsed = 0.0;`
- L6: `uniform float opacity = 0.65;`
- L7: `uniform float progress = 0.0;`
- L8: `uniform bool detonated = false;`

### Candidatos / evidencia

- L10, `shader` (shader interno): `vec2 p = UV*2.0-1.0;`
- L12, `shader` (shader interno): `float mask = 1.0-smoothstep(0.65,1.0,r);`
- L13, `shader` (shader interno): `float pattern = 0.75+0.25*sin(p.x*12.0+sin(p.y*8.0-elapsed*4.0)*2.0+elapsed*2.0);`
- L14, `shader` (shader interno): `vec3 color = tint.rgb;`
- L15, `shader` (shader interno): `if (mode == 0) {`
- L16, `shader` (shader interno): `float x = fract(UV.x*3.0)-0.5 + sin(UV.y*10.0-elapsed*7.0)*0.06;`
- L17, `shader` (shader interno): `float width = 0.1+UV.y*0.22;`
- L18, `shader` (shader interno): `float tongue = (1.0-smoothstep(width*0.5,width,abs(x)))*smoothstep(0.0,0.2,UV.y)*(1.0-smoothstep(0.85,1.0,UV.y));`
- L19, `shader` (shader interno): `mask *= 0.3+0.7*tongue;`
- L20, `shader` (shader interno): `pattern = 0.9;`
- L21, `shader` (shader interno): `color = mix(tint.rgb,vec3(1.0,0.85,0.2),tongue*0.7);`
- L22, `shader` (shader interno): `} else if (mode == 2) {`
- L23, `shader` (shader interno): `float width = mix(0.65,0.2,UV.y);`
- L24, `shader` (shader interno): `float x = p.x + sin(UV.y*14.0-elapsed*8.0)*0.06;`
- L25, `shader` (shader interno): `mask = (1.0-smoothstep(width*0.7,width,abs(x))) * smoothstep(0.0,0.12,UV.y) * (1.0-smoothstep(0.92,1.0,UV.y));`
- L26, `shader` (shader interno): `pattern = 0.75+0.25*sin(UV.y*38.0+p.x*8.0-elapsed*15.0);`
- L27, `shader` (shader interno): `color = mix(tint.rgb,vec3(1.0,0.85,0.2),(1.0-abs(x)/width)*pattern*0.8);`
- L28, `shader` (shader interno): `} else if (mode == 3) {`
- L29, `shader` (shader interno): `mask *= 0.7+0.3*sin(p.x*5.0+sin(p.y*6.0+elapsed)*2.0);`
- L30, `shader` (shader interno): `} else if (mode == 5 && !detonated) {`
- L31, `shader` (shader interno): `mask = 1.0-smoothstep(0.22,0.3,r);`
- L32, `shader` (shader interno): `pattern = 0.7+0.3*sin(elapsed*6.0);`
- L33, `shader` (shader interno): `} else if (mode == 6 || (mode == 5 && detonated)) {`
- L34, `shader` (shader interno): `float ring = abs(r-max(0.05,progress));`
- L35, `shader` (shader interno): `mask = (1.0-smoothstep(0.025,0.12,ring))*(1.0-progress);`
- L37, `shader` (shader interno): `COLOR = vec4(color, mask*pattern*opacity*tint.a);`

## shaders/turret_fire_band.gdshader

18 líneas; 0 anotaciones export; 6 uniforms; 7 candidatos.

### Uniforms editables

- L3: `uniform float phase = 0.0;`
- L4: `uniform bool use_color_mask = true;`
- L5: `uniform float firing : hint_range(0.0,1.0) = 0.0;`
- L6: `uniform vec4 fire_red : source_color = vec4(0.75,0.08,0.018,1.0);`
- L7: `uniform vec4 fire_orange : source_color = vec4(1.0,0.48,0.045,1.0);`
- L8: `uniform vec4 fire_yellow : source_color = vec4(1.0,0.86,0.33,1.0);`

### Candidatos / evidencia

- L10, `shader` (shader interno): `vec4 original=texture(TEXTURE,UV);`
- L12, `shader` (shader interno): `float belt=use_color_mask ? smoothstep(0.61,0.72,original.g)* (1.0-smoothstep(0.40,0.55,original.b)) : 1.0;`
- L13, `shader` (shader interno): `float flow=sin(UV.x*47.0-phase*4.0)+0.5*sin(UV.y*63.0+UV.x*19.0+phase*5.0);`
- L14, `shader` (shader interno): `float hot=smoothstep(-0.1,0.8,flow);`
- L15, `shader` (shader interno): `vec3 fire=mix(fire_red.rgb,fire_orange.rgb,0.55+0.45*sin(flow+phase*0.5));`
- L16, `shader` (shader interno): `fire=mix(fire,fire_yellow.rgb,hot*(0.35+firing*0.5));`
- L17, `shader` (shader interno): `COLOR=vec4(mix(original.rgb,fire,belt),original.a);`

## shaders/warning_fire_color.gdshader

5 líneas; 0 anotaciones export; 2 uniforms; 0 candidatos.

### Uniforms editables

- L3: `uniform float phase=0.0;`
- L4: `uniform vec4 fire_color : source_color = vec4(1.0,0.6,0.12,1.0);`


## tools/build_ui_theme.gd

17 líneas; 0 anotaciones export; 0 uniforms; 2 candidatos.

### Candidatos / evidencia

- L10, `build` (regla/valor): `var id := "cream"`
- L12, `build` (literal adicional (revisión)): `if arg.begins_with("--palette="): id = arg.trim_prefix("--palette=")`

