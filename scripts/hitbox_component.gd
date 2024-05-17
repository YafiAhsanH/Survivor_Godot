extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent 

func damage(damage):
	if health_component:
		health_component.take_damage(damage)
