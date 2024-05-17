extends CharacterBody2D

@onready var player = $/root/Game/Player
@onready var animated_sprite = $AnimatedSprite2D

const SMOKE_SCENE = preload("res://scenes/smoke_explosion.tscn")
const XP_GEM = preload("res://scenes/experience_gem.tscn")

const SPEED_CHASE = 150.0 
const SPEED_RANDOM = 100.0
var chase_player = true
var direction
var random_direction
var direction_x
var health = 3

func _physics_process(delta):
	# get direction to player
	direction = global_position.direction_to(player.global_position)
	
	# flip sprite left or right
	if chase_player:
		direction_x = direction[0]
		flip_sprite(direction_x)
	else:
		direction_x = random_direction[0]
		flip_sprite(direction_x)
		
	# move mob to player or move randomly
	if chase_player:
		velocity = direction * SPEED_CHASE
	else:
		velocity = random_direction * SPEED_RANDOM
	
	# transition from hurt animation to run animation
	if animated_sprite.animation == "hurt" and animated_sprite.frame == 4:
		animated_sprite.animation = "run"
	
	move_and_slide()
	
func on_health_depleted():
	queue_free()
		
	# add smoke effect when mob dies
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().call_deferred("add_child", smoke)
	smoke.global_position = global_position
	
	# generate xp gems when mob dies
	var gem = XP_GEM.instantiate()
	get_parent().call_deferred("add_child", gem)
	gem.global_position = global_position

func _on_chase_timer_timeout():
	chase_player = not chase_player
	
	# generate random direction
	var random_x = randf_range(-1,1)
	var random_y = randf_range(-1,1)
	random_direction = Vector2(random_x, random_y) 

func flip_sprite(dir):
	if dir > 0:
		animated_sprite.flip_h = true
	elif dir < 0:
		animated_sprite.flip_h = false
	
	
