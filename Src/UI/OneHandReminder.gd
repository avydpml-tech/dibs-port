extends Node2D


func _ready():
	
	pass

func _input(event):
	if (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"))\
	and SettingsManager.is_one_handed_mode:
		show_reminder()

func show_reminder():
	if Globals.get_player().is_one_handed_reminded:
		return
	Globals.get_player().is_one_handed_reminded = true
	visible = true
	$Timer.start()

func _on_Timer_timeout():
	visible = false