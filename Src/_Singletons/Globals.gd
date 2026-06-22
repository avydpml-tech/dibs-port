extends Node




signal debug_mode_set
signal entered_mainhub
signal woof_jazz_played
signal blush_set(value)
signal hotkey_mode_pressed(setting, is_active)
signal joy_controller_activated(value)

var game_version: String
var game_name: String
var current_level
var is_moving_joysticks

var debug_mode: bool = false


var is_entered_mainhub: bool = false setget set_entered_mainhub
var is_show_mainhub_start_screen: bool = false


var is_minigame_active: bool = false
var is_woof_jazz: bool = false setget set_woof_jazz
var is_blush: bool = false


var is_using_controller: bool = false setget set_is_using_controller

var player_state_ref: String = ""


var has_game_started: bool = false


var completed_one_Handed_tutorial: = false


var is_tired_boss: bool = false


func set_is_using_controller(value):
	is_using_controller = value
	emit_signal("joy_controller_activated", is_using_controller)


func _ready():
	game_version = ProjectSettings.get_setting("application/config/version")
	game_name = "DiBS-" + game_version
	ProjectSettings.set_setting("application/config/name", game_name)
	pause_mode = Node.PAUSE_MODE_PROCESS

	CursorManager.set_visible(true)

	add_snack_timer()


func _input(event):

	
	var is_using_keyboard_or_mouse = event is InputEventMouseMotion or event is InputEventKey
	is_moving_joysticks = 0 != Input.get_axis("joy_left", "joy_right") or \
	Vector2(0, 0) != Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	if is_using_keyboard_or_mouse:
		self.is_using_controller = false
		CursorManager.set_visible(true)

	elif (is_moving_joysticks or event is InputEventJoypadButton) and not is_using_keyboard_or_mouse:
		self.is_using_controller = true
		CursorManager.set_visible(false)
	
	
	if event.is_action_pressed("ui_F5"):
		debug_mode = not debug_mode
		emit_signal("debug_mode_set")

	if event.is_action_pressed("ui_F4"):
		
		ProjectSettings.set_setting("display/window/vsync/use_vsync", false)


	if event.is_action_pressed("ui_z") and not get_tree().paused:
		SettingsManager.is_exploration_mode = not SettingsManager.is_exploration_mode
		var current: Dictionary = ggsManager.settings_data[str(18)]["current"]
		current["value"] = SettingsManager.is_exploration_mode
		ggsManager.save_settings_data()
		emit_signal("hotkey_mode_pressed", "exploration_mode", SettingsManager.is_exploration_mode)

	if event.is_action_pressed("ui_x") and not get_tree().paused:
		SettingsManager.is_bored_mode = not SettingsManager.is_bored_mode
		var current: Dictionary = ggsManager.settings_data[str(17)]["current"]
		current["value"] = SettingsManager.is_bored_mode
		ggsManager.save_settings_data()
		emit_signal("hotkey_mode_pressed", "bored_mode", SettingsManager.is_bored_mode)

	
	


func set_entered_mainhub(value):
	is_entered_mainhub = value
	emit_signal("entered_mainhub")


func set_woof_jazz(new_value):
	is_woof_jazz = new_value
	self.emit_signal("woof_jazz_played")


func set_blush(new_value):
	is_blush = new_value
	emit_signal("blush_set")


var is_in_tab_buttons: bool = false

func is_in_tab_buttons() -> bool:
	return is_in_tab_buttons
	




var tutorial_icons: Dictionary = {}
var player_var_dict = {}

func set_one_handed_controls(boolean: bool):
	player_var_dict["one_handed_controls"] = boolean


func get_player():
	for p in get_tree().get_nodes_in_group("Player"):
		return p


func _is_player(body) -> bool:
	for p in get_tree().get_nodes_in_group("Player"):
		if body == p:
			return true
	return false


func get_coom_button():
	for p in get_tree().get_nodes_in_group("CoomButton"):
		return p


func add_stamina(add):
	get_player().add_stamina(add)







var is_in_labs: bool = false

func reset_everything():
	reset_player()
	reset()
	EntityManager.reset_entities_list()
	ItemManager.reset_objects_list()
	Achievements.reset_achievements()
	EventManager.clear()
	SaveManager.save_all_data()

func restart_game():
	reset_everything()
	SceneChanger._change_scene("res://Src/Menu/temp/openingScene.tscn")


func new_timestamp():
	var tick = OS.get_ticks_msec()
	var ms = str(tick)
	ms.erase(ms.length() - 1, 1)
	var timestamp = "[" + str(tick / 3600000) + ":" + str(tick / 60000).pad_zeros(2) + ":" + str(tick / 1000).pad_zeros(2) + "." + ms + "]\t"
	return timestamp

func delete_settings():
	var dir = Directory.new()
	dir.open("user://")
	dir.remove("settings_data.json")






func reset():
	is_entered_mainhub = false


func save():
	var save = {
		"is_entered_mainhub": is_entered_mainhub, 
	}
	return save


func load_data(data_dict):
	if data_dict == null: return
		
	for key in data_dict:
		set(key, data_dict[key])


func reset_player():
	var save = {
		"current_health": 3, 
		"coom_count": 0, 
		"magazine_arr": [], 
		"ammo_count": 0, 
		"flashlight_active": true, 
		"show_debug": false, 
		"stamina": 100, 
	}

	set_global_player_variables(save)


func save_player_to_file():
	if get_player() != null:
		return get_player().save_to_file()

	var save = {
		"current_health": 1, 
		"ammo_count": 0, 
		"magazine_arr": [], 
		"is_blaster_enabled": true, 
		"is_most_ammo_first": true, 
	}
	return save

func get_current_level() -> String:
	return SceneChanger.get_current_scene()


func load_player_data(data_dict):
	player_var_dict = data_dict
	
		
	
	



func set_global_player_variables(player_dict):
	player_var_dict = player_dict


func get_global_player_variables():
	pass


func load_player_global_variables():
	if player_var_dict == {}: return
	for key in player_var_dict:
		get_player().set(key, player_var_dict[key])





var is_already_shown_one_handed_tutorial: = false

signal walk_area_entered
signal walk_area_entered_left
signal walk_area_exited_left
signal walk_area_entered_right
signal walk_area_exited_right

func walk_area_entered():
	self.emit_signal("walk_area_entered")

func walk_area_entered_left():
	self.emit_signal("walk_area_entered_left")

func walk_area_exited_left():
	self.emit_signal("walk_area_exited_left")

func walk_area_entered_right():
	self.emit_signal("walk_area_entered_right")

func walk_area_exited_right():
	self.emit_signal("walk_area_exited_right")


func add_snack_timer():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 10
	timer.set_name("snackTimer")
	add_child(timer)

func get_snack_timer():
	return get_node("snackTimer")

func start_snack_timer():
	get_node("snackTimer").start()
