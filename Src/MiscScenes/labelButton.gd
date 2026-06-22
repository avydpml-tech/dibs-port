extends Button

export (String) var mouse_entered = ""
export (String) var mouse_exited = ""
export (String) var url = ""





func _on_textButton_mouse_entered():
	set_text(mouse_entered)
	pass


func _on_textButton_mouse_exited():
	set_text(mouse_exited)
	pass


func _on_textButton_pressed():
	OS.shell_open(url)
	pass
