extends Node

const MUSHROOM = preload("res://scenes/mushroom.tscn")
const BUNNY = preload("res://scenes/bunny.tscn")
const stage_mobs = [MUSHROOM, BUNNY]
var stage = 0
var mob_count = 0


func _on_stage_next():
	stage += 1

func make_mob():
	mob_count += 1
	return stage_mobs[stage].instantiate()
	
func reset():
	stage = 0
	mob_count = 0
