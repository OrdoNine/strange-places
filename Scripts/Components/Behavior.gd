class_name Behavior
extends Resource

enum BalancePattern {cone = 0, star = 1}

@export_category("Base Stats") 
@export var health := 1
@export var speed := 1200.0
@export var drag := 1.2
@export var jump := 1.0 #jump is a thrust of speed, used by walkers 
@export var size := Vector2(95,143)

@export_category("Balancing Settings")
#used by the player to land, used by enemies for AI purposes
@export var balance_acc := 5 #how many casts to spawn to check for balance
@export var balance_count := 3 #how many casts need to collide for this object to be balanced
@export var balance_thres := 16.0 #sets the distance for the balance check, will snap below this.
@export var balance_pattern : BalancePattern = BalancePattern.cone #how the casts are organized.
@export var balance_degrees := 0.0 #the orientation of the balance casts
@export var balance_on_move := false #whether can balance while moving
@export var balance_on_hazard := false #whether can balance on unsafe tiles and areas

@export_category("Flavor")
@export var sprite : Texture2D = load("res://icon.svg")

@export_category("AI")
#not used by the player
@export var AI : NPCAI
@export var Projectile : Projectile 
