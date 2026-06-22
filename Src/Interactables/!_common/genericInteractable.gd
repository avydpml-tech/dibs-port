extends Node2D
class_name Interactable

export (bool) var activated = false
export (bool) var is_persist = true
var player_entered: bool = false

func _ready():
	add_to_group("Interactable")
	if is_persist:
		add_to_group("ItemPersist")
	_hide_silhouette()


func interacted():
	pass


func item_activated():
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


func save():
	var save_dict = {
		"unique_id": get_name(), 
		"filename": get_filename(), 
		"parent_path": get_parent().get_path(), 
		"owner_path": get_owner().get_filename(), 
		"activated": activated, 
	}
	return save_dict




















func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
