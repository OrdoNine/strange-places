class_name Effect
extends Resource

@export_category("Targets")
@export var target_player := false
@export var target_enemy := false
@export var target_tiles := false 
@export var target_projs := false #affects projectiles from the targeted sources above

@export_category("Flags")
@export var kill_targets := false #cannot kill tiles
@export var set_bush := false
@export var set_fire := false
@export var set_wet := false
@export var set_frozen := false
@export var set_electric := false

@export_category("Values")
@export var knockback := 0.0 
@export var drag_mult := 1.0
@export var speed_mult := 1.0

@export_category("Flavor")
@export var texture : Texture2D
