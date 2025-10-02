extends Node2D

# Path to the scene we want to load
const SECOND_SCENE_PATH = "res://scenes/Test World/World.tscn"

func _ready():
	# Connect the button pressed signal
	$Button.pressed.connect(_on_Button_pressed)

func _on_Button_pressed():
	# Correct function for Godot 4
	get_tree().change_scene_to_file(SECOND_SCENE_PATH)
