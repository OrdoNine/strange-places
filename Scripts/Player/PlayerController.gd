class_name Player
extends Character

var clumsy : Tween = null

func _ready() -> void:
	build()

func _physics_process(delta: float) -> void:
	
	var direction := Vector2(Input.get_axis("LEFT", "RIGHT"), Input.get_axis("UP", "DOWN"))
	if direction.x and abs(velocity.x) < speed:
		velocity.x += direction.x * speed * delta
		last_horiz_dir = direction.x
	
	if not direction.x or sign(velocity.x) != direction.x:
		#adds friction when stopped or changing direction
		velocity.x /= drag
		if abs(velocity.x) < speed/100:
			velocity.x *= -1 * abs(direction.x) #negates or stops velocity based on control
		
	if direction.y and abs(velocity.y) < speed:
		velocity.y += direction.y * speed * delta
		
	if not direction.y or sign(velocity.y) != direction.y:
		#adds friction when stopped or changing direction
		velocity.y /= drag
		if abs(velocity.y) < speed/100:
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

func _reset_balance(tween : Tween):
	#reset booth orientation from clumsy animation
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.2).set_ease(Tween.EASE_OUT)
	tween.play()
