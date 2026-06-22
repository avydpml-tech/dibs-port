



extends Node

var allow_pause: bool = true

signal game_paused
signal game_unpaused

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	

	if SceneChanger.connect("scene_changed", self, "scene_changer_set_pause") != OK:
		print_debug("Pause Singleton: signal scene_changed not connected to set_pause")

	if not self.is_connected("game_paused", self, "check_menu"):
		self.connect("game_paused", self, "check_menu")

	if not self.is_connected("game_unpaused", self, "check_menu"):
		self.connect("game_unpaused", self, "check_menu")


func _input(event):
	if event.is_action_pressed("ui_pause") and allow_pause:
		set_pause()
	













func set_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		self.emit_signal("game_paused")
	else:
		self.emit_signal("game_unpaused")
	return


func check_menu():
	if get_tree().paused:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.PAUSE)
	else:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.NONE)

func scene_changer_set_pause():
	get_tree().paused = false

func set_allow_pause(should_allow_pause: bool):
	allow_pause = should_allow_pause
