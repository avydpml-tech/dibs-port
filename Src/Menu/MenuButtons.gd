extends Button



func _on_OptionsButton_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.OPTIONS)


func _on_Extras_pressed():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.EXTRA)


func _on_QuitButton_pressed():
	print(self.get_name(), ": Quit game")
	get_tree().quit()
