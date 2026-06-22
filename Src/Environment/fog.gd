extends Sprite


func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	hide()


func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	show()
