extends Control




export (bool) var is_hide_after_time = true

func _ready():
	if Globals.is_already_shown_one_handed_tutorial:
		queue_free()

	Globals.connect("walk_area_entered_left", self, "_on_LeftArea_mouse_entered")
	Globals.connect("walk_area_exited_left", self, "_on_LeftArea_mouse_exited")
	Globals.connect("walk_area_entered_right", self, "_on_RightArea_mouse_entered")
	Globals.connect("walk_area_exited_right", self, "_on_RightArea_mouse_exited")


	set_visibility()
	SettingsManager.connect("one_handed_mode_set", self, "set_visibility")

	$Timer.start()


func _input(event):
	if event.is_action_pressed("ui_4"):
		$AnimationPlayer.play("fadeout")


func set_visibility():
	show() if SettingsManager.is_one_handed_mode else hide()


func _exit_tree():
	Globals.is_already_shown_one_handed_tutorial = true


func _on_RightArea_mouse_entered():
	if not get_tree().paused:
		$RightArea / Center / ArrowUpOutline2.show()

func _on_RightArea_mouse_exited():
	
	$RightArea / Center / ArrowUpOutline2.hide()


func _on_LeftArea_mouse_entered():
	if not get_tree().paused:
		$LeftArea / Center / ArrowUpOutline2.show()


func _on_LeftArea_mouse_exited():
	$LeftArea / Center / ArrowUpOutline2.hide()
	


func _on_Timer_timeout():
	if is_hide_after_time:
		$AnimationPlayer.play("fadeout")