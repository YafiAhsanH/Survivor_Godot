extends Node2D

@onready var animation_player = $AnimationPlayer

func attack(dir_x):
	match dir_x:
		Enums.DIRECTION.LEFT:
			animation_player.play("attack_left")
		Enums.DIRECTION.RIGHT: 
			animation_player.play("attack_right")
		_:
			print("wrong parameter!")

func _on_blade_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
