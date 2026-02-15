extends CharacterBody2D

@export var size := Vector2(95,144)
@export var balance_acc := 5 #how many casts to spawn to check for balance
@export var balance_count := 3 #how many casts need to collide for this object to be balanced
@export var balance_thres := 16.0 #sets the distance for the balance check, will snap below this.

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var balanced := false

func _ready() -> void:
	$CollisionShape2D.shape.size = size
	var texture = $Sprite2D.texture
	if texture and texture.get_width() > 0 and texture.get_height() > 0:
		$Sprite2D.scale = size/texture.get_size()
	
	var odd := balance_acc % 2
	var median := (balance_acc - odd)/2
	var balance_dist = size.x/(balance_acc - odd)
	for i in range(0, balance_acc):
		var cast = RayCast2D.new()
		cast.target_position.y = size.y/2 + balance_thres
		
		if i == 0 and odd:
			cast.target_position.x = 0
		else:
			var left = true
			var direct_idx = i #fixing i to respect directions
			if not odd:
				direct_idx += 1
			if direct_idx > median:
				left = false
				direct_idx -= median
			cast.target_position.x = balance_dist * (direct_idx * (-1 if left else 1))
		$BalanceCasts.add_child(cast)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(Input.get_axis("LEFT", "RIGHT"), Input.get_axis("UP", "DOWN"))
	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	balanced = false
	if velocity.is_equal_approx(Vector2.ZERO):
		balanced = balance()
	
	if balanced:
		$Sprite2D.self_modulate = Color(1, 1, 1, 1)
	else:
		print("yep")
		$Sprite2D.self_modulate = Color(1, 0, 0, 1)
	move_and_slide()


func balance() -> bool:
	var colls := 0
	for i in range($BalanceCasts.get_child_count()):
		var cast = $BalanceCasts.get_child(i)
		if cast is RayCast2D and cast.is_colliding():
			colls += 1
	return colls >= balance_count
