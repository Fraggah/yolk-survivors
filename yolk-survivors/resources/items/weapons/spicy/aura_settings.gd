extends Resource
class_name SpicyAuraSettings

@export_range(0.1, 1.0, 0.01) var area_y_ratio := 0.6
@export var color := Color(1.0, 0.31, 0.08, 1.0)
@export_range(0.0, 1.0, 0.01) var opacity := 0.22
@export_range(0.0, 10.0, 0.1) var breathing_speed := 2.0
@export_range(0.0, 1.0, 0.01) var breathing_strength := 0.2

@export_group("Orbiting embers")
@export_range(0, 32, 1) var orbit_particle_count := 16
@export_range(0.0, 3.0, 0.05) var orbit_speed := 0.65
@export_range(0.005, 0.08, 0.005) var orbit_particle_size := 0.025
@export_range(0.0, 1.0, 0.05) var orbit_opacity := 0.4
@export_range(0.0, 1.0, 0.05) var ring_opacity := 0.25
@export var ember_color := Color("ff7435")

@export_group("Central embers")
@export_range(0, 32, 1) var central_particle_count := 24
@export_range(0.003, 0.04, 0.001) var central_particle_size := 0.008
@export_range(0.0, 0.5, 0.01) var central_travel := 0.14
@export_range(0.1, 3.0, 0.05) var central_lifetime := 0.9
@export_range(0.0, 1.0, 0.05) var central_opacity := 0.45
