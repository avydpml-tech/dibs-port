extends Node

signal bored_mode_set
signal exploration_mode_set
signal sfw_mode_set(value)
signal one_handed_mode_set
signal jump_stamina_drain_set
signal infinite_ammo_mode_set
signal auto_combine_ammo_mode_set
signal one_handed_deadzone_set


var keyboard_layout = "QWERTY"
var controls = {
	
	"QWERTY": [KEY_SPACE, KEY_W, KEY_A], 
	"AZERTY": [KEY_SPACE, KEY_Z, KEY_Q]
}
var input_map = ["ui_up", "ui_up", "ui_left"]



var is_bored_mode: bool = false setget set_bored_mode
var is_exploration_mode: bool = false setget set_exploration_mode
var is_sfw_mode: bool = false setget set_sfw_mode
var is_one_handed_mode: bool = false setget set_one_handed_controls
var is_jump_stamina_drain_mode: bool = false setget set_jump_stamina_drain_mode
var is_frisky: bool = false setget set_frisky
var is_infinite_ammo_mode: bool = false setget set_infinite_ammo_mode
var is_auto_combine_ammo_mode: bool = false setget set_auto_combine_mode


var is_autosave: bool = true
var one_handed_deadzone: float = 0 setget set_one_handed_deadzone


func set_bored_mode(value):
	is_bored_mode = value
	
	emit_signal("bored_mode_set")


func set_exploration_mode(value):
	is_exploration_mode = value
	if is_exploration_mode:
		connect_plants_to_exploration_mode()
	emit_signal("exploration_mode_set")


func set_sfw_mode(value):
	is_sfw_mode = value
	emit_signal("sfw_mode_set")


func set_one_handed_controls(value):
	is_one_handed_mode = value
	emit_signal("one_handed_mode_set")


func set_jump_stamina_drain_mode(value):
	is_jump_stamina_drain_mode = value
	emit_signal("jump_stamina_drain_set")



func set_frisky(value):
	is_frisky = value

func set_infinite_ammo_mode(value):
	is_infinite_ammo_mode = value
	emit_signal("infinite_ammo_mode_set")


func set_auto_combine_mode(value):
	is_auto_combine_ammo_mode = value
	emit_signal("auto_combine_ammo_mode_set")


func set_one_handed_deadzone(value):
	one_handed_deadzone = value
	emit_signal("one_handed_deadzone_set")


func connect_plants_to_exploration_mode():
	for p in get_tree().get_nodes_in_group("Nonplayer"):
		
		if not self.is_connected("exploration_mode_set", p, "exploration_mode_changed"):
			self.connect("exploration_mode_set", p, "exploration_mode_changed")
		


func change_keyboard_layout( var is_qwerty: bool):
	keyboard_layout = "QWERTY" if is_qwerty else "AZERTY"
	add_input_events(keyboard_layout)

	var other_layout = "QWERTY" if not is_qwerty else "AZERTY"
	remove_input_events(other_layout)



func add_input_events( var keyboard_layout):
	
	for i in range(len(input_map)):
		var event = InputEventKey.new()
		event.scancode = controls[keyboard_layout][i]
		InputMap.action_add_event(input_map[i], event)



func remove_input_events( var keyboard_layout_to_remove):
	for i in range(len(input_map)):
		var event = InputEventKey.new()
		event.scancode = controls[keyboard_layout_to_remove][i]
		InputMap.action_erase_event(input_map[i], event)













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
"\r\nhttps://docs.godotengine.org/en/stable/classes/class_@globalscope.html#enumerations\r\nKEY_SPACE = 32 --- Space key.\r\nKEY_AT = 64 --- @ key.\r\nKEY_A = 65 --- A key.\r\nKEY_B = 66 --- B key.\r\nKEY_C = 67 --- C key.\r\nKEY_D = 68 --- D key.\r\nKEY_E = 69 --- E key.\r\nKEY_F = 70 --- F key.\r\nKEY_G = 71 --- G key.\r\nKEY_H = 72 --- H key.\r\nKEY_I = 73 --- I key.\r\nKEY_J = 74 --- J key.\r\nKEY_K = 75 --- K key.\r\nKEY_L = 76 --- L key.\r\nKEY_M = 77 --- M key.\r\nKEY_N = 78 --- N key.\r\nKEY_O = 79 --- O key.\r\nKEY_P = 80 --- P key.\r\nKEY_Q = 81 --- Q key.\r\nKEY_R = 82 --- R key.\r\nKEY_S = 83 --- S key.\r\nKEY_T = 84 --- T key.\r\nKEY_U = 85 --- U key.\r\nKEY_V = 86 --- V key.\r\nKEY_W = 87 --- W key.\r\nKEY_X = 88 --- X key.\r\nKEY_Y = 89 --- Y key.\r\nKEY_Z = 90 --- Z key.\r\n\r\n# Mouse wheel \r\nif event is InputEventMouseButton:\r\n\tif event.is_pressed():\r\n\t\t# zoom in\r\n\t\tif event.button_index == BUTTON_WHEEL_UP:\r\n\t\t\tzoom_pos = get_global_mouse_position()\r\n\t\t\t# call the zoom function\r\n\t\t# zoom out\r\n\t\tif event.button_index == BUTTON_WHEEL_DOWN:\r\n\t\t\tzoom_pos = get_global_mouse_position()\r\n\t\t\t# call the zoom function\r\n"
	
	
	
