extends Node








var curr_start_pos: String = ""

var previous_pos: String = ""
var previous_level: String = ""

var pos_before_gallery: String = ""
var level_before_gallery: String = ""




func pass_scene_properties(where_is_exit_point, root_scene_node):
	set_scene_before_gallery(root_scene_node)
	previous_level = root_scene_node.get_filename()
	curr_start_pos = where_is_exit_point


func set_scene_before_gallery(root_scene_node):
	if not root_scene_node in get_tree().get_nodes_in_group("Gallery"):
		level_before_gallery = root_scene_node.get_filename()
		pos_before_gallery = curr_start_pos


func place_player():
	for load_pos in get_tree().get_nodes_in_group("LoadPos"):
		if load_pos.get_name() == PosManager.curr_start_pos:
			get_player().global_position = load_pos.global_position


func get_player():
	for player in get_tree().get_nodes_in_group("Player"):
		return player

func set_start_location(new_location):
	curr_start_pos = new_location