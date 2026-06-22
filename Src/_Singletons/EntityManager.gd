extends Node





var print_debug_status: bool = false
var persistent_entity_list = []


func generic_ready():
	load_creatures()
	call_deferred("check_if_entity_alive")


func check_if_entity_alive():
	for entity in get_tree().get_nodes_in_group("Nonplayer"):
		if not entity.is_alive:
			entity.is_alive()


func print_persistent_entity_list():
	print_debug("EntityManager: ", persistent_entity_list)

	
func reset_entities_list():
	persistent_entity_list = []
	if print_debug_status:
		
		print_persistent_entity_list()



func load_creatures():
	if print_debug_status:
		
		print_persistent_entity_list()

	var persistent_objects = persistent_entity_list

	if persistent_objects.size() <= 0:
		return

	for f in get_tree().get_nodes_in_group("Nonplayer"):
		if not f.has_method("save"):
			continue
			
		var save_nodes = f.call("save")

		
		for i in persistent_entity_list:
			var same_id = save_nodes["unique_id"] == i["unique_id"]
			var same_path = save_nodes["owner_path"] == i["owner_path"]
			
			if same_id and same_path:
				f.is_alive = i["is_alive"]









func save_entity(save_dict):
	
	

	
	if persistent_entity_list == []:
		persistent_entity_list.append(save_dict)
		
		return
		

	
	
	
	
	
	
	
	
	
	
		
	
	
	
	
	
	
	persistent_entity_list.append(save_dict)





func save():
	var save = {
		"persistent_entity_list": persistent_entity_list, 
	}
	return save


func load_data(data_dict):
	if data_dict == null: return

	for key in data_dict:
		set(key, data_dict[key])
