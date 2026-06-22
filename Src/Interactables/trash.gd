extends Interactable


export (String) var unique_id = ""
var play_sound: bool = false


func _ready():
	get_node("toppled/toppled_highlight").hide()
	$Area2D.show_on_top = true

	call_deferred("_interacted_by_obj")

	
func _enter_tree():
	add_to_group(unique_id)


func _bin_toppled(boolean):
	$"toppled".visible = boolean
	$"upright".visible = not boolean


func interacted():
	_bin_toppled(false)
	if activated: return

	activated = true
	Achievements.trash_cleaned()
	ItemManager.save_item(self.save())


func _interacted_by_obj():
	if activated:
		_bin_toppled(false)



func _interacted_by_EventManager(variant):
	_bin_toppled(variant)

	
	
	if variant:
		Achievements.is_club_door_unlocked = true


func _show_silhouette():
	$"toppled/toppled_highlight".show()


func _hide_silhouette():
	$"toppled/toppled_highlight".hide()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) and player_entered:
		interacted()


func _on_Area2D_mouse_entered():
	
	pass
