extends Node

var current_ending: String = ""

func start_ending(ending_name: String):
	print(get_name() + ": " + ending_name + " ending started.")
	
	current_ending = ending_name
	SceneChanger._change_scene("res://Src/MiscScenes/endingScene/endingScene.tscn")
