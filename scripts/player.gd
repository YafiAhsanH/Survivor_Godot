extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurt_box = %HurtBox
@onready var health_bar = $HealthBar
@onready var experience_bar = $ExperienceBar
@onready var blade = %Blade

const SPEED = 200.0
var health = 100.0
const DAMAGE_RATE = 5.0
var xp = 0
var xp_multiplier = 1
var level = 1
var faced_direction = Enums.DIRECTION.RIGHT

signal health_depleted
signal level_up

func _ready():
	animated_sprite.sprite_frames = CharacterManager.load_character()
	animated_sprite.play("idle")

func _physics_process(delta):
	# get direction (x, y)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# calculate velocity
	velocity = direction * SPEED
	
	# get direction of x axis
	var direction_x = direction[0]
	
	
	# flip sprite based on x axis direction
	if direction_x < 0:
		faced_direction = Enums.DIRECTION.LEFT
		animated_sprite.flip_h = true
	elif direction_x > 0:
		faced_direction = Enums.DIRECTION.RIGHT
		animated_sprite.flip_h = false
	
	# determine animation
	if velocity.length() > 0.0:
		animated_sprite.animation = "run"
	else:
		animated_sprite.animation = "idle"
		
	var overlapping_mobs = hurt_box.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		health_bar.value = health
		if health <= 0.0:
			emit_signal("health_depleted")
	
	# call action on left-click
	if Input.is_action_just_pressed("left_click"):
		action_left_click(faced_direction)
	
	move_and_slide()
	
func gain_xp(xp_gained):
	xp += xp_gained * xp_multiplier
	experience_bar.value = xp 
	
	# handle level up
	if xp >= 100:
		level += 1
		xp = 0
		xp_multiplier = xp_multiplier * 0.95
		experience_bar.value = xp
		emit_signal("level_up")
		
func action_left_click(dir_x):
	blade.attack(dir_x)
	
