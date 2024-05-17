extends Node2D

@onready var path_follow = %PathFollow2D
@onready var game_over = %GameOver

var probability
var new_mob

@onready var mob_count_label = $CanvasLayer/MobCount

func _ready():
	Clock.start()

# debug
func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#var bodies = $Player/Nuke.get_overlapping_bodies()
		#for body in bodies:
			#if body.is_in_group("mob"):
				#body.take_damage()
	pass

func spawn_mob():
	probability = randf()
	
	#if probability < 0.75:
		#new_mob = MUSHROOM.instantiate()
	#else:
		#new_mob = BUNNY.instantiate()
	
	# debug
	new_mob = MobManager.make_mob()
	
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)
	
	# debug mob count
	mob_count_label.text = str(MobManager.mob_count)
	
func on_timer_timeout():
	spawn_mob()

func _on_player_health_depleted():
	game_over.visible = true
	get_tree().paused = true
