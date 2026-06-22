extends Control


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		_on_CancelButton_pressed()


func _on_QuitButton_pressed():
	print(self.get_name(), ": Quit game")
	get_tree().quit()



func _on_OptionsButton_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.OPTIONS)


func _on_Extras_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.EXTRA)



func _on_RestartButton_pressed():
	get_tree().paused = false
	Globals.restart_game()
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.NONE)
	
	
func _on_CancelButton_pressed():
	get_tree().paused = false
	Pause.check_menu()
	Globals.get_player().get_node("playerCamera")._on_camera_zoomed()

