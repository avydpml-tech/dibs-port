extends Control


func _ready():
	MenuHandler.connect("menu_changed", self, "_update_buttons")
	$optionDescription.text = ""



func _input(event):
	
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"))\
	and get_focus_owner() == null:
			$VBoxContainer / ggsBool5.call_deferred("grab_focus")
	
	if event.is_action_pressed("joy_b"):
		_check_where_back()
	



func _update_buttons():
	if not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.EXTRA):
		return

	for button in $VBoxContainer.get_children():
		if button is CheckButton:
			button.update_button()

		
		
func _on_OptionsButton_pressed():
	$optionDescription.text = ""
	_check_where_back()









func _check_where_back():
	if Globals.is_show_mainhub_start_screen:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.NONE)
	else:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.PAUSE)
