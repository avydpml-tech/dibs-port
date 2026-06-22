extends Node2D
class_name PhysicsInteractable

var player_entered: bool = false

func _ready():
	add_to_group("Interactable")
	pass



func interacted():
	pass


func _player_entered():
	_show_silhouette()
	player_entered = true
	
func _player_exited():
	_hide_silhouette()
	player_entered = false
	
func _show_silhouette():
	pass
	
func _hide_silhouette():
	pass




















func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
	pass
