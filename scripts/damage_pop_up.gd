extends Marker2D

var damage

@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func _ready():
	_update()

func _update():
	label.text = str(damage)

