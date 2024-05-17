extends Node

const CHARACTER_SPRITE_RESOURCES = [
	"res://resources/ninja_frog_animation.tres",
	"res://resources/pink_guy_animation.tres",
	"res://resources/mask_dude_animation.tres",
	"res://resources/virtual_guy_animation.tres"
]

var selected_character_index = 0

func next_character():
	selected_character_index += 1
	if selected_character_index == CHARACTER_SPRITE_RESOURCES.size():
		selected_character_index = 0
		
func prev_character():
	selected_character_index -= 1
	if selected_character_index < 0:
		selected_character_index = CHARACTER_SPRITE_RESOURCES.size() - 1

func load_character():
	return ResourceLoader.load(CHARACTER_SPRITE_RESOURCES[selected_character_index])
