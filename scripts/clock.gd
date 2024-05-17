extends CanvasLayer

@onready var clock_label = $ClockLabel
var second = 0
var minute = 0
var second_label = ""
var minute_label = ""

signal next_stage

func _ready():
	Clock.next_stage.connect(MobManager._on_stage_next)

func start():
	reset()
	visible = true

func stop():
	visible = false

func _on_timer_timeout():
	second += 1
	if second > 60:
		second = 0
		minute += 1
	
	if minute / 10 < 1:
		minute_label = "0" + str(minute)
	else:
		minute_label = str(minute)
	
	if second / 10 < 1:
		second_label = "0" + str(second)
	else:
		second_label = str(second)
		
	clock_label.text = minute_label + ":" + second_label
	
	if Clock.minute == 0 and Clock.second == 30:
		next_stage.emit()
		
func reset():
	second = 0
	minute = 0
	second_label = ""
	minute_label = ""
	clock_label.text = "00:00"
	
