extends CharacterBody2D

@onready var player = $/root/Game/Player
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_component = $HealthComponent

@export var SPEED = 80.0 
@export var knockback_recovery = 3.5
@export var experience = 1
var knockback = Vector2.ZERO

@onready var loot_base = get_tree().get_first_node_in_group("loot")

const SMOKE_SCENE = preload("res://scenes/smoke_explosion.tscn")
const XP_GEM = preload("res://scenes/experience_gem.tscn")
var exp_gem = preload("res://scenes/xp_gem.tscn")

signal remove_from_array(object)

# debug
func _ready():
	#animated_sprite.stop()
	pass

func _physics_process(delta):
	# calculate knockback
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
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
	
	# add knockback to movement (if any)
	velocity += knockback
	
	# transition from hurt animation to run animation
	if animated_sprite.animation == "hurt" and animated_sprite.frame == 4:
		animated_sprite.animation = "run"
	
	move_and_slide()
	
func on_health_depleted():
	emit_signal("remove_from_array", self)
	queue_free()
		
	# add smoke effect when mob dies
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().call_deferred("add_child", smoke)
	smoke.global_position = global_position
	
	# generate xp gems when mob dies
	var gem = exp_gem.instantiate()
	get_parent().call_deferred("add_child", gem)
	gem.global_position = global_position
	gem.experience = experience

# debug
func _on_visible_on_screen_notifier_2d_screen_exited():
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$CollisionShape2D.debug_color = Color(0,0,0,1)
	#print("out")

# debug
func _on_visible_on_screen_notifier_2d_screen_entered():
	$AnimatedSprite2D.visible = true
	$CollisionShape2D.disabled = false
	#print("in")

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	knockback = angle * knockback_amount
	if animated_sprite:
		animated_sprite.play("hurt")
	health_component.take_damage(damage)
