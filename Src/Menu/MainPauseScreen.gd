extends Control


onready var resume_button = $VBoxContainer / ResumeButton

func _input(event):
	
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"))\
	and get_focus_owner() == null:
		resume_button.call_deferred("grab_focus")
	
	if event.is_action_pressed("ui_cancel"):
		_on_ResumeButton_pressed()


func _on_QuitButton_pressed():
	print(self.get_name(), ": Quit game")
	get_tree().quit()


func _on_ResumeButton_pressed():
	get_tree().paused = false
	Pause.check_menu()
	Globals.get_player().get_node("playerCamera")._on_camera_zoomed()


func _on_OptionsButton_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.OPTIONS)


func _on_Extras_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.EXTRA)
