extends Node

export (String) var new_scene_path = ""

func interacted():
	SceneChanger._change_scene(new_scene_path)