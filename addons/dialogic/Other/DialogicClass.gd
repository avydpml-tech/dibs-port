extends Node









class_name Dialogic






















static func start(timeline: String = "", default_timeline: String = "", dialog_scene_path: String = "res://addons/dialogic/Nodes/DialogNode.tscn", use_canvas_instead = true):
	var dialog_scene = load(dialog_scene_path)
	var dialog_node = null
	var canvas_dialog_node = null
	var returned_dialog_node = null
	
	if use_canvas_instead:
		var canvas_dialog_script = load("res://addons/dialogic/Nodes/canvas_dialog_node.gd")
		canvas_dialog_node = canvas_dialog_script.new()
		canvas_dialog_node.set_dialog_node_scene(dialog_scene)
		dialog_node = canvas_dialog_node.dialog_node
	else:
		dialog_node = dialog_scene.instance()
	
	returned_dialog_node = dialog_node if not canvas_dialog_node else canvas_dialog_node
	
	
	if timeline == "":
		if (Engine.get_main_loop().has_meta("last_dialog_state")
			and not Engine.get_main_loop().get_meta("last_dialog_state").empty()
			and not Engine.get_main_loop().get_meta("last_dialog_state").get("timeline", "").empty()):
		
			dialog_node.resume_state_from_info(Engine.get_main_loop().get_meta("last_dialog_state"))
			return returned_dialog_node
		
		
		elif (Engine.get_main_loop().has_meta("current_timeline")
			and not Engine.get_main_loop().get_meta("current_timeline").empty()):
				timeline = Engine.get_main_loop().get_meta("current_timeline")
		
		
		else:
			timeline = default_timeline
	
	
	
	
	if timeline.ends_with(".json"):
		for t in DialogicUtil.get_timeline_list():
			if t["file"] == timeline:
				dialog_node.timeline = t["file"]
				dialog_node.timeline_name = timeline
				return returned_dialog_node
		
		dialog_node.dialog_script = {
			"events": [
				{"event_id": "dialogic_001", 
				"character": "", 
				"portrait": "", 
				"text": "[Dialogic Error] Loading dialog [color=red]" + timeline + "[/color]. It seems like the timeline doesn't exists. Maybe the name is wrong?"
			}]
		}
		return returned_dialog_node
	
	
	var timeline_file = _get_timeline_file_from_name(timeline)
	if timeline_file:
		dialog_node.timeline = timeline_file
		dialog_node.timeline_name = timeline
		return returned_dialog_node
	
	
	return returned_dialog_node





static func change_timeline(timeline: String) -> void :
	
	set_current_timeline(timeline)
	
	
	if has_current_dialog_node():
		var dialog_node = Engine.get_main_loop().get_meta("latest_dialogic_node")
		
		
		var timeline_file = _get_timeline_file_from_name(timeline)
		
		dialog_node.change_timeline(timeline_file)
	else:
		print("[D] Tried to change timeline, but no DialogNode exists!")




static func next_event(discreetly: bool = false):
	
	
	if has_current_dialog_node():
		var dialog_node = Engine.get_main_loop().get_meta("latest_dialogic_node")
		
		dialog_node.next_event(discreetly)










static func timeline_exists(timeline: String):
	var timeline_file = _get_timeline_file_from_name(timeline)
	if timeline_file:
		return true
	else:
		return false







static func load(slot_name: String = ""):
	_load_from_slot(slot_name)
	Engine.get_main_loop().set_meta("current_save_slot", slot_name)






static func save(slot_name: String = "", is_autosave = false) -> void :
	
	if is_autosave and not get_autosave():
		return
	
	
	var current_dialog_info = {}
	if has_current_dialog_node():
		current_dialog_info = Engine.get_main_loop().get_meta("latest_dialogic_node").get_current_state_info()
	
	var game_state = {}
	if Engine.get_main_loop().has_meta("game_state"):
		game_state = Engine.get_main_loop().get_meta("game_state")
	
	var save_data = {
		"game_state": game_state, 
		"dialog_state": current_dialog_info
		}
	
	
	_save_state_and_definitions(slot_name, save_data)



static func get_slot_names() -> Array:
	return DialogicResources.get_saves_folders()





static func erase_slot(slot_name: String) -> void :
	DialogicResources.remove_save_folder(slot_name)





static func has_current_dialog_node() -> bool:
	return Engine.get_main_loop().has_meta("latest_dialogic_node") and is_instance_valid(Engine.get_main_loop().get_meta("latest_dialogic_node"))





static func reset_saves(slot_name: String = "", reload: = true) -> void :
	DialogicResources.reset_save(slot_name)
	if reload: _load_from_slot(slot_name)



static func get_current_slot():
	if Engine.get_main_loop().has_meta("current_save_slot"):
		return Engine.get_main_loop().get_meta("current_save_slot")
	else:
		return ""






static func export (dialog_node = null) -> Dictionary:
	
	var current_dialog_info = {}
	if dialog_node == null and has_current_dialog_node():
		dialog_node = Engine.get_main_loop().get_meta("latest_dialogic_node")
	if dialog_node:
		current_dialog_info = dialog_node.get_current_state_info()
	
	
	return {
		"definitions": _get_definitions(), 
		"state": Engine.get_main_loop().get_meta("game_state"), 
		"dialog_state": current_dialog_info
	}



static func import(data: Dictionary) -> void :
	
	Engine.get_main_loop().set_meta("current_save_lot", "/")
	
	
	Engine.get_main_loop().set_meta("definitions", data["definitions"])
	Engine.get_main_loop().set_meta("game_state", data["state"])
	Engine.get_main_loop().set_meta("last_dialog_state", data.get("dialog_state", null))
	set_current_timeline(get_saved_state_general_key("timeline"))







static func clear_all_variables():
	for d in _get_definitions()["variables"]:
		d["value"] = ""


static func set_variable(name: String, value):
	var exists = false
	
	if "/" in name:
		var variable_id = _get_variable_from_file_name(name)
		if variable_id != "":
			for d in _get_definitions()["variables"]:
				if d["id"] == variable_id:
					d["value"] = str(value)
					exists = true
	else:
		for d in _get_definitions()["variables"]:
			if d["name"] == name:
				d["value"] = str(value)
				exists = true
	if exists == false:
		print("[Dialogic] Warning! the variable [" + name + "] doesn't exists. Create it from the Dialogic editor.")
	return value


static func get_variable(name: String, default = null):
	if "/" in name:
		var variable_id = _get_variable_from_file_name(name)
		for d in _get_definitions()["variables"]:
			if d["id"] == variable_id:
				return d["value"]
		print("[Dialogic] Warning! the variable [" + name + "] doesn't exists.")
		return default
	else:
		for d in _get_definitions()["variables"]:
			if d["name"] == name:
				return d["value"]
		print("[Dialogic] Warning! the variable [" + name + "] doesn't exists.")
		return default









static func get_saved_state_general_key(key: String, default = "") -> String:
	if not Engine.get_main_loop().has_meta("game_state"):
		return default
	if key in Engine.get_main_loop().get_meta("game_state").keys():
		return Engine.get_main_loop().get_meta("game_state")[key]
	else:
		return default



static func set_saved_state_general_key(key: String, value) -> void :
	if not Engine.get_main_loop().has_meta("game_state"):
		Engine.get_main_loop().set_meta("game_state", {})
	Engine.get_main_loop().get_meta("game_state")[key] = str(value)
	save("", true)








static func toggle_history():
	if has_current_dialog_node():
		var dialog_node = Engine.get_main_loop().get_meta("latest_dialogic_node")
		dialog_node.HistoryTimeline._on_toggle_history()
	else:
		print("[D] Tried to toggle history, but no dialog node exists.")




static func auto_advance_on(toggle: bool, delay: float = 2):
	if has_current_dialog_node():
		var dialog_node = Engine.get_main_loop().get_meta("latest_dialogic_node")
		dialog_node.autoPlayMode = toggle
		dialog_node.autoWaitTime = float(delay)
	else:
		print("[D] Tried to toggle auto advance mode, but no dialog node exists.")






static func get_autosave() -> bool:
	if Engine.get_main_loop().has_meta("autoload"):
		return Engine.get_main_loop().get_meta("autoload")
	return true


static func set_autosave(autoload):
	Engine.get_main_loop().set_meta("autoload", autoload)


static func set_current_timeline(timeline):
	Engine.get_main_loop().set_meta("current_timeline", timeline)
	return timeline


static func get_current_timeline():
	var timeline
	timeline = Engine.get_main_loop().get_meta("current_timeline")
	if timeline == null:
		timeline = ""
	return timeline



static func get_action_button():
	return DialogicResources.get_settings_value("input", "default_action_key", "dialogic_default_action")





static func _load_from_slot(slot_name: String = "") -> Dictionary:
	Engine.get_main_loop().set_meta("definitions", DialogicResources.get_saved_definitions(slot_name))
	
	var state_info = DialogicResources.get_saved_state_info(slot_name)
	Engine.get_main_loop().set_meta("last_dialog_state", state_info.get("dialog_state", null))
	Engine.get_main_loop().set_meta("game_state", state_info.get("game_state", null))
	
	return state_info.get("dialog_state", {})



static func _save_state_and_definitions(save_name: String, state_info: Dictionary) -> void :
	DialogicResources.save_definitions(save_name, _get_definitions())
	DialogicResources.save_state_info(save_name, state_info)



static func _get_definitions() -> Dictionary:
	var definitions
	if Engine.get_main_loop().has_meta("definitions"):
		definitions = Engine.get_main_loop().get_meta("definitions")
	else:
		definitions = DialogicResources.get_default_definitions()
		Engine.get_main_loop().set_meta("definitions", definitions)
	return definitions



static func set_glossary_from_id(id: String, title: String, text: String, extra: String) -> void :
	var target_def: Dictionary;
	for d in _get_definitions()["glossary"]:
		if d["id"] == id:
			target_def = d;
	if target_def != null:
		if title and title != "[No Change]":
			target_def["title"] = title
		if text and text != "[No Change]":
			target_def["text"] = text
		if extra and extra != "[No Change]":
			target_def["extra"] = extra


static func set_variable_from_id(id: String, value: String, operation: String) -> void :
	var target_def: Dictionary;
	for d in _get_definitions()["variables"]:
		if d["id"] == id:
			target_def = d;
	if target_def != null:
		var converted_set_value = value
		var converted_target_value = target_def["value"]
		var is_number = converted_set_value.is_valid_float() and converted_target_value.is_valid_float()
		if is_number:
			converted_set_value = float(value)
			converted_target_value = float(target_def["value"])
		var result = target_def["value"]
		
		match operation:
			"=":
				result = converted_set_value
			"+":
				result = converted_target_value + converted_set_value
			"-":
				if is_number:
					result = converted_target_value - converted_set_value
			"*":
				if is_number:
					result = converted_target_value * converted_set_value
			"/":
				if is_number:
					result = converted_target_value / converted_set_value
		target_def["value"] = str(result)


static func _get_timeline_file_from_name(timeline_name_path: String) -> String:
	var timelines = DialogicUtil.get_full_resource_folder_structure()["folders"]["Timelines"]
	
	
	if "/" in timeline_name_path:
		
		if (timeline_name_path.left(1) != "/"):
			timeline_name_path = "/" + timeline_name_path
		var parts = timeline_name_path.split("/", false)
	
		
		if parts.size() == 1:
			for t in DialogicUtil.get_timeline_list():
				for f in timelines["files"]:
					if t["file"] == f and t["name"] == parts[0]:
						return t["file"]
		if parts.size() > 1:
			var current_data
			var current_depth = 0
			for p in parts:
				if current_depth == 0:
					
					if (timelines["folders"].has(p)):
						current_data = timelines["folders"][p]
					else:
						return ""
				elif current_depth == parts.size() - 1:
					
					for t in DialogicUtil.get_timeline_list():
						for f in current_data["files"]:
							if t["file"] == f and t["name"] == p:
								return t["file"]
							
				else:
					
					if (current_data["folders"].size() > 0):
						if p in current_data["folders"]:
							current_data = current_data["folders"][p]
						else:
							return ""
					else:
						return ""
				current_depth += 1
		return ""
	else:
		
		for t in DialogicUtil.get_timeline_list():
			if t["name"] == timeline_name_path:
				return t["file"]
	return ""

static func _get_variable_from_file_name(variable_name_path: String) -> String:
	
	if (variable_name_path.left(1) != "/"):
		variable_name_path = "/" + variable_name_path

	var definitions = DialogicUtil.get_full_resource_folder_structure()["folders"]["Definitions"]
	var parts = variable_name_path.split("/", false)
	
	
	if parts.size() == 1:
		for t in _get_definitions()["variables"]:
			for f in definitions["files"]:
				if t["id"] == f and t["name"] == parts[0]:
					return t["id"]
	if parts.size() > 1:
		var current_data
		var current_depth = 0
		
		for p in parts:
			if current_depth == 0:

				
				if (definitions["folders"].has(p)):
					current_data = definitions["folders"][p]
				else:
					return ""
			elif current_depth == parts.size() - 1:
				
				for t in _get_definitions()["variables"]:
					for f in current_data["files"]:
						if t["id"] == f and t["name"] == p:
							return t["id"]
							
			else:
				
				if (current_data["folders"].size() > 0):
					if p in current_data["folders"]:
						current_data = current_data["folders"][p]
					else:
						return ""
				else:
					return ""
			current_depth += 1
	return ""
