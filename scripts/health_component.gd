extends Node2D
class_name HealthComponent

@export var max_health := 100.0
@onready var popup_location = $PopupLocation

var health: float

signal health_depleted

func _ready():
	health = max_health

func take_damage(damage):
	health -= damage
	popup_location.popup(damage)
	if health <= 0:
		health_depleted.emit()
