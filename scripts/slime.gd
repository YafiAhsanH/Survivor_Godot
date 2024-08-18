extends CharacterBody2D

@onready var player = $/root/Game/Player
@onready var sprite = $Sprite2D

const SPEED = 80.0 

func _physics_process(delta):
	# get direction to player
	var direction = global_position.direction_to(player.global_position)
	var direction_x = direction[0]
	
	# flip sprite left or right
	if direction_x > 0:
		sprite.flip_h = true
	elif direction_x < 0:
		sprite.flip_h = false
	
	# move mob to player	
	velocity = direction * SPEED
	
	move_and_slide()
