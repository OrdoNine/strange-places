class_name Character
extends CharacterBody2D

enum BalancePattern {cone = 0, star = 1}

@onready var sprite : Sprite2D = $Sprite2D
 
@export var size := Vector2(96,144)
@export_category("Balancing Settings")
@export var balance_acc := 5 #how many casts to spawn to check for balance
@export var balance_count := 3 #how many casts need to collide for this object to be balanced
@export var balance_thres := 16.0 #sets the distance for the balance check, will snap below this.
@export var balance_pattern : BalancePattern = BalancePattern.cone #how the casts are organized.
@export var balance_degrees := 0.0 #the orientation of the balance casts

var speed := 1200.0
var drag := 1.2
var balanced := false
var last_horiz_dir := 1

func build() -> void:
	$CollisionShape2D.shape.size = size
	var texture = sprite.texture
	if texture and texture.get_width() > 0 and texture.get_height() > 0:
		sprite.scale = size/texture.get_size()
	
	var balance_rot = deg_to_rad(balance_degrees)
	var odd := balance_acc % 2
	match balance_pattern:
		BalancePattern.cone: 
			var balance_dist = size.x/(balance_acc - odd) * abs(cos(balance_rot))\
								+ size.y/(balance_acc - odd) * abs(sin(balance_rot))
			var median := (balance_acc - odd)/2
			for i in range(balance_acc):
				var cast = RayCast2D.new()
				
				if i == 0 and odd:
					cast.target_position.x = (size.x/2 + balance_thres) * sin(balance_rot)
					cast.target_position.y = (size.y/2 + balance_thres) * cos(balance_rot)
				else:
					var left = true
					var direct_idx = i #fixing i to respect directions
					if not odd:
						direct_idx += 1
					if direct_idx > median:
						left = false
						direct_idx -= median
					else:
						direct_idx *= -1
					cast.target_position.x = (balance_dist * direct_idx) * sin(balance_rot + PI/2)\
											+ (size.x/2 + balance_thres) * sin(balance_rot)
					cast.target_position.y = (balance_dist * direct_idx) * cos(balance_rot + PI/2)\
											+ (size.y/2 + balance_thres) * cos(balance_rot)
				$BalanceCasts.add_child(cast)
		BalancePattern.star:
			var balance_dist = 2*PI/balance_acc
			for i in range(balance_acc):
				var cast = RayCast2D.new()
				cast.target_position = Vector2(
									(size.x/2 + balance_thres) * sin(i * balance_dist + deg_to_rad(balance_degrees)),
				 					(size.y/2 + balance_thres) * cos(i * balance_dist + deg_to_rad(balance_degrees)) )
				$BalanceCasts.add_child(cast)

func balance() -> bool:
	#check whether is balanced
	var colls := 0
	for i in range(balance_acc):
		var cast = $BalanceCasts.get_child(i)
		if cast is RayCast2D and cast.is_colliding():
			#check if valid landing spot
			var collider = cast.get_collider()
			var coll_tile = collider.local_to_map(cast.get_collision_point() - cast.get_collision_normal() * 8)
			#adding the normal due to an off by one tile issue due to the collision point being too accurate
			var data = collider.get_cell_tile_data(coll_tile)
			if data.has_custom_data("Fire") and data.get_custom_data("Fire"):
				return false
			colls += 1
	return colls >= balance_count
