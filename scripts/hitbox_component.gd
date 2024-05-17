extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent
@export var animated_sprite : AnimatedSprite2D 

func damage(damage):
	if health_component:
		if animated_sprite:
			animated_sprite.play("hurt")
		health_component.take_damage(damage)
