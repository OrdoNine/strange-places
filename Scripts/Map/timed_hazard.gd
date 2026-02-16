@tool
class_name TimedHazard
extends Node2D

enum Period {off = 0, prep = 1, on = 2}
enum TimingQuirk {none = 0, constant = 1, instaprep = 2}

@onready var area = $Area2D
@onready var timer = $Timers/Timer
@onready var pretimer = $Timers/PreTimer
@onready var postimer = $Timers/PostTimer

@export_category("Timing")
@export var frequency := 1.0: #main timer, how often the main effect occurs
	set(value):
		frequency = max(value, duration)
		if frequency - duration < preparation:
			preparation = frequency - duration
@export var preparation := 0.3: #how much in advance to prepare for the effect. run anims
	set(value):
		preparation = max(value, 0)
		preparation = min(value, frequency - duration) 
		if is_equal_approx(preparation, 0) and starting_mode == Period.prep:
			starting_mode = Period.on
@export var duration := 0.3: #how long the area is active for after frequency is up 
	set(value):
		duration = max(value, 0.001)
		duration = min(value, frequency - preparation)
@export var starting_mode : Period = Period.off: #at what stage should this object start
	set(value):
		if is_equal_approx(preparation, 0) and value == Period.prep:
			starting_mode = Period.on
		else:
			starting_mode = value

@export_category("Data")
@export var area_shape : Shape2D
@export var main_effect : Effect #effect that triggers on timer
@export var pre_effect : Effect #effect that triggers as a warning

var mode : Period = Period.off #the current state of the hazard

#optimizations
var timing : TimingQuirk = TimingQuirk.none #used to optimized timers 
var members = [] #who is inside the area currently

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		mode = starting_mode
		
		if not main_effect:
			if pre_effect:
				printerr("Created a timed hazard with not main effect. Using prep effect instead!")
				main_effect = pre_effect
				pre_effect = null
			else:
				printerr("Created a timed hazard with no effects!")
		
		if is_equal_approx(frequency, duration):
			#the frequency and duration are a full cycle
			timing = TimingQuirk.constant 
			if mode != Period.on:
				#temp timer for delay
				get_tree().create_timer(frequency).connect("timeout", _on_timer_timeout)
			remove_child($Timers) #timers are not necessary
				
		elif is_equal_approx(frequency, preparation + duration):
			#preparation and duration are seamless
			timing = TimingQuirk.instaprep
			remove_child(pretimer) #removes PreTimer, opting for PostTimer to be the trigger instead
		 
		if pretimer.is_inside_tree() and mode == Period.off and preparation > 0:
			pretimer.start(frequency - preparation)
		if timer.is_inside_tree():
			timer.start(frequency - (preparation if mode == Period.prep else 0.0))
		
		var coll_shape = CollisionShape2D.new()
		coll_shape.shape = area_shape
		area.add_child(coll_shape)
		
		if main_effect.target_tiles:
			area.set_collision_mask_value(1, true)
			area.set_collision_mask_value(1 + int(main_effect.target_tiles), true)
		if main_effect.target_player:
			area.set_collision_mask_value(3, true)
			area.set_collision_mask_value(3 + int(main_effect.target_tiles), true)
		if main_effect.target_enemy:
			area.set_collision_mask_value(5, true)
			area.set_collision_mask_value(5 + int(main_effect.target_tiles), true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body in members:
		members.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

func _on_timer_timeout() -> void:
	deactivate_preEffect()
	activate_mainEffect()
	print("main")
	mode = Period.on
	if postimer.is_inside_tree():
		postimer.start(duration)
	if pretimer.is_inside_tree():
		pretimer.start(frequency - preparation)

func _on_pre_timer_timeout() -> void:
	print("pre")
	activate_preEffect()

func _on_post_timer_timeout() -> void:
	deactivate_mainEffect()
	print("post")
	match timing:
		TimingQuirk.none:
			mode = Period.off
		TimingQuirk.instaprep:
			activate_preEffect()

func activate_mainEffect():
	mode = Period.on
	if main_effect:
		if main_effect.texture:
			var sprite = Sprite2D.new()
			sprite.texture = main_effect.texture
			$EffectSpawns/Main.add_child(sprite) 

func activate_preEffect():
	mode = Period.prep
	if pre_effect:
		if pre_effect.texture:
			var sprite = Sprite2D.new()
			sprite.texture = pre_effect.texture
			$EffectSpawns/Prep.add_child(sprite) 

func deactivate_mainEffect():
	if main_effect:
		for e in $EffectSpawns/Main.get_children():
			$EffectSpawns/Main.remove_child(e)

func deactivate_preEffect():
	if pre_effect:
		for e in $EffectSpawns/Prep.get_children():
			$EffectSpawns/Prep.remove_child(e)
		
	
	
	
