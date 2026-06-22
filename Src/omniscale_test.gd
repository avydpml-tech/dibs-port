extends Node2D


var timer = null
signal signaler


func _ready():
	connect("signaler", $Area2D, "_area_call_signal")
	
	_call_signal()
	timer = get_tree().create_timer(10)
	pass

func _process(delta):
	if timer != null:
		print(timer.time_left)
	if Input.is_action_just_pressed("ui_1"):
		timer.time_left += 10
		
	pass

func _call_signal():
	print("signal called")
	emit_signal("signaler")





func _on_rightSide_mouse_entered():
	
	pass


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		print("Clicked")
	pass
