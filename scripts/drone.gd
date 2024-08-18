extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var attack_timer = $AttackTimer

var distance_to_player = 0
var tween: Tween
var anticipation_flag: bool = false
var follow: bool = false
var speed = 200
var anticipation_base_amount = 300
var anticipation_recovery = 10
var anticipation = Vector2.ZERO
var brake_flag = false
var brake = 10

var level = 1
var attack_speed = 0.2
var reset_position: Marker2D
var target = Vector2(1,1)

var direction
var negative_angle
var negative_point

var random_number = 0

func _ready():
	random_number = randf()
	
	#position = player.position
	level = player.drone_level
	match level:
		1:
			attack_speed = 0.2
		2:
			attack_speed = 0.1
		3:
			attack_speed = 0.1
		4:
			attack_speed = 0.1
	
	attack_timer.wait_time = attack_speed
	tween = create_tween().set_loops()
	tween.tween_property(sprite, "offset", Vector2(0, 10), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "offset", Vector2(0, -10), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
func _physics_process(delta):
	#distance_to_player = position.distance_to(player.position)
	#direction = global_position.direction_to(player.global_position)
	
	distance_to_player = global_position.distance_to(reset_position.global_position)
	direction = global_position.direction_to(reset_position.global_position)
	
	anticipation = anticipation.move_toward(Vector2.ZERO, anticipation_recovery)
		
	if distance_to_player > 100 and not anticipation_flag and not follow:
		anticipation_flag = true
		follow = true
		set_anticipation()
		
	if follow:
		velocity = direction * speed
		velocity += anticipation
		
	if brake_flag:
		follow = false
		velocity = velocity.move_toward(Vector2.ZERO, brake)
		if velocity <= Vector2.ZERO:
			brake_flag = false
	
	if distance_to_player < 50 and follow:
		brake_flag = true
		anticipation_flag = false
	
	move_and_slide()
	
func set_anticipation():
	#negative_angle = global_position.direction_to(player.global_position) * -1
	reset_position.global_position = player.global_position + Vector2(randf_range(-1,1) * 60, randf_range(-1,1) * 60)
	negative_angle = global_position.direction_to(reset_position.global_position) * -1
	
	anticipation = negative_angle * anticipation_base_amount

func _on_area_2d_body_entered(body):
	#if body.is_in_group("player"):
		#brake_flag = true
		#anticipation_flag = false
	pass
		
func _on_attack_timer_timeout():
	if target:
		#attack target
		#print("attack" + str(random_number))
		pass
