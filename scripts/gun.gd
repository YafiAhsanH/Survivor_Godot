extends Area2D

@onready var shooting_point = %ShootingPoint
@onready var sprite = $WeaponPivot/Sprite2D

func _physics_process(delta):
	# follow closest enemy
	#var enemies_in_range = get_overlapping_bodies()
	#
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range[0]
		#look_at(target_enemy.global_position)
		
	look_at(get_global_mouse_position())
	
	# flip gun vertically on the left side
	var rotation = global_rotation_degrees
	if abs(rotation) > 90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
	

func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	shooting_point.add_child(new_bullet)


func _on_timer_timeout():
	shoot()
