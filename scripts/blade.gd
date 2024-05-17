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

func _on_hitbox_area_entered(area):
	if area is HitboxComponent:
		area.damage(2)
