class_name NPCAI
extends Resource

enum Trigger {never = 0, always = 1, on_balance = 2, off_balance = 3, 
				player_near = 4, player_away = 5, on_hit = 6, 
				on_effect = 7, on_ground = 8, mid_air = 9}
enum Movement {walking = 0, flying = 1}

@export_category("Values")
@export var must_see_player := true #the player is considered nearby only if the enemy can see them
@export var near_player_dist := 3.0 #the player is considered nearby if they are this amount of tiles away  

@export_category("Behaviors")
@export var movement_type : Movement = Movement.walking
@export var patrol : Trigger = Trigger.on_balance #the npc moves on its own
@export var fire : Trigger = Trigger.never #the npc fires its projectile, if it has one
@export var fire_cooldown := 1.0 
@export var flip : Trigger = Trigger.off_balance #the npc flips its movement direction
@export var chase : Trigger = Trigger.never #the npc moves towards the player
@export var jump : Trigger = Trigger.never 
#the npc jumps away from colliders (no matter the trigger, it must be currently against a wall)
