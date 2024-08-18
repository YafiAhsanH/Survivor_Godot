extends Area2D

@export var experience = 1

var spr_blue = preload("res://assets/Kyrise_s 16x16 RPG Icon Pack - V1.2/icons/16x16/gem_01c.png")
var spr_green = preload("res://assets/Kyrise_s 16x16 RPG Icon Pack - V1.2/icons/16x16/gem_01a.png")
var spr_red = preload("res://assets/Kyrise_s 16x16 RPG Icon Pack - V1.2/icons/16x16/gem_01d.png")

var target = null
var speed = -1

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_green
	else:
		sprite.texture = spr_red
		
func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 4 * delta

func collect():
	#play sound
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	queue_free()
	return experience
	

