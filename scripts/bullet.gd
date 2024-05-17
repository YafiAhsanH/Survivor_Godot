extends Area2D

const SPEED = 300.0
var travelled_distance = 0
var RANGE = 1200.0

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	
	if travelled_distance > RANGE:
		queue_free()

func _on_hitbox_area_entered(area):
	queue_free()
	if area is HitboxComponent:
		area.damage(1)
