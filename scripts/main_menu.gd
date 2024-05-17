extends Control

@onready var animated_sprite = $CanvasLayer/AnimatedSprite2D

func _ready():
	load_animation()

func _on_play_button_pressed():
	reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_next_skin_button_pressed():
	CharacterManager.next_character()
	load_animation()
	
func _on_prev_skin_button_pressed():
	CharacterManager.prev_character()
	load_animation()
	
func load_animation():
	animated_sprite.sprite_frames = CharacterManager.load_character()
	animated_sprite.play("run")

func reset():
	Clock.reset()
	MobManager.reset()



