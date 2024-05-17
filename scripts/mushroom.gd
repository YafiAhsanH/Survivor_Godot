extends CharacterBody2D

@onready var player = $/root/Game/Player
@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 80.0 
var health = 1

# debug
func _ready():
	#animated_sprite.stop()
	pass

func _physics_process(delta):
	# get direction to player
	var direction = global_position.direction_to(player.global_position)
	var direction_x = direction[0]
	
	# flip sprite left or right
	if direction_x > 0:
		animated_sprite.flip_h = true
	elif direction_x < 0:
		animated_sprite.flip_h = false
	
	# move mob to player	
	velocity = direction * SPEED
	
	# transition from hurt animation to run animation
	if animated_sprite.animation == "hurt" and animated_sprite.frame == 4:
		animated_sprite.animation = "run"
	
	move_and_slide()
	
func take_damage():
	animated_sprite.animation = "hurt"
	health -= 1
	if health <= 0:
		queue_free()
		
		# add smoke effect when mob dies
		const SMOKE_SCENE = preload("res://scenes/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().call_deferred("add_child", smoke)
		smoke.global_position = global_position
		
		# generate xp gems when mob dies
		const XP_GEM = preload("res://scenes/experience_gem.tscn")
		var gem = XP_GEM.instantiate()
		get_parent().call_deferred("add_child", gem)
		gem.global_position = global_position
		

# debug
func _on_visible_on_screen_notifier_2d_screen_exited():
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$CollisionShape2D.debug_color = Color(0,0,0,1)
	print("out")

# debug
func _on_visible_on_screen_notifier_2d_screen_entered():
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.disabled = false
	print("in")
