extends PopupPanel
signal confirmed(event)

enum Type{Keyboard, Gamepad}
var type: int
var tree_already_paused: bool = false
var source: Object

onready var Message: Label = $Mrg / Message
onready var nTimer: Timer = $Timer


func _ready() -> void :
	
	if get_tree().paused:
		tree_already_paused = true
	get_tree().paused = true
	Message.text = ggsManager.ggs_data["keybind_confirm_text"]
	nTimer.start()


func _input(event: InputEvent) -> void :
	
	match type:
		Type.Keyboard:
			if not (event is InputEventKey or event is InputEventMouseButton):
				return
		Type.Gamepad:
			if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				return
	
	
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton)\
	and event.pressed == false:
			return
	
	if event is InputEventJoypadMotion and abs(event.axis_value) < 1:
		return
	
	
	var actions: Array = _get_non_ui_actions(InputMap.get_actions())
	for action in actions:
		if InputMap.action_has_event(action, event):
			
			
			
			if event is InputEventJoypadMotion:
				var match_index = InputMap.get_action_list(action).find(event)
				if InputMap.get_action_list(action)[match_index].axis_value != event.axis_value:
					continue
			
			Message.text = ggsManager.ggs_data["keybind_assigned_text"]
			nTimer.start()
			return
	
	
	emit_signal("confirmed", event)
	get_tree().set_input_as_handled()
	
	
	if not tree_already_paused:
		get_tree().paused = false
	source.grab_focus()
	queue_free()


func _get_non_ui_actions(actions: Array) -> Array:
	var result: Array = []
	for action in actions:
		if not action.begins_with("ui_"):
			result.append(action)
	return result


func _on_Timer_timeout() -> void :
	if not tree_already_paused:
		get_tree().paused = false
	source.grab_focus()
	queue_free()
