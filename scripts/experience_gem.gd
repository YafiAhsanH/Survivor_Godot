extends Area2D

@onready var player = $/root/Game/Player

const SPEED = 200.0
var moving = false

func _process(delta):
	# move xp towards player
	if moving:
		var direction = global_position.direction_to(player.global_position)
		position += direction * SPEED * delta

func _on_body_entered(body):
	queue_free()
	if body.has_method("gain_xp"):
		body.gain_xp(10)

func _on_magnet_body_entered(body):
	moving = true
