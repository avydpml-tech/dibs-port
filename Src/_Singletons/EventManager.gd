extends Node






















var target_objs_dict = {}









var relationship_log_dict = {}





func link_to_target(target_scene, target_node, var variant):
	_add_to_dictionary(target_objs_dict, 
							target_scene, 
							target_node, 
							variant)

	
			


func log_relationship(owner, name, target_node):
	_add_to_dictionary(relationship_log_dict, 
							owner, 
							name, 
							target_node)


func _add_to_dictionary(dict, arg1, arg2, arg3):
	if not dict.has(arg1):
		dict[arg1] = {arg2: arg3}
	else:
		dict[arg1][arg2] = arg3



func apply_properties_to_target(current_root_scene_path):

	
	if current_root_scene_path.substr(0, 6) != "res://":
		print_debug(self.get_name(), ": Recieved argument is not file path.")
		return
	if not target_objs_dict.has(current_root_scene_path):
		print_debug(self.get_name(), ": Received root scene not found in dictionary of targets.")
		return

	var target_nodes_dict = target_objs_dict.get(current_root_scene_path)

	
	
	
	
	
	

	for key in target_nodes_dict:
		var variant = target_nodes_dict[key]
		for obj in get_tree().get_nodes_in_group(key):
			if obj != null and obj.has_method("_interacted_by_EventManager"):
				obj._interacted_by_EventManager(variant)


func clear():
	relationship_log_dict = {}
	target_objs_dict = {}





func save():
	var save = {
		"relationship_log_dict": relationship_log_dict, 
		"target_objs_dict": target_objs_dict, 
	}
	return save


func load_data(data_dict):
	if data_dict == null: return

	for key in data_dict:
		set(key, data_dict[key])
