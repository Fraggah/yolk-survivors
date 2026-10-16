extends Resource
class_name RangedSettings

@export_range(1, 16, 1) var projectile_count := 1
@export_range(0.0, 180.0, 1.0) var spread_degrees := 0.0
@export_range(1, 12, 1) var burst_count := 1
@export_range(0.01, 1.0, 0.01) var burst_interval := 0.1
@export var lock_burst_aim := false
@export_group("Explosion")
@export var explodes := false
@export var explode_on_impact := true
@export_range(0.05, 10.0, 0.05) var fuse := 0.8
@export_range(1.0, 400.0, 1.0) var explosion_radius := 70.0
@export_range(0.1, 1.0, 0.05) var area_y_ratio := 0.6
@export_range(0.0, 5.0, 0.05) var explosion_damage_multiplier := 1.0
@export var explosion_texture: Texture2D
@export var explosion_color := Color("f6bc65")
@export_range(0.05, 2.0, 0.01) var explosion_visual_duration := 0.18
@export_group("Plate break")
@export_range(0.0, 1.0, 0.01) var plate_break_chance := 0.8
@export_range(0, 40, 1) var plate_fragment_count := 12
@export var plate_fragment_duration := 0.45
@export var plate_fragment_speed := 180.0
@export var plate_fragment_edge_color := Color("c4bba7")
@export_range(0.0, 1.0, 0.01) var plate_fragment_edge_width := 0.1
@export_group("Baguette harpoon")
@export var harpoon_pin_duration := 0.5
@export var harpoon_embed_duration := 0.1
@export var harpoon_embed_angle := -0.25
@export var harpoon_capture_radius := 16.0
@export_group("Pressure cooker landing")
@export var landing_slow_radius := 110.0
@export_range(0.0, 1.0, 0.05) var landing_slow_factor := 0.6
@export var landing_slow_duration := 1.5
@export var landing_visual_duration := 0.3
@export var pot_inflate_amount := 0.2
@export var pot_sprite_scale := 0.5
@export_group("Corn impact")
@export_range(0.0, 1.0, 0.01) var corn_explosion_chance := 0.3
@export_range(0.0, 5.0, 0.05) var corn_contact_damage_multiplier := 0.25
@export_group("Popcorn follow-up")
@export var popcorn_scene: PackedScene
@export var popcorn_speed := 700.0
@export var popcorn_range := 240.0
@export_range(0.0, 5.0, 0.05) var popcorn_damage_multiplier := 1.0
@export_group("Landed explosives")
## Flight height is visual; fuse begins only after reaching the target snapshot.
@export var lob_height := 45.0
@export var egg_contact_push := 1.25
@export_range(0.01, 1.0, 0.01) var egg_fall_duration := 0.1
@export_range(0.0, 2.0, 0.01) var pre_explosion_shake_duration := 0.2
@export_range(0.0, 10.0, 0.1) var pre_explosion_shake_amount := 2.0
@export_range(1.0, 100.0, 1.0) var pre_explosion_shake_frequency := 35.0
@export_range(0, 20, 1) var bonus_yolks := 1
@export_group("Contact remnant")
@export var leaves_pit := false
@export var pit_texture: Texture2D
@export var pit_projectile_scene: PackedScene
@export var pit_projectile_speed := 700.0
@export_range(0.0, 1.0, 0.01) var pit_range_multiplier := 0.5
@export_range(0.0, 90.0, 1.0) var pit_deviation_degrees := 45.0
@export_range(0.1, 20.0, 0.1) var pit_duration := 3.0
@export_range(1.0, 100.0, 1.0) var pit_radius := 16.0
@export_range(0.0, 3.0, 0.05) var pit_damage_multiplier := 0.5
@export_range(0.05, 3.0, 0.05) var pit_hit_interval := 0.5
@export_group("Ketchup splatter")
@export_range(1, 16, 1) var splatter_count := 3
@export_range(0.0, 3.0, 0.05) var splatter_damage_multiplier := 0.25
@export_range(0.0, 180.0, 1.0) var splatter_spread_degrees := 50.0
@export var splatter_speed := 700.0
## Fraction of the weapon's full shot range, independent of distance already flown.
@export_range(0.0, 1.0, 0.01) var splatter_range_multiplier := 0.1
@export_group("Continuous stream")
@export_range(1.0, 80.0, 0.5) var stream_width := 10.0
@export var stream_color := Color("fff0be")
@export var stream_core_color := Color("fffdf0")
@export var stream_edge_color := Color("c5b587")
@export_range(0.0, 10.0, 0.1) var stream_wobble := 1.6
@export_range(0.0, 30.0, 0.1) var stream_flow_speed := 8.0
@export_range(0.01, 1.0, 0.01) var stream_particle_interval := 0.06
@export_range(0, 40, 1) var stream_muzzle_particles := 3
@export_range(0, 60, 1) var stream_impact_particles := 10
@export_range(0.05, 2.0, 0.01) var stream_particle_lifetime := 0.4
@export_range(0.0, 500.0, 5.0) var stream_particle_speed := 100.0
