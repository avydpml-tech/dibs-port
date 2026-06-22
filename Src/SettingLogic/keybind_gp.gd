extends Node






func main(value: Dictionary) -> void :
	var target_action: String = value["action_name"]
	var action_list: Array = InputMap.get_action_list(target_action)
	var prev_event: InputEventJoypadButton = Utils.array_find_type(action_list, "InputEventJoypadButton")
	var new_event: InputEventJoypadButton = InputEventJoypadButton.new()
	new_event.button_index = value["value"]

	InputMap.action_erase_event(target_action, prev_event)
	InputMap.action_add_event(target_action, new_event)
