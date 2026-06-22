extends Area2D


export (String) var scene_path_to_load = ""
export (String) var where_is_exit_point = ""
export (float) var time_delay = 0.1
export (bool) var turn_off_music = false


func _ready():
	add_to_group("Doors")
	$timeDelay.start()


func _on_Transition_point_body_entered(body):
	if body.get_name() == "playerChar":
		stop_player()
		PosManager.pass_scene_properties(where_is_exit_point, get_owner())

		get_node("/root/SceneChanger")._change_scene(scene_path_to_load, time_delay)
		_turn_off_music()
		ItemManager.parse_for_ammo_in_scene()


func stop_player():
	
	pass

func _turn_off_music():
	if turn_off_music:
		SoundManager.stop_music()
	pass
