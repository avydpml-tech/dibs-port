extends Stage

func _ready():
	_generic_ready()
	_preload_next_scene()
	

func _preload_next_scene():
	var door = $"Transition_point"
	door.where_is_exit_point = PosManager.pos_before_gallery
	if PosManager.level_before_gallery != "":
		door.scene_path_to_load = PosManager.level_before_gallery
	else:
		door.scene_path_to_load = "res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn"
