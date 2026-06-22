extends OptionButton

export (int, 0, 99) var setting_index: int
var script_instance: Object


func _ready() -> void :
	
	var current = ggsManager.settings_data[str(setting_index)]["current"]
	selected = current["value"]
	
	
	var script: Script = load(ggsManager.settings_data[str(setting_index)]["logic"])
	script_instance = script.new()
	
	
	connect("item_selected", self, "_on_item_selected")
	connect("mouse_entered", self, "_on_mouse_entered")


func reset_to_default() -> void :
	var default = ggsManager.settings_data[str(setting_index)]["default"]
	_on_item_selected(default["value"])
	selected = default["value"]


func _on_item_selected(index: int) -> void :
	var current = ggsManager.settings_data[str(setting_index)]["current"]
	current["value"] = index
	ggsManager.save_settings_data()
	script_instance.main(current)



func _on_mouse_entered() -> void :
	grab_focus()
