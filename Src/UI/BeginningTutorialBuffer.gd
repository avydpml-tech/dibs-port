extends Control



func _ready():
	if Globals.completed_one_Handed_tutorial:
		get_parent().queue_free()


func _on_left_mouse_exited():
	get_parent().queue_free()
	Globals.completed_one_Handed_tutorial = true


func _on_right_mouse_exited():
	get_parent().queue_free()
	Globals.completed_one_Handed_tutorial = true

