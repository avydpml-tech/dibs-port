extends CheckButton

export (int, 0, 99) var setting_index: int
export (String, MULTILINE) var option_description: String = "temp"
var script_instance: Object



func _ready() -> void :
	
	var current: Dictionary = ggsManager.settings_data[str(setting_index)]["current"]
	pressed = current["value"]
	
	
	var script: Script = load(ggsManager.settings_data[str(setting_index)]["logic"])
	script_instance = script.new()
	
	
	connect("toggled", self, "_on_toggled")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("focus_entered", self, "_on_focus_entered")


func reset_to_default() -> void :
	var default: Dictionary = ggsManager.settings_data[str(setting_index)]["default"]
	_on_toggled(default["value"])
	pressed = default["value"]


func update_button() -> void :
	var default: Dictionary = ggsManager.settings_data[str(setting_index)]["current"]
	_on_toggled(default["value"])
	pressed = default["value"]


func _on_toggled(button_pressed: bool) -> void :
	var current: Dictionary = ggsManager.settings_data[str(setting_index)]["current"]
	current["value"] = button_pressed
	ggsManager.save_settings_data()
	script_instance.main(current)



func update_button_status() -> void :
	var default: Dictionary = ggsManager.settings_data[str(setting_index)]["current"]
	pressed = default["value"]


func _on_mouse_entered():
	grab_focus()

func _on_mouse_exited():
	release_focus()



func _on_focus_entered() -> void :

	if not has_node("../../optionDescription"):
		return

	var label = get_node("../../optionDescription")
	if label != null:
		label.text = option_description

