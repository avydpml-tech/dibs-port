extends Node








func main(value: Dictionary) -> void :
	OS.window_fullscreen = value["value"]
	
	
	
	if value["value"] == false:
		var script_resource: Script = load(value["window_script_path"])
		var script_instance: Object = script_resource.new()
		var current = ggsManager.settings_data[str(value["window_setting_index"])]["current"]
		script_instance.main(current)
	
	OS.center_window()
