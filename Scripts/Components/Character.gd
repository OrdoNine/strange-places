class_name Character
extends CharacterBody2D

@onready var sprite = $Sprite2D
@export var behavior : Behavior

const GRAVITY = 100.0

var health := 1
var balanced := false
var last_horiz_dir := 1

signal changed_balance(state : bool)
signal got_hit()
signal got_effect()

func _ready() -> void:
	build()

func build() -> void:
	#set up values
	$CollisionShape2D.shape.size = behavior.size
	sprite.texture = behavior.sprite
	health = behavior.health
	
	#set up signals
	got_hit.connect(_on_got_hit)
	got_effect.connect(_on_got_effect)
	
	#set up balance casts
	var balance_rot = deg_to_rad(behavior.balance_degrees)
	var odd := behavior.balance_acc % 2
	match behavior.balance_pattern:
		Behavior.BalancePattern.cone: 
			var balance_dist = behavior.size.x/(behavior.balance_acc - odd) * abs(cos(balance_rot))\
								+ behavior.size.y/(behavior.balance_acc - odd) * abs(sin(balance_rot))
			var median := (behavior.balance_acc - odd)/2
			for i in range(behavior.balance_acc):
				var cast = RayCast2D.new()
				
				if i == 0 and odd:
					cast.target_position.x = (behavior.size.x/2 + behavior.balance_thres) * sin(balance_rot)
					cast.target_position.y = (behavior.size.y/2 + behavior.balance_thres) * cos(balance_rot)
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
											+ (behavior.size.x/2 + behavior.balance_thres) * sin(balance_rot)
					cast.target_position.y = (balance_dist * direct_idx) * cos(balance_rot + PI/2)\
											+ (behavior.size.y/2 + behavior.balance_thres) * cos(balance_rot)
				$BalanceCasts.add_child(cast)
		Behavior.BalancePattern.star:
			var balance_dist = 2*PI/behavior.balance_acc
			for i in range(behavior.balance_acc):
				var cast = RayCast2D.new()
				cast.target_position = Vector2(
									(behavior.size.x/2 + behavior.balance_thres) * sin(i * balance_dist + balance_rot),
				 					(behavior.size.y/2 + behavior.balance_thres) * cos(i * balance_dist + balance_rot) )
				$BalanceCasts.add_child(cast)

func balance() -> bool:
	#check whether is balanced
	var result = true
	if not behavior.balance_on_move and not velocity.is_equal_approx(Vector2.ZERO):
		result = false
	
	if result:
		var colls := 0
		for i in range(behavior.balance_acc):
			var cast = $BalanceCasts.get_child(i)
			if cast is RayCast2D and cast.is_colliding():
				#check if valid landing spot
				if not behavior.balance_on_hazard:
					var collider = cast.get_collider()
					var coll_tile = collider.local_to_map(cast.get_collision_point() - cast.get_collision_normal() * 8)
					#adding the normal due to an off by one tile issue due to the collision point being too accurate
					var data = collider.get_cell_tile_data(coll_tile)
					if data.has_custom_data("Fire") and data.get_custom_data("Fire"):
						result = false
						break
				colls += 1
		if result: #rechecking due to break
			result = colls >= behavior.balance_count
	if result != balanced:
		balanced = result
		emit_signal("changed_balance", balanced)
	return result

func _on_got_hit() -> void:
	pass

func _on_got_effect() -> void:
	pass
