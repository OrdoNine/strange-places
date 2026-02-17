class_name NPC
extends Character

var actions : NPCAI

func _ready() -> void:
	build()
	match behavior.AI.movement_type:
		NPCAI.Movement.walking:
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		NPCAI.Movement.flying:
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	actions = behavior.AI

func _process(delta: float) -> void:
	if sign(velocity.x) != last_horiz_dir:
		#adds friction when stopped or changing direction
		velocity.x /= behavior.drag
		if abs(velocity.x) < behavior.speed/100:
			velocity.x *= -1 
	balance()
	match actions.movement_type:
		NPCAI.Movement.walking:
			if can_take_action("patrol"):
				if abs(velocity.x) < behavior.speed:
					velocity.x += last_horiz_dir * behavior.speed * delta
			if can_take_action("fire"):
				pass
			if can_take_action("chase"):
				pass
			if can_take_action("jump") and is_on_floor():
				velocity.y = -behavior.speed * behavior.jump
			if velocity.y < GRAVITY * 1000:
				velocity.y += GRAVITY * delta
		NPCAI.Movement.flying:
			pass
	move_and_slide()

func can_take_action(property : StringName):
	var act = actions.get(property)
	return act == NPCAI.Trigger.always\
			or (act == NPCAI.Trigger.on_balance and balanced)\
			or (act == NPCAI.Trigger.off_balance and not balanced)\
			or (act == NPCAI.Trigger.mid_air and not is_on_floor())\
			or (act == NPCAI.Trigger.on_ground and is_on_floor())

func _on_changed_balance(state: bool) -> void:
	if (actions.flip == NPCAI.Trigger.on_balance and state) or (actions.flip == NPCAI.Trigger.off_balance and not state):
		last_horiz_dir = -last_horiz_dir
