extends Button

export (String, FILE) var new_scene_path
export (bool) var player_skipped = false
export (bool) var reset_everything = false

func _on_changeSceneButton_pressed():
	if reset_everything:
		reset_game()
	
	if player_skipped:
		player_skipped()
	SceneChanger._change_scene(new_scene_path)

func player_skipped():
	EventManager.link_to_target("res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn", "lockedDoor", true)

func reset_game():
	Globals.reset_everything()