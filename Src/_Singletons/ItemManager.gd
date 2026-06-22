extends Node





var persistent_objects_list = []
var persistent_ammo_arr = []

func generic_ready():
	load_item_variables()
	call_deferred("activate_items")







func activate_items():
	var persistent_items = get_tree().get_nodes_in_group("ItemPersist")
	for item in persistent_items:
		if item.activated:
			item.item_activated()
	

func print_persistent_objects_list():
	print_debug("ItemManager: ", persistent_objects_list)


func reset_objects_list():
	persistent_objects_list = []
	persistent_ammo_arr = []
	
	














func save_item(item_dict):
	print_debug("ItemManager: ----------------------item saving----------------------")
	
	if persistent_objects_list == []:
		persistent_objects_list.append(item_dict)
		print_debug("ItemManager: ItemManager is empty. Appending list.")
		
		return
		
	
	for obj in persistent_objects_list:
		var same_id = item_dict["unique_id"] == obj["unique_id"]
		var same_path = item_dict["owner_path"] == obj["owner_path"]
		
		if same_id and same_path:
			obj["activated"] = item_dict["activated"]
			
			return
	
	persistent_objects_list.append(item_dict)
	


	
func load_item_variables():
	var persistent_objects = persistent_objects_list
	if persistent_objects.size() <= 0:
		return

	
	

	for item in get_tree().get_nodes_in_group("ItemPersist"):
		
		if not item.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % item.name)
			continue
			
		var save_nodes = item.call("save")

		for stored_object in persistent_objects:
			var is_same_id = save_nodes["unique_id"] == stored_object["unique_id"]
			var is_same_path = save_nodes["owner_path"] == stored_object["owner_path"]

			if is_same_id and is_same_path:
				item.activated = stored_object["activated"]







func parse_for_ammo_in_scene():
	print(self.get_name(), ": ----------------------Parsing Scene for Ammo----------------------")
	for mag in get_tree().get_nodes_in_group("Ammo"):
		if not mag.is_temporary:
			return

		var is_in_arr: bool = false
		
		
		for entry in persistent_ammo_arr:
			var is_same_id = mag.get_name() == entry["unique_id"]
			var is_same_owner = mag.get_owner().get_filename() == entry["owner_path"]

			if is_same_id and is_same_owner:
				is_in_arr = true

		if not is_in_arr:
			ItemManager.save_ammo_to_arr(mag.save_ammo())

		is_in_arr = false




func save_ammo_to_arr(save_dict):
	
	print_debug("ItemManager: ----------------------Mag saving----------------------")

	
	if persistent_ammo_arr == []:
		persistent_ammo_arr.append(save_dict)
		print_debug("ItemManager: persistent_ammo_arr is empty. Appending list.")
		return
		
	
	persistent_ammo_arr.append(save_dict)
	


func load_ammo_in_this_scene(current_scene: Node):
	print_debug("ItemManager: ----------------------Mag loading----------------------")
	var persistent_objects = persistent_ammo_arr

	
	if persistent_objects.size() <= 0:
		print_debug(self.get_name(), ": No persistent ammo detected. Not loading.")
		return

	
	
	
	
	
	
	

	for object in persistent_objects:
		
		if object.has("owner_path"):
			if object["owner_path"] != current_scene.get_filename():
				print_debug("Object \"", object["unique_id"], "\" should not be in this scene. ", \
				"This should instead be in", " ", object["owner_path"])
				continue
		else:
			continue

		
		var new_object = load(object["filename"]).instance()
		
		current_scene.add_child(new_object)
		new_object.set_owner(current_scene)
		new_object.set_name(object["unique_id"])
		new_object.set_filename(object["filename"])
		new_object.global_position = Vector2(object["pos_x"], object["pos_y"])

		
		for i in object.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "unique_id":
				continue
			new_object.set(i, object[i])
			new_object._ready()
	_remove_ammo_from_arr(current_scene)












func _remove_ammo_from_arr(current_scene: Node):
	
	var arr = persistent_ammo_arr
	for i in arr:
		if i["owner_path"] == current_scene.get_filename():
			arr.erase(i)
			return






func save():
	var save = {
		"persistent_objects_list": persistent_objects_list, 
		"persistent_ammo_arr": persistent_ammo_arr, 
	}
	return save


func load_data(data_dict):
	if data_dict == null: return

	for key in data_dict:
		set(key, data_dict[key])












		















		






			






























	
























\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
"\r\nfunc load_scene(scene_filename, root_path_to_node):\r\n\tprint_debug('----------------------scene loaded----------------------')\r\n\tprint_debug(persistent_objects_list)\r\n\r\n\t# We use a Globals.list instead of a savefile. \r\n\tvar persistent_objects = Globals.persistent_objects_list\r\n\r\n\t# If the list is empty, don't run program.\r\n\tif persistent_objects.size() <= 0:\r\n\t\treturn\r\n\r\n\t# We need to revert the game state so we're not cloning objects\r\n\t# This is done by deleting saveable objects below.\r\n\tvar save_nodes = get_tree().get_nodes_in_group(\"Persist\")\r\n\tfor i in save_nodes:\r\n\t\ti.queue_free()\r\n\r\n\tfor object in persistent_objects:\r\n\t\t# Instances the object to its position.\r\n\t\tvar new_object = load(object[\"filename\"]).instance()\r\n\r\n\t\t# Makes sure the object only spawns in a specific scene.\r\n\t\t# Also makes sure the player is not persisting. \r\n\t\tif object.has('owner_path'):\r\n\t\t\tprint_debug(object['owner_path'])\r\n\t\t\tif object['owner_path'] != scene_filename:\r\n\t\t\t\tprint_debug('This object should not be in this scene', \" \", object['owner_path'])\r\n\t\t\t\tcontinue\r\n\t\telse:\r\n\t\t\tcontinue\r\n\r\n\t\t\r\n\t\tget_node(root_path_to_node).add_child(new_object)\r\n\t\tnew_object.set_owner(object['owner'])\r\n\t\tnew_object.position = Vector2(object[\"pos_x\"], object[\"pos_y\"])\r\n\r\n\t\t# Now we set the remaining variables.\r\n\t\tfor i in object.keys():\r\n\t\t\tif i == \"filename\" or i == \"parent\" or i == \"pos_x\" or i == \"pos_y\":\r\n\t\t\t\tcontinue\r\n\t\t\tnew_object.set(i, object[i]) # e.x. {'health': 100}\t\r\n"

			
\
\
\
\
\
\
\
"\r\nNOTE: These save functions only work if it is not a nested Persist\r\n\t  Object (i.e, Persist object that is a child of another persist Object).\r\n\t  Otherwise, it will return 'file not found''\r\n''\t\r\nOk, on Windows ' user:// ' is in the appdata folder.\r\n''\r\n"
