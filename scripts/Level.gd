extends Label

var level = 1

func _on_player_level_up():
	level += 1
	text = "Lvl " + str(level) 
