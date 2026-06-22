extends Control


onready var first_control_node = $VBoxContainer / ggsBool

func _ready():
	$VBoxContainer / ggsBool3.set_text(SettingsManager.keyboard_layout)

func _input(event):
	
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"))\
	and get_focus_owner() == null:
			first_control_node.call_deferred("grab_focus")
	
	if event.is_action_pressed("joy_b"):
		_check_where_back()



func _process(delta):
	$VBoxContainer / ggsBool8 / optionDescription2.show() if (get_focus_owner() == get_node("VBoxContainer/ggsBool8")) else $VBoxContainer / ggsBool8 / optionDescription2.hide()
		


func _on_ggsBool3_pressed():
	$VBoxContainer / ggsBool3.set_text(SettingsManager.keyboard_layout)


func _on_OptionsButton_pressed():
	_check_where_back()








func _check_where_back():
	if Globals.is_show_mainhub_start_screen:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.NONE)
	else:
		MenuHandler.load_menu(MenuHandler.MENU_LEVEL.PAUSE)
