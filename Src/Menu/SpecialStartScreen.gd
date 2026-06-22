extends Node2D

func _enter_tree():
	if not Globals.is_show_mainhub_start_screen:
		queue_free()
	else:
		Globals.get_player().starting_state = "sit"


func _ready():
	if Globals.is_show_mainhub_start_screen:
		MenuHandler.connect("menu_changed", self, "should_show")
		Pause.set_allow_pause(false)
		$AnimationPlayer.play("fade_in")
		ScreenManager.fade_out(0.4, 0.8)


func _input(event):
	if event.is_action_pressed("ui_up")\
	or event.is_action_pressed("ui_down")\
	and $Control.get_focus_owner() == null:
		$Control / VBoxContainer2 / PlayButton.call_deferred("grab_focus")


func should_show():
	show() if MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.NONE) else hide()


func _on_PlayButton_pressed():
	Pause.set_allow_pause(true)
	Globals.get_player().is_seated = false
	Globals.is_show_mainhub_start_screen = false
	$AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name: String):
	if $AnimationPlayer.assigned_animation == "fade_out":
		queue_free()
