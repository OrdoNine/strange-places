extends CharacterBody2D

@onready var sprite : Sprite2D = $Sprite2D
 
@export var size := Vector2(96,144)
@export var balance_acc := 5 #how many casts to spawn to check for balance
@export var balance_count := 3 #how many casts need to collide for this object to be balanced
@export var balance_thres := 16.0 #sets the distance for the balance check, will snap below this.

const SPEED := 1200.0
const DRAG := 1.2
var balanced := false
var last_horiz_dir := 1

var clumsy : Tween = null

func _ready() -> void:
	$CollisionShape2D.shape.size = size
	var texture = sprite.texture
	if texture and texture.get_width() > 0 and texture.get_height() > 0:
		sprite.scale = size/texture.get_size()
	
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
	
	var direction := Vector2(Input.get_axis("LEFT", "RIGHT"), Input.get_axis("UP", "DOWN"))
	if direction.x and abs(velocity.x) < SPEED:
		velocity.x += direction.x * SPEED * delta
		last_horiz_dir = direction.x
	
	if not direction.x or sign(velocity.x) != direction.x:
		#adds friction when stopped or changing direction
		velocity.x /= DRAG
		if abs(velocity.x) < SPEED/100:
			velocity.x *= -1 * abs(direction.x) #negates or stops velocity based on control
		
	if direction.y and abs(velocity.y) < SPEED:
		velocity.y += direction.y * SPEED * delta
		
	if not direction.y or sign(velocity.y) != direction.y:
		#adds friction when stopped or changing direction
		velocity.y /= DRAG
		if abs(velocity.y) < SPEED/100:
			velocity.y *= -1 * abs(direction.y)
	
	balanced = false
	if velocity.is_equal_approx(Vector2.ZERO):
		balanced = balance()
		#play clumsy animation
		if not balanced:
			var running = false
			if clumsy and clumsy.is_valid():
				if clumsy.is_running():
					running = true
				else:
					clumsy.kill()
			
			if not running:
				clumsy = get_tree().create_tween()
				print(last_horiz_dir)
				clumsy.tween_property(sprite, "rotation_degrees", 20.0 * last_horiz_dir, 0.25).set_ease(Tween.EASE_OUT)
				clumsy.tween_property(sprite, "rotation_degrees", -20.0 * last_horiz_dir, 0.5).set_ease(Tween.EASE_OUT)
				clumsy.play()
		else:
			_reset_balance(clumsy)
	elif clumsy and clumsy.is_running():
		_reset_balance(clumsy)
	
	$AnimationTree.set("parameters/blend_position", float(balanced))
	move_and_slide()
	
	for i in get_slide_collision_count():
		var colln = get_slide_collision(i).get_normal()
		
		if colln.x:
			velocity.x = colln.x
		if colln.y: 
			velocity.y = colln.y
		
	if abs(global_position.x - snappedf(global_position.x, 48.0)) <= max(abs(velocity.x)/100, 1):
		global_position.x = snappedf(global_position.x, 48.0)
		#prints("snapped to ", global_position.x)
	if abs(global_position.y - snappedf(global_position.y, 48.0)) <= max(abs(velocity.y)/100, 1):
		global_position.y = snappedf(global_position.y, 48.0)

func balance() -> bool:
	#check whether is balance
	var colls := 0
	for i in range(balance_acc):
		var cast = $BalanceCasts.get_child(i)
		if cast is RayCast2D and cast.is_colliding():
			#check if valid landing spot
			var collider = cast.get_collider()
			var data = collider.get_cell_tile_data(collider.local_to_map(cast.get_collision_point()))
			if data.has_custom_data("Fire") and data.get_custom_data("Fire"):
				return false
			colls += 1
	return colls >= balance_count

func _reset_balance(tween : Tween):
	#reset booth orientation
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.2).set_ease(Tween.EASE_OUT)
	tween.play()
